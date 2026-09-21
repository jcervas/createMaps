#!/usr/bin/env bash
# Assemble the per-state TIGER extracts into one national block spine.
#
#   usage: assemble_spine.sh <raw_dir> <out.csv.gz>
#
# Adds the parent-geography keys every equivalency join needs (county, tract,
# block group) plus the state postal code, and normalizes the internal point
# coordinates out of TIGER's zero-padded "+38.8754924" / "-075.5997892" form.
set -euo pipefail
RAW="${1:?raw dir required}"
OUT="${2:?output path required}"

awk -F, -v OFS=, '
BEGIN {
  split("01 AL,02 AK,04 AZ,05 AR,06 CA,08 CO,09 CT,10 DE,11 DC,12 FL,13 GA," \
        "15 HI,16 ID,17 IL,18 IN,19 IA,20 KS,21 KY,22 LA,23 ME,24 MD,25 MA," \
        "26 MI,27 MN,28 MS,29 MO,30 MT,31 NE,32 NV,33 NH,34 NJ,35 NM,36 NY," \
        "37 NC,38 ND,39 OH,40 OK,41 OR,42 PA,44 RI,45 SC,46 SD,47 TN,48 TX," \
        "49 UT,50 VT,51 VA,53 WA,54 WV,55 WI,56 WY,60 AS,66 GU,69 MP,72 PR," \
        "78 VI", pairs, ",")
  for (i in pairs) { split(pairs[i], kv, " "); post[kv[1]] = kv[2] }
  print "GEOID20","ST","STATEFP","COUNTYFP","TRACT","BLKGRP","BLOCKCE", \
        "POP20","HOUSING20","ALAND20","AWATER20","INTPTLAT","INTPTLON", \
        "UR20","UACE20","FUNCSTAT20"
}
FNR == 1 { next }
{
  gsub(/"/, "")
  g = $1
  if (length(g) != 15) { bad++; next }
  printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%.7f,%.7f,%s,%s,%s\n",
    g, post[substr(g,1,2)], substr(g,1,2), substr(g,1,5), substr(g,1,11),
    substr(g,1,12), substr(g,12,4), $9, $10, $5, $6, $7+0, $8+0, $2, $3, $4
}
END { if (bad) printf "dropped %d malformed rows\n", bad > "/dev/stderr" }
' "$RAW"/*.csv | gzip -6 > "$OUT"

echo "wrote $OUT ($(du -h "$OUT" | cut -f1))"
