#!/usr/bin/env python3
"""Battery % and power draw over time, macOS vs Omarchy, from the battlog CSVs."""
import csv, sys
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

def load(*files):
    rows = []
    for f in files:
        rows += list(csv.DictReader(open(f)))
    t0 = int(rows[0]["ts"])
    rows = [r for r in rows if r["charging"] == "0"]
    h = [(int(r["ts"]) - t0) / 3600 for r in rows]
    pct = [int(r["percent"]) for r in rows]
    w = [float(r["watts"]) if r["watts"] and float(r["watts"]) > 0.5 else None for r in rows]
    return h, pct, w

runs = [("macOS 27", "#3b82f6", load("macos-run1.csv", "macos-run1b.csv")),
        ("Omarchy (Asahi)", "#e5484d", load("omarchy-run2.csv"))]

plt.rcParams.update({"font.size": 13, "font.family": "DejaVu Sans"})
fig, (a1, a2) = plt.subplots(2, 1, figsize=(10, 7.5), sharex=True, gridspec_kw={"height_ratios": [2, 1]})
for name, color, (h, pct, w) in runs:
    end = h[-1]
    a1.plot(h, pct, color=color, lw=2.5, label=f"{name}: {int(end)}h {round(end % 1 * 60):02d}m")
    hw = [x for x, y in zip(h, w) if y]
    ww = [y for y in w if y]
    a2.plot(hw, ww, color=color, lw=1.5, label=f"{name}: {sum(ww)/len(ww):.1f} W avg")
a1.set_ylabel("battery %")
a1.set_ylim(0, 102)
a1.legend(loc="lower left", frameon=False)
a1.set_title("MacBook Air M1, same test: max brightness, Chrome/Chromium page rotation", fontsize=13)
a2.set_ylabel("watts")
a2.set_xlabel("hours on battery")
a2.set_ylim(0, 11)
a2.legend(loc="lower left", frameon=False)
for a in (a1, a2):
    a.grid(alpha=0.25)
    a.spines[["top", "right"]].set_visible(False)
fig.tight_layout()
fig.savefig(sys.argv[1] if len(sys.argv) > 1 else "battery.png", dpi=150)
