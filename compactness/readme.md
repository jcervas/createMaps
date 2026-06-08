# District Compactness Analysis

Measures the geometric compactness of U.S. congressional districts across mid-decade redistricting plans, ranks them from least to most compact using two complementary measures, exports individual SVG maps for the worst offenders, and assembles a 5×5 PNG summary grid.

---

## Overview

Compactness is a standard criterion in redistricting law and reform. A perfectly compact district (a circle) scores 1.0 on both measures; a highly contorted district scores near 0. This pipeline computes two measures that capture different aspects of ill-compactness:

### Polsby-Popper

> PP = (4π · Area) / Perimeter²

Penalizes **jagged or notched borders** — any deviation from a smooth outline inflates the perimeter relative to the area. Computed by mapshaper using planar area and perimeter after state-plane projection.

### Reock

> Reock = Area / Area of minimum bounding circle

Penalizes **elongated shapes** — a district that stretches far from its center will be poorly covered by its smallest enclosing circle. Computed via Shapely's exact `minimum_bounding_circle()`.

### Why both?

PP and Reock are correlated (~0.6–0.7 in the literature) but measure genuinely different things. A district can score poorly on one and fine on the other:

- A district with smooth but elongated boundaries scores low on Reock, high on PP
- A district that is compact in shape but deeply notched scores low on PP, high on Reock

Averaging the raw scores is misleading because PP tends to produce lower absolute values than Reock, making it the dominant factor in any simple mean. Instead, this pipeline ranks districts separately by each measure and combines them as an **average of ranks** — a standard rank aggregation technique that is scale-free and robust to distributional differences between measures.

> Combined rank = (PP rank + Reock rank) / 2

Districts are sorted by this combined rank ascending (lower = more ill-compact). Where two districts tie on combined rank, the average of their raw scores is used as a tiebreaker.

---

## Repository Structure

```
compactness/
├── compactness.sh                    # Main pipeline: calculate → rank → export SVGs → build grid
├── compactness_grid.sh               # Standalone: rasterize SVGs and assemble 5×5 PNG
├── compactness_results.csv           # All districts × all plans (raw PP + Reock scores)
├── compactness_results_by_plan.csv   # Plan-level summary (mean PP, Reock, avg; latest plans only)
├── compactness_results_top25.csv     # Top-25 most ill-compact districts by combined rank
├── compactness_grid.png              # 5×5 PNG grid of the 25 worst districts
└── compactness_svgs/                 # Individual SVGs, one per top-25 district
    ├── rank1_LA-2026_district2.svg
    ├── rank2_CA-2026_district19.svg
    └── ...

../mid-decade-redistricting/mid-decade/   # Input GeoJSON plans (one per plan)
../us-urban.json                          # U.S. urban areas (shown as grey fill in SVGs)
```

---

## Requirements

| Tool | Purpose | Install |
|------|---------|---------|
| `mapshaper` ≥ 0.7 | Polsby-Popper calculation, projection, SVG export | `npm install -g mapshaper` |
| `python3` + `shapely` | Reock (minimum bounding circle), ranking, CSV output | `pip install shapely` |
| `python3` + `Pillow` | PNG grid assembly | `pip install Pillow` |
| `qlmanage` | SVG → PNG rasterization (macOS built-in) | — |

---

## Usage

### Full pipeline (calculate + SVGs + grid)

Run from inside the `compactness/` directory:

```bash
cd /path/to/createMaps/compactness
bash compactness.sh
```

This will:
1. Loop over every `.geojson` in `../mid-decade-redistricting/mid-decade/`
2. Compute Polsby-Popper for each district via mapshaper (after state-plane projection)
3. Compute Reock for each district via Shapely's minimum bounding circle
4. Merge scores, filter to the most recent plan per state, and rank by average of ranks
5. Print district and plan-level tables to stdout
6. Write `compactness_results.csv`, `compactness_results_by_plan.csv`, and `compactness_results_top25.csv`
7. Export 25 SVGs to `compactness_svgs/`, each projected into the correct state plane CRS and overlaid with urban areas
8. Call `compactness_grid.sh` to produce `compactness_grid.png`

### Grid only (if SVGs already exist)

```bash
bash compactness_grid.sh
```

---

## Input Data

**District plans** (`../mid-decade-redistricting/mid-decade/*.geojson`)

Each file is a GeoJSON FeatureCollection of congressional district polygons. File names follow the pattern `{STATE}-{YEAR}.geojson` (e.g. `CA-2026.geojson`, `LA-2026.geojson`). Required properties per feature:

