#!/usr/bin/env bash
# Pull the Census 2020 Block Assignment Files and fold them into one national
# block -> standard-geography crosswalk.
#
#   usage: fetch_baf.sh <work_dir> <out.csv.gz>
#
# BAF is the official block-to-geography equivalency: place, VTD, state house,
# state senate, congressional district (116th, the 2020 vintage), school
# district, and AIANNH area. Joined to the spine on GEOID20 it lets you roll
# blocks up to any of those without touching geometry.
set -euo pipefail
WORK="${1:?work dir required}"
OUT="${2:?output path required}"
mkdir -p "$WORK/zips"

STATES="01 AL,02 AK,04 AZ,05 AR,06 CA,08 CO,09 CT,10 DE,11 DC,12 FL,13 GA,15 HI,
16 ID,17 IL,18 IN,19 IA,20 KS,21 KY,22 LA,23 ME,24 MD,25 MA,26 MI,27 MN,28 MS,
29 MO,30 MT,31 NE,32 NV,33 NH,34 NJ,35 NM,36 NY,37 NC,38 ND,39 OH,40 OK,41 OR,
42 PA,44 RI,45 SC,46 SD,47 TN,48 TX,49 UT,50 VT,51 VA,53 WA,54 WV,55 WI,56 WY,
60 AS,66 GU,69 MP,72 PR,78 VI"

LAYERS="INCPLACE_CDP VTD CD SLDU SLDL SDUNI AIANNH"

get_one() {
  local fips=$1 post=$2 work=$3
  local z="$work/zips/BlockAssign_ST${fips}_${post}.zip"
  [ -s "$z" ] || curl -sfS --retry 3 -o "$z" \
    "https://www2.census.gov/geo/docs/maps-data/data/baf2020/BlockAssign_ST${fips}_${post}.zip" \
    || { echo "FAIL $post" >&2; rm -f "$z"; return 0; }
  echo "ok   $post"
}
export -f get_one

echo "$STATES" | tr ',' '\n' | tr -d '\n\t' >/dev/null  # noop, keeps shellcheck quiet
echo "$STATES" | tr ',' '\n' | sed 's/^ *//;s/ *$//' | grep -v '^$' \
  | xargs -P 6 -I{} bash -c 'set -- {}; get_one $1 $2 "'"$WORK"'"'

# Fold every layer of every state into one wide row per block.
python3 - "$WORK/zips" "$OUT" "$LAYERS" <<'PY'
import csv, gzip, io, sys, zipfile, pathlib

zipdir, out, layers = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3].split()
cols = ["GEOID20"] + layers
with gzip.open(out, "wt", newline="") as fh:
    w = csv.writer(fh)
    w.writerow(cols)
    for zp in sorted(zipdir.glob("*.zip")):
        rows = {}
        with zipfile.ZipFile(zp) as z:
            # BlockAssign_ST10_DE_INCPLACE_CDP.txt -> layer "INCPLACE_CDP"
            names = {n[:-4].split("_", 3)[3]: n for n in z.namelist()
                     if n.endswith(".txt") and len(n[:-4].split("_", 3)) == 4}
            for layer in layers:
                if layer not in names:
                    continue
                with z.open(names[layer]) as f:
                    rdr = csv.reader(io.TextIOWrapper(f, "utf-8"), delimiter="|")
                    next(rdr, None)
                    for rec in rdr:
                        if len(rec) < 2:
                            continue
                        rows.setdefault(rec[0], {})[layer] = rec[1]
        for geoid in sorted(rows):
            r = rows[geoid]
            w.writerow([geoid] + [r.get(l, "") for l in layers])
        print(f"{zp.stem}: {len(rows)} blocks", file=sys.stderr)
PY
echo "wrote $OUT"
