#!/usr/bin/env python3
"""
Combines per-state congressional district GeoJSON files into a single
national file, selecting the most recent map year per state.

Election data note:
  - Files with "(w 2020 Pres)" in the filename use 2020 Presidential results.
  - All other files use 2024 Presidential results.
  DemPct / RepPct are renamed accordingly: DemPct2024Pres, RepPct2020Pres, etc.

Outputs: national-cd-raw.geojson (pre-clip, in this directory)
"""

import json, os, re

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "Congressional-Plans")
OUT_FILE = os.path.join(os.path.dirname(__file__), "national-cd-raw.geojson")

FIELDS_TO_DROP = {"color", "opacity", "text-size", "text-color", "NAME"}

def parse_state_year(fname):
    m = re.match(r'^([A-Z]{2})-(\d{4})', fname)
    if m:
        return m.group(1), int(m.group(2))
    return None, None

def is_2020_pres(fname):
    return "2020 Pres" in fname

# ── Select most recent file per state ────────────────────────────────────────
state_files = {}
for fname in os.listdir(DATA_DIR):
    if not fname.endswith(".geojson"):
        continue
    state, year = parse_state_year(fname)
    if state is None:
        continue
    if state not in state_files or year > state_files[state][1]:
        state_files[state] = (fname, year)

# ── Combine ───────────────────────────────────────────────────────────────────
combined = {"type": "FeatureCollection", "features": []}

for state, (fname, year) in sorted(state_files.items()):
    elec_year = "2020" if is_2020_pres(fname) else "2024"
    fpath = os.path.join(DATA_DIR, fname)
    with open(fpath) as f:
        data = json.load(f)

    for feature in data["features"]:
        props = feature["properties"]
        # Rename election-result fields
        for field in ("DemPct", "RepPct", "Margin"):
            if field in props:
                props[f"{field}{elec_year}Pres"] = props.pop(field)
        # Drop display/style fields
        for field in FIELDS_TO_DROP:
            props.pop(field, None)
        combined["features"].append(feature)

    print(f"  {state} ({year}, {elec_year} Pres) — {fname}")

with open(OUT_FILE, "w") as f:
    json.dump(combined, f)

n = len(combined["features"])
s = len(state_files)
print(f"\nWrote {n} districts from {s} states → {OUT_FILE}")
