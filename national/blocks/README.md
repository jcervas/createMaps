# National 2020 Census Block Spine

One row for every 2020 tabulation block in the United States — **8,180,866 blocks**
across the 50 states, DC, Puerto Rico, and the four island areas — keyed on
`GEOID20`, carrying the geography needed to join it to anything and the PL 94-171
counts needed to report on the result.

Built for equivalency files covering geographies the Census does not maintain:
media markets (DMAs), mid-decade congressional plans, coalition districts,
service areas — anything that can be expressed as a block-to-area assignment.

The data files are gitignored (271 MB national, 286 MB split by state, 22 MB
crosswalk); rebuild them with the scripts below in roughly 20 minutes.

---

## Files

| Path | Contents |
|------|----------|
| `us_blocks_2020.csv.gz` | The national spine, 8,180,866 rows × 55 columns |
| `us_blocks_2020_baf.csv.gz` | Block → place / VTD / CD / SLDU / SLDL / school district / AIANNH |
| `by_state/{ST}.csv.gz` | The same rows split by postal code, for state-sized work |
| `scripts/` | The build pipeline (see below) |

## Columns

**Geography** — `GEOID20`, `ST` (postal), `STATEFP`, `COUNTYFP` (5-digit),
`TRACT` (11), `BLKGRP` (12), `BLOCKCE` (4). The parent keys are materialized so a
rollup to county, tract, or block group is a `GROUP BY`, not a substring.

**Block attributes** — `ALAND20`, `AWATER20` (square meters), `INTPTLAT`,
`INTPTLON` (internal point, decimal degrees, NAD83), `UR20` (urban/rural),
`UACE20` (urban area code), `FUNCSTAT20`.

**Counts** — `POP20`, `HOUSING20`, then the PL 94-171 detail:

| Group | Columns |
|-------|---------|
| Population by race | `POP_WHITE` `POP_BLACK` `POP_AIAN` `POP_ASIAN` `POP_NHPI` `POP_OTHER` `POP_TWOPLUS` |
| Population by ethnicity × race | `POP_HISP` `POP_NH_WHITE` `POP_NH_BLACK` `POP_NH_AIAN` `POP_NH_ASIAN` `POP_NH_NHPI` `POP_NH_OTHER` `POP_NH_TWOPLUS` |
| Voting-age population by race | `VAP_TOTAL` `VAP_WHITE` `VAP_BLACK` `VAP_AIAN` `VAP_ASIAN` `VAP_NHPI` `VAP_OTHER` `VAP_TWOPLUS` |
| VAP by ethnicity × race | `VAP_HISP` `VAP_NH_WHITE` `VAP_NH_BLACK` `VAP_NH_AIAN` `VAP_NH_ASIAN` `VAP_NH_NHPI` `VAP_NH_OTHER` `VAP_NH_TWOPLUS` |
| Housing | `HU_OCCUPIED` `HU_VACANT` |
| Group quarters | `GQ_TOTAL` `GQ_CORRECTIONAL` `GQ_JUVENILE` `GQ_NURSING` `GQ_NONINST` `GQ_COLLEGE` |

`GQ_CORRECTIONAL` is there for prison-gerrymandering adjustments; the `VAP_NH_*`
columns are the ones VRA analysis actually uses.

The island areas (AS, GU, MP, VI — 5,911 blocks) have geography but no PL
columns: the Census publishes their demographics in a separate Island Areas
release, not in `2020/dec/pl`.

---

## Sources

Two independent sources, deliberately, so they can check each other:

1. **TIGER/Line 2023 `TABBLOCK20`** — geography plus `POP20` / `HOUSING20`.
   TIGER 2023 is the most recent vintage that still carries the 2020 counts on
   the block record; 2024 dropped them. Read over HTTP range requests through
   GDAL's `/vsizip//vsicurl/`, so no shapefile is ever stored — only the DBF
   attribute table moves across the wire.
