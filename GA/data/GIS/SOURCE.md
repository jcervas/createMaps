# GA source data

Built fresh for the Houston County racial dot-density map — this repo had no
GA folder before. All 2020 vintage, matching the rest of this repo's TN/etc.
conventions, except field names have no `20` suffix (that's simply how the
TIGER/Line product names them; not worth renaming for cosmetic parity).

| File | Source | Built how |
|---|---|---|
| `blockgroups.json` | TIGER/Line 2020 block-group boundaries (`tl_2020_13_bg.zip`) joined to 2020 P.L. 94-171 total population (`P1_001N`/`P1_003N`/`P1_004N`) and voting-age population (`P3_001N`/`P3_003N`/`P3_004N`) counts, Census API `dec/pl` | `mapshaper -join ... keys=GEOID,GEOID`, 7,446/7,446 block groups matched |
| `tl_2020_13_place.json` | TIGER/Line 2020 place boundaries (`tl_2020_13_place.zip`), geometry only | direct shapefile → JSON conversion |
| `tracts.json` | Same recipe as `blockgroups.json`, at tract level (2,796/2,796 matched) | kept as a general-purpose GA asset; the map script itself now uses block groups instead — Houston County has few enough tracts that a tract-level map showed only a handful of dots inside the county |

Fields on `blockgroups.json`: `STATEFP, COUNTYFP, TRACTCE, GEOID, ALAND, TOTAL, WHITE, BLACK, TOTAL_VAP, WHITE_VAP, BLACK_VAP` (the `_VAP` fields are voting-age population, from P3; `tracts.json` predates these and only has the P1 total-population fields).

**Rebuilding.** There's no build script anymore (the mapshaper/basemap static
map that used to auto-fetch these on a clean checkout was retired — the
`houston-county-dot-map-d3.html` map now covers that need). To regenerate
`blockgroups.json` from scratch:

```bash
STATE_FIPS=13
curl -s -o tl_2020_bg.zip "https://www2.census.gov/geo/tiger/TIGER2020/BG/tl_2020_${STATE_FIPS}_bg.zip"
unzip -oq tl_2020_bg.zip -d bg_raw

# Block-group queries need the county wildcard shown below -- a bare state
# wildcard (fine for tract-level queries) 400s at block-group level.
curl -s -o pl2020_bg_raw.json \
  "https://api.census.gov/data/2020/dec/pl?get=P1_001N,P1_003N,P1_004N,P3_001N,P3_003N,P3_004N,NAME&for=block%20group:*&in=state:${STATE_FIPS}%20county:*&key=${CENSUS_API_KEY}"

python3 -c "
import json, csv
d = json.load(open('pl2020_bg_raw.json'))
hdr = d[0]
with open('pl2020_bg.csv', 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['GEOID', 'TOTAL', 'WHITE', 'BLACK', 'TOTAL_VAP', 'WHITE_VAP', 'BLACK_VAP'])
    for row in d[1:]:
        rec = dict(zip(hdr, row))
        geoid = rec['state'] + rec['county'] + rec['tract'] + rec['block group']
        w.writerow([geoid, rec['P1_001N'], rec['P1_003N'], rec['P1_004N'],
                     rec['P3_001N'], rec['P3_003N'], rec['P3_004N']])
"

mapshaper -i "bg_raw/tl_2020_${STATE_FIPS}_bg.shp" \
  -i pl2020_bg.csv string-fields=GEOID \
  -join target="tl_2020_${STATE_FIPS}_bg" source=pl2020_bg keys=GEOID,GEOID \
  -filter-fields STATEFP,COUNTYFP,TRACTCE,GEOID,ALAND,TOTAL,WHITE,BLACK,TOTAL_VAP,WHITE_VAP,BLACK_VAP \
  -o blockgroups.json force
```

And `tl_2020_13_place.json`:

```bash
curl -s -o tl_2020_place.zip "https://www2.census.gov/geo/tiger/TIGER2020/PLACE/tl_2020_${STATE_FIPS}_place.zip"
unzip -oq tl_2020_place.zip -d place_raw
mapshaper -i "place_raw/tl_2020_${STATE_FIPS}_place.shp" -o tl_2020_13_place.json force
```

`tracts.json` uses the same block-group recipe with `TRACT` in place of `BG`
in the TIGER path, if it's ever needed again.

Block-group P.L. 94-171 queries need an explicit county wildcard in the
Census API's `in=` clause (`state:13 county:*`) — a bare state wildcard,
which works fine for tract-level queries, returns a 400 at block-group level.

The Census API key: the script reads `$CENSUS_API_KEY` if set, otherwise
falls back to the one already saved in `~/.Renviron` (also used by this
machine's R/tidycensus setup). Get a free key at
https://api.census.gov/data/key_signup.html if neither is available.