| Property | Description |
|----------|-------------|
| `id` | District number (used for filtering and labelling) |
| `NAME` | District name |

**Urban areas** (`../us-urban.json`)

U.S. Census urbanized areas, clipped to each district and rendered as a grey fill layer in the SVGs to provide geographic context.

---

## Output Files

### `compactness_results.csv`
One row per district across all plans.

| Column | Description |
|--------|-------------|
| `plan` | Plan name (e.g. `CA-2026`) |
| `district_id` | District number |
| `district_name` | District name |
| `polsby_popper` | Polsby-Popper score (0–1; lower = less compact) |
| `reock` | Reock score (0–1; lower = less compact) |

### `compactness_results_by_plan.csv`
One row per plan (latest plans only), ranked by mean average score ascending.

| Column | Description |
|--------|-------------|
| `plan` | Plan name |
| `n_districts` | Number of districts |
| `mean_pp` | Mean Polsby-Popper |
| `mean_reock` | Mean Reock |
| `mean_avg` | Mean of (PP + Reock) / 2 |
| `min_pp` | Lowest Polsby-Popper in plan |
| `min_reock` | Lowest Reock in plan |

### `compactness_results_top25.csv`
The 25 most ill-compact districts from the latest plan per state, ranked by average of ranks.

| Column | Description |
|--------|-------------|
| `rank` | Combined rank (1 = most ill-compact) |
| `plan` | Plan name |
| `district_id` | District number |
| `polsby_popper` | Polsby-Popper score |
| `reock` | Reock score |
| `avg_rank` | Average of PP rank and Reock rank |

### `compactness_svgs/rank{N}_{PLAN}_district{ID}.svg`
One SVG per top-25 district. Each map shows:
- **Grey fill** — urban areas clipped to the district boundary
- **Dark fill + black stroke** — the district polygon itself
- Projected into the appropriate state plane CRS (NAD83)
- Named and ordered by combined rank

### `compactness_grid.png`
5×5 PNG grid (~2100×2400 px at 150 dpi) of the 25 worst districts, each cell labelled with rank, plan, district number, and both PP and Reock scores.

---

## Projections

Each SVG is reprojected from WGS84 into the state's NAD83 State Plane CRS before export, so shape proportions are accurate. Polsby-Popper is also computed in this projection. The EPSG codes used:

| State | EPSG | State | EPSG | State | EPSG |
|-------|------|-------|------|-------|------|
| AL | 2759 | LA | 2800 | OH | 2834 |
| AK | 3338 | ME | 2802 | OK | 2836 |
| AZ | 2762 | MD | 2804 | OR | 2838 |
| AR | 2764 | MA | 2805 | PA | 3362 |
| CA | 3311 | MI | 2808 | RI | 2840 |
| CO | 2773 | MN | 2811 | SC | 3360 |
| CT | 2775 | MS | 2813 | SD | 2841 |
| DE | 2776 | MO | 2816 | TN | 2843 |
| FL | 2777 | MT | 2818 | TX | 2845 |
| GA | 2780 | NE | 2819 | UT | 2850 |
| HI | 2784 | NV | 2821 | VT | 2852 |
| ID | 2788 | NH | 2823 | VA | 2853 |
| IL | 2790 | NJ | 2824 | WA | 2855 |
| IN | 2792 | NM | 2826 | WV | 2857 |
| IA | 2794 | NY | 2829 | WI | 2860 |
| KS | 2796 | NC | 3358 | WY | 2863 |
| KY | 2798 | ND | 2832 | | |

---

## Notes

- **Most-recent-plan filtering** — When multiple plans exist for a state (e.g. `LA-2022`, `LA-2024`, `LA-2026`), only districts from the latest year are included in the top-25 ranking and SVG export. All plans are retained in `compactness_results.csv`.
- **Why average of ranks, not average of scores** — PP scores tend to be lower in absolute terms than Reock scores, so a simple mean would effectively weight PP more heavily. Rank aggregation is scale-free: each measure contributes equally regardless of its distribution.
- **Reock and projected geometry** — Reock is computed on the unprojected WGS84 geometry using Shapely. For consistency, Polsby-Popper is computed on the state-plane projected geometry via mapshaper, where area/perimeter ratios are more accurate.
- **macOS bash compatibility** — `declare -A` (associative arrays) requires bash ≥ 4. Because macOS ships bash 3.2, the EPSG lookup uses a `case` statement instead.
- **SVG transparency** — mapshaper SVGs use RGBA fills. The `qlmanage` rasterizer preserves transparency; the grid script composites each cell onto a white background before assembly.
