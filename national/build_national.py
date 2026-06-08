#!/usr/bin/env python3
"""
build_national.py

Reads original GeoJSON files from Congressional-Plans (never modifies them),
enriches features in-memory, and writes national-cd-{year}-raw.geojson to
the output/ subfolder.

Enrichment per feature:
  - Drops display/style fields (color, opacity, text-size, text-color, NAME)
  - Files with "2020 Pres" in filename:
      * Renames DemPct/RepPct/Margin → DemPct2020Pres/RepPct2020Pres/Margin2020Pres
      * Adds DemPct2024Pres/RepPct2024Pres/Margin2024Pres from The Downballot CSV
      * Notes: documents both sources
  - All other files (DRA 2024 data):
      * Renames DemPct/RepPct/Margin → DemPct2024Pres/RepPct2024Pres/Margin2024Pres
      * Notes: "Source: Dave's Redistricting App"
  - Notes is always the last field

Usage:
  python3 build_national.py --year 2022   # all 2022 maps
  python3 build_national.py --year 2024   # most recent through 2024
  python3 build_national.py --year 2026   # most recent (default)

Outputs: output/national-cd-{year}-raw.geojson
"""

import csv, json, os, re, argparse, copy

SCRIPT_DIR = os.path.dirname(__file__)
DATA_DIR   = os.path.join(SCRIPT_DIR, "..", "Congressional-Plans")
CSV_FILE   = os.path.join(SCRIPT_DIR, "downballot_2024.csv")
OUT_DIR    = os.path.join(SCRIPT_DIR, "output")

FIELDS_TO_DROP = {"color", "opacity", "text-size", "text-color", "NAME"}

DRA_NOTE = "Source: Dave's Redistricting App (https://davesredistricting.org)."
DB_URL   = ("https://docs.google.com/spreadsheets/d/"
            "1ng1i_Dm_RMDnEvauH44pgE6JCUsapcuu8F2pCfeLWFo")

# ── Load Downballot CSV ───────────────────────────────────────────────────────
# Row 0: banner, Row 1: year headers, Row 2: column headers, Row 3+: data
downballot = {}
with open(CSV_FILE, newline="") as f:
    rows = list(csv.reader(f))
for row in rows[3:]:
    if not row or not row[0].strip():
        continue
    dist = re.sub(r"-AL$", "-01", row[0].strip())
    try:
        downballot[dist] = {
            "harris":   float(row[3]) / 100,
            "trump24":  float(row[4]) / 100,
            "margin24": float(row[5]) / 100,
            "biden":    float(row[6]) / 100,
            "trump20":  float(row[7]) / 100,
            "margin20": float(row[8]) / 100,
        }
    except (ValueError, IndexError):
        pass

# ── Args ──────────────────────────────────────────────────────────────────────
parser = argparse.ArgumentParser()
parser.add_argument("--year", type=int, default=2026,
                    help="Max map year to include (2022, 2024, or 2026)")
args    = parser.parse_args()
MAX_YEAR = args.year

os.makedirs(OUT_DIR, exist_ok=True)
OUT_FILE = os.path.join(OUT_DIR, f"national-cd-{MAX_YEAR}-raw.geojson")

# ── Select most recent file per state up to MAX_YEAR ─────────────────────────
def parse_state_year(fname):
    m = re.match(r"^([A-Z]{2})-(\d{4})", fname)
    if m:
        return m.group(1), int(m.group(2))
    return None, None

state_files = {}
for fname in os.listdir(DATA_DIR):
    if not fname.endswith(".geojson"):
        continue
    state, year = parse_state_year(fname)
    if state is None or year > MAX_YEAR:
        continue
    if state not in state_files or year > state_files[state][1]:
        state_files[state] = (fname, year)

# ── Enrich and combine ────────────────────────────────────────────────────────
combined = {"type": "FeatureCollection", "features": []}

for state, (fname, year) in sorted(state_files.items()):
    is_2020_file = "2020 Pres" in fname
    fpath = os.path.join(DATA_DIR, fname)

    with open(fpath) as f:
        data = json.load(f)

    for feature in data["features"]:
        # Deep copy so we never mutate the in-memory original
        props = copy.deepcopy(feature["properties"])

        # Drop display/style fields
        for field in FIELDS_TO_DROP:
            props.pop(field, None)

        if is_2020_file:
            # Rename existing fields as 2020
            for old, new in [("DemPct", "DemPct2020Pres"),
                              ("RepPct", "RepPct2020Pres"),
                              ("Margin", "Margin2020Pres")]:
                if old in props:
                    props[new] = props.pop(old)

            # Add 2024 from Downballot
            dist = re.sub(r"-AL$", "-01", props.get("state-district", "").strip())
            db   = downballot.get(dist)
            if db:
                props["DemPct2024Pres"] = round(db["harris"],   6)
                props["RepPct2024Pres"] = round(db["trump24"],  6)
                props["Margin2024Pres"] = round(db["margin24"], 6)
                note = (f"2020 Pres data from original precinct-based shapefile. "
                        f"2024 Pres data (Harris/Trump %) from The Downballot ({DB_URL}).")
            else:
                print(f"  WARNING: {dist} not found in Downballot data")
                note = "2020 Pres data from original precinct-based shapefile."

        else:
            # DRA file — rename DemPct/RepPct as 2024, recalculate Margin
            # from DemPct - RepPct to avoid sign errors in the stored Margin field
            dem = props.pop("DemPct", None)
            rep = props.pop("RepPct", None)
            props.pop("Margin", None)
            if dem is not None and rep is not None:
                props["DemPct2024Pres"] = dem
                props["RepPct2024Pres"] = rep
                props["Margin2024Pres"] = round(dem - rep, 6)
            note = DRA_NOTE

        # Mark whether this state's map changed vs the previous cycle
        # (no states change in the 2022 baseline; 2024/2026 mark their new files)
        props["changed"] = 1 if (year == MAX_YEAR and MAX_YEAR > 2022) else 0

        # Notes always last
        props["Notes"] = note

        enriched = {"type": "Feature",
                    "geometry": feature["geometry"],
                    "properties": props}
        combined["features"].append(enriched)

    print(f"  {state} ({year}) — {fname}")

with open(OUT_FILE, "w") as f:
    json.dump(combined, f)

n = len(combined["features"])
s = len(state_files)
print(f"\nWrote {n} districts from {s} states → {OUT_FILE}")