2. **Census API, `2020/dec/pl`** — the PL 94-171 tables (P1, P2, P3, P4, P5, H1),
   one request per county.

## Verification

Every figure below was checked against published totals, for the 50 states + DC:

| Measure | Spine | Published |
|---------|-------|-----------|
| Blocks | 8,132,968 | 8,132,968 |
| Total population | 331,449,281 | 331,449,281 |
| Housing units | 140,498,736 | 140,498,736 |
| Black alone | 41,104,200 | 41,104,200 |
| Hispanic or Latino | 62,080,044 | 62,080,044 |
| NH White alone | 191,697,647 | 191,697,647 |
| Voting-age population | 258,343,281 | 258,343,281 |
| Group quarters | 8,239,016 | 8,239,016 |

Adding Puerto Rico's 41,987 blocks gives 8,174,955 — the official national total.

The merge step also compares TIGER's `POP20` and `HOUSING20` against the API's
`P1_001N` and `H1_001N` block by block: **0 mismatches across all 8,174,955
blocks** with PL coverage. Two independently sourced values agreeing on every
block is the strongest available check that neither pull dropped or shifted rows.

---

## Rebuilding

Needs `ogr2ogr` (GDAL) and a Census API key in `CENSUS_API_KEY` or `~/.Renviron`.

```bash
RAW=/tmp/blockbuild
national/blocks/scripts/fetch_tiger_blocks.sh  "$RAW/tiger"        # ~8 min
python3 national/blocks/scripts/fetch_pl_blocks.py "$RAW/pl"       # ~7 min
python3 national/blocks/scripts/merge_spine.py "$RAW/tiger" "$RAW/pl" \
        national/blocks/us_blocks_2020.csv.gz                      # ~6 min
```

If you have no API key, `scripts/assemble_spine.sh "$RAW/tiger" out.csv.gz`
builds a geography-only spine from the TIGER extracts alone — the same 16
geography and `POP20` / `HOUSING20` columns, without the PL detail.

Both fetchers are resumable — `fetch_tiger_blocks.sh` skips states it already
has, `fetch_pl_blocks.py` caches each county separately — so an interrupted run
picks up where it stopped.

The standard-geography crosswalk is a separate pull:

```bash
national/blocks/scripts/fetch_baf.sh "$RAW/baf" \
        national/blocks/us_blocks_2020_baf.csv.gz                  # ~3 min
```

It folds the Census 2020 Block Assignment Files into one national block →
place / VTD / CD (116th) / SLDU / SLDL / unified school district / AIANNH
crosswalk, 8,174,955 rows, for rolling blocks up to standard geographies
without touching geometry. Join it to the spine on `GEOID20`.

---

## Using it

`scripts/rollup.py` aggregates the spine to any geography defined by a block
assignment file — every numeric column summed, block counts included, and
unassigned blocks reported rather than dropped.

```bash
python3 national/blocks/scripts/rollup.py \
    national/blocks/us_blocks_2020.csv.gz \
    dra-data/2022-2026/congress/TX-2026-Congressional-block-assignments.csv \
    tx2026-districts.csv --state TX
```

```
668,757 block assignments -> 38 target areas
matched 668,757 blocks into 38 areas

  CD     POP20    dev%  BVAP%  HVAP%  NHWVAP%
   1   766,987  +0.00%  17.7%  14.3%    63.1%
   2   766,987  +0.00%  11.0%  25.8%    52.7%
  ...
total 29,145,505 across 38 districts, ideal 766,987
```

The assignment file can be anything with a `GEOID20` column and a target column
(`--key` / `--to` name them). For a geography defined by a boundary rather than
an assignment list — a DMA polygon, a service area — assign blocks first by
point-in-polygon on `INTPTLAT` / `INTPTLON`, then roll up the result.

Nielsen DMAs are built from whole counties, so a DMA equivalency only needs a
county → DMA list joined on `COUNTYFP`; going to blocks matters when a market
definition splits a county.
