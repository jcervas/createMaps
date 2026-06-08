#!/usr/bin/env bash
# ============================================================
# build_national.sh
# Builds national-cd.geojson from per-state congressional
# district files. Run from this directory.
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "$SCRIPT_DIR"
US_STATE="$SCRIPT_DIR/../us-state.json"
RAW="$SCRIPT_DIR/national-cd-raw.geojson"
OUT="$SCRIPT_DIR/national-cd.geojson"

echo "=== Step 1: Combine per-state files ==="
python3 "$SCRIPT_DIR/build_national.py"

echo ""
echo "=== Step 2: Clip water with mapshaper ==="
mapshaper \
  -i "$RAW" name=cd \
  -i "$US_STATE" name=us-state \
  -dissolve target=us-state \
  -clip target=cd source=us-state \
  -clean target=cd \
  -o "$OUT" target=cd format=geojson

echo ""
echo "Done → $OUT"
