# Results

## macOS, run 1 (2026-10-22)

MacBook Air M1 (2020), 16 GB, 1 TB. Brightness max, auto-brightness and True Tone off, Wi-Fi on,
Bluetooth off, Chrome with workload.html (a public page every 60 s), `caffeinate -di`.

- 100% at 16:47, last sample at 1% at 23:44 local, then the Air went down: **6 h 57 m**
- Power draw: **6.34 W average** (median 6.23, 6.02 to 10.09), flat across the run:
  6.33 / 6.30 / 6.34 / 6.34 / 6.31 / 6.32 / 6.45 W per hour
- About **43.8 Wh** drawn from 100% to 1% (43.4 Wh logged + ~4 min before the watts fix)
- 90% at 1.0 h, 75% at 2.1 h, 50% at 3.8 h, 25% at 5.4 h, 10% at 6.4 h

Files: `macos-run1.csv` (first 4 minutes, watts column broken: awk rounded the
unsigned amperage to 0) and `macos-run1b.csv` (the rest, watts via bc).

Battery Health: Normal, maximum capacity **95%** (~47.4 Wh of the 49.9 Wh design),
so the 43.8 Wh measured leaves ~3.6 Wh that macOS keeps back at shutdown or the
meter misses.

macOS Golden Gate 27.0.1. MacBook Air M1 (2020), 16 GB RAM.

## Omarchy, run 2 (2026-10-23)

Same Air, Omarchy 4.5.0rc1 on the Asahi kernel 7.2.12 (omarchy-mac, quattro), LUKS on,
power profile balanced, brightness 100% (brightnessctl), Bluetooth blocked, Docker
stopped, Chromium with workload.html, idle off with `omarchy-toggle-idle` (Omarchy 4
has no hypridle: the shell blanks the screen, which spoiled run 1 after 5 minutes).

- 100% at 15:15, last sample at 2% at 20:38 local: **5 h 23 m**
- **8.10 W average** (median 8.08, 7.83 to 9.10), flat every hour: 8.05 / 8.08 / 8.05 / 8.18 / 8.11 / 8.16 W
- **43.6 Wh** drawn (macOS: 43.4 Wh). The two runs read power from different sources
  (ioreg on macOS, power_now on Linux) and still agree on the energy, so the meters can be trusted.

## Comparison

| | macOS 27.0.1 | Omarchy (Asahi) |
|---|---|---|
| 100% to off | 6 h 57 m | 5 h 23 m (-23%) |
| average draw | 6.34 W | 8.10 W (+28%) |
| energy | 43.4 Wh | 43.6 Wh |

macOS sits around 6.1-6.3 W and spikes on page loads; Omarchy stays flat at ~8 W, which
points at a higher floor (display/GPU or idle states) rather than the browser work itself.
Chart: battery.png (`python3 ../chart.py battery.png`, needs matplotlib).

