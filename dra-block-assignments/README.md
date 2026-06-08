# DRA Official Maps — Block Assignment Files

Block assignment CSVs for all **Official Maps** on
[Dave's Redistricting App](https://davesredistricting.org) (DRA).
Each file maps every Census 2020 block (GEOID20) to a district number for a
given state plan.

Downloaded June 2026 for **The Redistricting Network** project at Carnegie
Mellon University.

---

## Folder structure

Files are organized by redistricting era and chamber:

```
116th-118th/
  congress/         Congressional maps in use before the 2020-census redistricting
                    (116th Congress maps, plus NC 118th court-ordered plan)
2018/
  lower/            State house maps drawn for the 2018–2020 election cycle
  upper/            State senate maps drawn for the 2018–2020 election cycle
2020/
  congress/         Post-2020-census congressional redistricting plans
  lower/            Post-2020-census state house plans
  upper/            Post-2020-census state senate plans
  legislature/      Combined-chamber plans (e.g. NE unicameral, AZ joint)
2022-2026/
  congress/         Congressional maps used in 2022–2026 elections
  lower/            State house maps used in 2022–2026 elections
  upper/            State senate maps used in 2022–2026 elections
  legislature/      Combined-chamber plans
  council/          DC Council (non-state)
other/
  council/          Miscellaneous (DC 2012 Council)
scripts/            Automation scripts (see below)
dra_maps_lookup.csv Cross-reference of all plans: name, DRA ID, state, type,
                    year, district count, last-modified date
```

---

## File naming

Every CSV uses exactly the name shown in DRA's UI:

```
{STATE} {YEAR/ERA} {CHAMBER}.csv
```

Examples:
- `NC 2022 Congressional.csv`
- `TX 2020 State House.csv`
- `CA 116th Congressional.csv`

---

## CSV format

Each file is a two-column block assignment file:

| Column | Description |
|---|---|
| `Id` or `GEOID20` | 15-digit Census 2020 block GEOID |
| `District` | District number assigned to that block |

Row count equals the number of Census 2020 blocks in the state
(typically 100 k – 700 k rows).

---

## Lookup file

`dra_maps_lookup.csv` contains one row per plan:

| Column | Description |
|---|---|
| `name` | Plan title (matches filename minus `.csv`) |
| `id` | DRA internal UUID |
| `state` | Two-letter state code |
| `planType` | `congress` / `lower` / `upper` / `legislature` |
| `year` | Election year the plan was drawn for |
| `nDistricts` | Number of districts |
| `modified` | Last-modified date on DRA |
| `filename` | Exact filename in this folder |

---

## How to reproduce

### Requirements

- Python 3.8+
- Google Chrome with the **Claude in Chrome** MCP extension (or any way to
  run JavaScript in the DRA tab)
- A DRA account logged in to `davesredistricting.org`

### Steps

**1. Start the local receiver server**

```bash
python3 scripts/dra_server.py
```

This listens on `localhost:9001` and saves each CSV as it arrives.
Leave it running in a terminal throughout the download.

**2. Open DRA in Chrome**

Navigate to the Official Maps list:

```
https://davesredistricting.org/maps#list::Official-Maps
```

Make sure you are logged in (the Export button must be available on each map).

**3. Paste the automation script into the browser console**

Open DevTools → Console, paste the contents of `scripts/dra_automation.js`,
then run:

```js
runV3(0)      // download all plans from the beginning
// or
runV3(86)     // resume from index 86 after a crash
```

**4. Monitor progress**

```js
({
  index:  window._dra3.index,
  saved:  window._dra3.saved.length,
  errors: window._dra3.errors.length,
  done:   window._dra3.done
})
```

To stop early: `window._STOP = true`

**5. Handle errors / retry**

After the run completes, check `window._dra3.errors`. For each failed plan,
navigate manually or re-run `runV3` starting from that plan's index.
Known persistent failures:

| Plan | Reason |
|---|---|
| HI maps | DRA server does not serve HI block data |
| Duplicate 116th entries | Some plans appear twice in `_state_plans.json` with the same ID |

**6. Organize into folders**

Once all CSVs are saved to the root of this folder, run:

```bash
python3 scripts/organize.py
```

---

## Technical notes

### Why a local server?

DRA generates block assignment CSVs entirely client-side using
`blockMappingAsString()` inside the React app bundle. The files are offered
via a `blob:` URL anchor tag click — there is no server endpoint to call
directly. The automation intercepts `document.createElement('a')` calls at
runtime to capture the CSV text before the browser triggers a download, then
POSTs it to the local Python server, which saves it with the correct name.

### Authentication

Block assignment exports require a logged-in DRA session. The automation runs
inside the browser tab where the user is already authenticated, so no cookie
extraction or token management is needed.

### Load detection

The automation waits for three conditions before attempting an export:
1. No *"Retrieving N data files…"* spinner is present
2. The Export toolbar button is visible at the top of the page
3. At least one statistics table cell shows a non-zero population value

This avoids exporting before the block-level data has finished loading.

---

## Coverage

| Era | Plans | Notes |
|---|---|---|
| 116th–118th Congressional | 43 | All 50 states + NC court map |
| 2018 State Legislature | 94 | 48 lower + 46 upper |
| 2020 Redistricting | 137 | 43 congress + 44 lower + 45 upper + 5 legislature |
| 2022–2026 Election Cycle | 167 | 57 congress + 54 lower + 53 upper + 5 legis + 1 council |
| Other | 1 | DC 2012 Council |
| **Total** | **442** | |
