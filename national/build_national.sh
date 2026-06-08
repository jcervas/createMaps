#!/usr/bin/env bash
# ============================================================
# build_national.sh
# Builds national-cd-{2022,2024,2026}.geojson and .svg from
# per-state congressional district files. Run from this directory.
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$SCRIPT_DIR/output"
US_STATE="$SCRIPT_DIR/../us-state.json"

mkdir -p "$OUT_DIR"

for YEAR in 2022 2024 2026; do
  echo "========================================"
  echo "=== Building $YEAR map ==="
  echo "========================================"

  RAW="$OUT_DIR/national-cd-${YEAR}-raw.geojson"
  OUT="$OUT_DIR/national-cd-${YEAR}.geojson"
  SVG="$OUT_DIR/national-cd-${YEAR}.svg"

  echo "--- Step 1: Combine per-state files ---"
  python3 "$SCRIPT_DIR/build_national.py" --year "$YEAR"

  echo ""
  echo "--- Step 2: Clip water and clean lines ---"
  mapshaper \
    -i "$RAW" name=cd \
    -i "$US_STATE" name=us-state \
    -dissolve target=us-state \
    -clip target=cd source=us-state \
    -clean target=cd \
    -o "$OUT" target=cd format=geojson

  echo ""
  echo "--- Step 3: Generate SVG ---"
  mapshaper \
    -i "$OUT" name=cd \
    -proj albersusa \
    -each 'Party = Margin2024Pres > 0 ? "DEM" : "GOP"' target=cd \
    -each 'winning_pct = Party === "DEM" ? DemPct2024Pres * 100 : RepPct2024Pres * 100' target=cd \
    -each 'color = Party === "DEM" ? (winning_pct >= 60 ? "#1375B7" : winning_pct >= 55 ? "#5295CC" : winning_pct >= 50 ? "#92BDE0" : "#CEEAFD") : (winning_pct >= 60 ? "#C93135" : winning_pct >= 55 ? "#DB7171" : winning_pct >= 50 ? "#EAA9A9" : "#FCE0E0")' target=cd \
    -style fill=color opacity=0.8 stroke=none target=cd \
    -lines + name=district-lines \
    -style stroke='rgba(255,255,255,0.25)' stroke-width='TYPE=="inner" ? 0.5 : 0' fill=none target=district-lines \
    -dissolve state + name=state target=cd \
    -lines + name=state-lines target=state \
    -style stroke='#c5c5c5' stroke-width='TYPE=="inner" ? 1 : 0.7' fill=none target=state-lines \
    -filter 'changed === 1' + name=changed-states target=cd \
    -dissolve state target=changed-states \
    -style stroke='#000000' stroke-width=1.5 fill=none target=changed-states \
    -drop target=state \
    -dissolve target=cd fill \
    -simplify 5% \
    -o "$SVG" target=cd,state-lines,district-lines,changed-states format=svg

  echo ""
  echo "--- Step 4: District count ---"
  mapshaper -i "$OUT" -calc 'dem=sum(Margin2024Pres > 0 ? 1 : 0); rep=sum(Margin2024Pres < 0 ? 1 : 0)'

  echo ""
  echo "Done → $OUT"
  echo "Done → $SVG"
  echo ""
done

echo "All maps built."
