#!/usr/bin/env bash
# Pull 2020 tabulation-block attributes (no geometry) for every state/territory
# straight out of the TIGER 2023 TABBLOCK20 zips over HTTP range requests.
#
#   usage: fetch_tiger_blocks.sh <raw_output_dir> [parallel_jobs]
#
# TIGER2023 is used because it is the most recent vintage that still carries the
# 2020 census counts (POP20 / HOUSING20) on the block record. Geometry is never
# downloaded in full -- GDAL only pulls the DBF member of each zip.
set -euo pipefail

OUT="${1:?output dir required}"
JOBS="${2:-6}"
VINTAGE=2023
mkdir -p "$OUT"

FIPS="01 02 04 05 06 08 09 10 11 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 \
28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 \
56 60 66 69 72 78"

FIELDS=GEOID20,UR20,UACE20,FUNCSTAT20,ALAND20,AWATER20,INTPTLAT20,INTPTLON20,POP20,HOUSING20

fetch_one() {
  local st=$1 out=$2 vintage=$3 fields=$4
  local zip="https://www2.census.gov/geo/tiger/TIGER${vintage}/TABBLOCK20/tl_${vintage}_${st}_tabblock20.zip"
  local src="/vsizip//vsicurl/${zip}/tl_${vintage}_${st}_tabblock20.shp"
  local dst="${out}/${st}.csv"
  local tmp="${out}/.tmp_${st}"
  [ -s "$dst" ] && { echo "skip $st (have $(( $(wc -l < "$dst") - 1 )) rows)"; return 0; }
  for attempt in 1 2 3; do
    # Write through /vsistdout/ rather than naming a file: GDAL's CSV driver
    # will otherwise create a *directory* datasource for some inputs.
    if ogr2ogr -f CSV /vsistdout/ "$src" -select "$fields" > "$tmp" 2>/dev/null \
       && [ -s "$tmp" ]; then
      mv "$tmp" "$dst"
      echo "ok   $st  $(( $(wc -l < "$dst") - 1 )) blocks"
      return 0
    fi
    rm -f "$tmp"
    sleep $(( attempt * 5 ))
  done
  echo "FAIL $st" >&2
  return 1
}
export -f fetch_one

printf '%s\n' $FIPS | xargs -P "$JOBS" -I{} bash -c 'fetch_one "$@"' _ {} "$OUT" "$VINTAGE" "$FIELDS"
