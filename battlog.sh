#!/bin/sh
# Logs the battery once a minute to a CSV until you stop it (Ctrl-C) or the
# machine dies. Same script on macOS and Linux, so both runs give the same columns.
#
#   ./battlog.sh macos-run1.csv
#
# Columns: unix time, ISO time, percent, charging (1/0), power draw in watts
# (empty when the OS does not report it).
out=${1:-battery-$(date +%Y%m%d-%H%M).csv}
echo "ts,time,percent,charging,watts" > "$out"
while :; do
  ts=$(date +%s); now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  if [ "$(uname)" = Darwin ]; then
    pct=$(pmset -g batt | grep -o '[0-9]*%' | head -1 | tr -d %)
    if pmset -g batt | grep -q 'AC Power'; then chg=1; else chg=0; fi
    # Amperage is in mA (averaged by the battery), Voltage in mV. ioreg prints a
    # negative amperage as an unsigned 64-bit number, which awk's doubles round
    # to 0, so bc does the maths.
    bat=$(ioreg -rn AppleSmartBattery)
    a=$(echo "$bat" | awk -F' = ' '/"Amperage"/ {print $2; exit}')
    v=$(echo "$bat" | awk -F' = ' '/"Voltage"/ && !/Cell|Nominal|Max|Min|Raw/ {print $2; exit}')
    w=""
    if [ -n "$a" ] && [ -n "$v" ]; then
      w=$(echo "a = $a; if (a > 2^63) a = a - 2^64; if (a < 0) a = -a; scale = 2; a * $v / 1000000" | bc)
    fi
  else
    b=$(ls -d /sys/class/power_supply/*/ | while read d; do [ "$(cat "$d/type" 2>/dev/null)" = Battery ] && echo "$d" && break; done)
    pct=$(cat "$b/capacity")
    [ "$(cat "$b/status")" = Discharging ] && chg=0 || chg=1
    if [ -r "$b/power_now" ]; then
      # signed on Asahi (negative while discharging): keep the magnitude, like macOS
      w=$(awk '{v = $1 < 0 ? -$1 : $1; printf "%.2f", v/1e6}' "$b/power_now")
    elif [ -r "$b/current_now" ] && [ -r "$b/voltage_now" ]; then
      w=$(awk -v c="$(cat "$b/current_now")" -v v="$(cat "$b/voltage_now")" 'BEGIN{printf "%.2f", (c<0?-c:c)*v/1e12}')
    else w=""; fi
  fi
  echo "$ts,$now,$pct,$chg,$w" >> "$out"
  sleep 60
done
