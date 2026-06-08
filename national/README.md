# Mid-Decade Redistricting — National Congressional Districts

## Output

**`national-cd.geojson`** — All 435 U.S. congressional districts combined into a single GeoJSON, water-clipped to state boundaries.

---

## Reproducing the Build

### Requirements

- Python 3
- [mapshaper](https://github.com/mbloch/mapshaper) (`npm install -g mapshaper`)

### Run

```bash
bash build_national.sh
```

This runs two steps:

---

### Step 1 — Combine per-state files (`build_national.py`)

Reads individual state GeoJSON files from `mid-decade/`, selects the **most recent map year** for each state, renames election fields to reflect the election used, drops style fields, and writes `national-cd-raw.geojson`.

#### State selection (most recent year used)

| State | File used | Map year | Election |
|-------|-----------|----------|----------|
| AK | AK-2022.geojson | 2022 | 2024 Pres |
| AL | AL-2026.geojson | 2026 | 2024 Pres |
| AR | AR-2022-(w 2020 Pres).geojson | 2022 | 2020 Pres |
| AZ | AZ-2022.geojson | 2022 | 2024 Pres |
| CA | CA-2026.geojson | 2026 | 2024 Pres |
| CO | CO-2022.geojson | 2022 | 2024 Pres |
| CT | CT-2022-(w 2020 Pres).geojson | 2022 | 2020 Pres |
| DE | DE-2022.geojson | 2022 | 2024 Pres |
| FL | FL-2026.geojson | 2026 | 2024 Pres |
| GA | GA-2024.geojson | 2024 | 2024 Pres |
| HI | HI-2022.geojson | 2022 | 2024 Pres |
| IA | IA-2022.geojson | 2022 | 2024 Pres |
| ID | ID-2022.geojson | 2022 | 2024 Pres |
| IL | IL-2022.geojson | 2022 | 2024 Pres |
| IN | IN-2022.geojson | 2022 | 2024 Pres |
| KS | KS-2022.geojson | 2022 | 2024 Pres |
| KY | KY-2022.geojson | 2022 | 2024 Pres |
| LA | LA-2026.geojson | 2026 | 2024 Pres |
| MA | MA-2022.geojson | 2022 | 2024 Pres |
| MD | MD-2022.geojson | 2022 | 2024 Pres |
| ME | ME-2022-(w 2020 Pres).geojson | 2022 | 2020 Pres |
| MI | MI-2022-(w 2020 Pres).geojson | 2022 | 2020 Pres |
| MN | MN-2022.geojson | 2022 | 2024 Pres |
| MO | MO-2026.geojson | 2026 | 2024 Pres |
| MS | MS-2022.geojson | 2022 | 2024 Pres |
| MT | MT-2022.geojson | 2022 | 2024 Pres |
| NC | NC-2026.geojson | 2026 | 2024 Pres |
| ND | ND-2022.geojson | 2022 | 2024 Pres |
| NE | NE-2022.geojson | 2022 | 2024 Pres |
| NH | NH-2022.geojson | 2022 | 2024 Pres |
| NJ | NJ-2022(w 2020 Pres).geojson | 2022 | 2020 Pres |
| NM | NM-2022.geojson | 2022 | 2024 Pres |
| NV | NV-2022.geojson | 2022 | 2024 Pres |
| NY | NY-2024.geojson | 2024 | 2024 Pres |
| OH | OH-2026.geojson | 2026 | 2024 Pres |
| OK | OK-2022-(w 2020 Pres).geojson | 2022 | 2020 Pres |
| OR | OR-2022-(w 2020 Pres).geojson | 2022 | 2020 Pres |
| PA | PA-2022-(w 2020 Pres).geojson | 2022 | 2020 Pres |
| RI | RI-2022.geojson | 2022 | 2024 Pres |
| SC | SC-2022.geojson | 2022 | 2024 Pres |
| SD | SD-2022-(w 2020 Pres).geojson | 2022 | 2020 Pres |
| TN | TN-2026.geojson | 2026 | 2024 Pres |
| TX | TX-2026.geojson | 2026 | 2024 Pres |
| UT | UT-2026.geojson | 2026 | 2024 Pres |
| VA | VA-2022.geojson | 2022 | 2024 Pres |
| VT | VT-2022.geojson | 2022 | 2024 Pres |
| WA | WA-2022.geojson | 2022 | 2024 Pres |
| WI | WI-2022.geojson | 2022 | 2024 Pres |
| WV | WV-2022.geojson | 2022 | 2024 Pres |
| WY | WY-2022.geojson | 2022 | 2024 Pres |

> **Note:** Files with `(w 2020 Pres)` in the filename use 2020 Presidential election results. All others use 2024 Presidential results. Fields are named accordingly (`DemPct2024Pres`, `DemPct2020Pres`, etc.). Each district feature will have one pair populated and the other absent.

#### Fields dropped

`color`, `opacity`, `text-size`, `text-color`, `NAME`

---

### Step 2 — Clip water (`build_national.sh`)

Uses `us-state.json` (56 state/territory polygons) as a land mask:

```bash
mapshaper \
  -i national-cd-raw.geojson name=cd \
  -i ../us-state.json name=us-state \
  -dissolve target=us-state \
  -clip target=cd source=us-state \
  -o national-cd.geojson target=cd format=geojson
```

The dissolve collapses state boundaries into a single national land polygon, then clips the congressional districts to remove offshore water areas.

---

## Output Fields

| Field | Type | Description |
|-------|------|-------------|
| `state` | string | Two-letter state abbreviation (e.g., `TX`) |
| `state-district` | string | Zero-padded district ID (e.g., `TX-07`) |
| `year` | integer | Map year (year the district plan took effect) |
| `id` | integer | District number |
| `DemPct2024Pres` | float | Democratic share of 2-party Presidential vote, 2024 |
| `RepPct2024Pres` | float | Republican share of 2-party Presidential vote, 2024 |
| `Margin2024Pres` | float | Dem − Rep margin, 2024 Presidential |
| `DemPct2020Pres` | float | Democratic share of 2-party Presidential vote, 2020 |
| `RepPct2020Pres` | float | Republican share of 2-party Presidential vote, 2020 |
| `Margin2020Pres` | float | Dem − Rep margin, 2020 Presidential |
| `TotalPop` | integer | Total population (2020 Census) |
| `TotalVAP` | integer | Voting-age population (2020 Census) |
| `WhitePct` | float | White (non-Hispanic) share of VAP |
| `BlackPct` | float | Black share of VAP |
| `HispanicPct` | float | Hispanic share of VAP |
| `AsianPct` | float | Asian share of VAP |
| `NativePct` | float | Native American share of VAP |
| `PacificPct` | float | Pacific Islander share of VAP |
| `MinorityPct` | float | Non-white share of VAP |
| `PopDevPct` | float | Population deviation from ideal district size |
