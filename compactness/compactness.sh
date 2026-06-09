#!/bin/bash
# compactness.sh
# Calculates Polsby-Popper and Reock compactness for every district in every
# plan under mid-decade-redistricting/mid-decade/, then rank-orders results.
#
# Both measures are computed in WGS84 (mapshaper uses geodesic area/perimeter;
# Shapely uses planar geometry on geographic coordinates — differences vs. a
# projected CRS are < 0.15% for congressional districts).
#
# Polsby-Popper: (4π·Area) / Perimeter²   — penalizes jagged/notched borders
# Reock:         Area / MinBoundingCircle  — penalizes elongated shapes
# Combined rank: average of PP rank + Reock rank (robust to scale differences)
#
# Output: compactness_results.csv          (one row per district, all plans)
#         compactness_results_by_plan.csv  (plan-level summary, latest plans)
#         compactness_results_ranked.csv   (all districts ranked, latest plans)
#
# Requires: mapshaper, python3 + shapely + Pillow

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
PLANS_DIR="../Congressional-Plans"
PP_CSV="compactness_pp.csv"
OUTFILE="compactness_results.csv"
SVG_DIR="compactness_svgs"

# Maximum number of SVGs to generate and rows in the grid.
# Set to "all" to process every ranked district (may take several minutes).
TOP_N=all

# ── Step 1: Polsby-Popper via mapshaper (WGS84 geodesic) ─────────────────────
echo "Calculating Polsby-Popper (WGS84)..."
echo "plan,district_id,district_name,polsby_popper" > "$PP_CSV"

TMPDIR_LOCAL=$(mktemp -d)
for geojson in "$PLANS_DIR"/*.geojson; do
  plan=$(basename "$geojson" .geojson)
  tmpcsv="$TMPDIR_LOCAL/${plan}.csv"

  mapshaper "$geojson" \
    -each 'polsby_popper = (4 * Math.PI * this.area) / Math.pow(this.perimeter, 2)' \
    -o "$tmpcsv" format=csv 2>/dev/null

  # Prepend plan name; PP is the last column
  tail -n +2 "$tmpcsv" | awk -v plan="$plan" -F',' \
    'BEGIN{OFS=","} {print plan, $1, $2, $NF}' >> "$PP_CSV"
done
rm -rf "$TMPDIR_LOCAL"

# ── Step 2: Reock via shapely + merge + rank all districts ───────────────────
echo "Calculating Reock (WGS84) + merging + ranking..."

python3 - "$PLANS_DIR" "$PP_CSV" "$OUTFILE" "$TOP_N" <<'PYEOF'
import sys, os, json, csv, re
from collections import defaultdict
from shapely.geometry import shape
from shapely import minimum_bounding_circle

plans_dir = sys.argv[1]
pp_csv    = sys.argv[2]
out_csv   = sys.argv[3]
top_n_arg = sys.argv[4]   # integer string or "all"

# --- Load PP scores ---
pp_lookup = {}
with open(pp_csv) as f:
    for r in csv.DictReader(f):
        pp_lookup[(r['plan'], r['district_id'])] = r

# --- Calculate Reock for every district ---
reock_lookup = {}
for fname in sorted(os.listdir(plans_dir)):
    if not fname.endswith('.geojson'):
        continue
    plan = fname[:-8]
    with open(os.path.join(plans_dir, fname)) as f:
        gj = json.load(f)
    for feat in gj['features']:
        did = str(feat['properties'].get('id', ''))
        try:
            geom = shape(feat['geometry'])
            mbc  = minimum_bounding_circle(geom)
            reock = geom.area / mbc.area if mbc.area > 0 else None
        except Exception:
            reock = None
        reock_lookup[(plan, did)] = reock

# --- Merge ---
rows = []
for (plan, did), pp_row in pp_lookup.items():
    try:
        pp = float(pp_row['polsby_popper'])
    except (ValueError, KeyError):
        pp = None
    rows.append({
        'plan':          plan,
        'district_id':   did,
        'district_name': pp_row.get('district_name', did),
        'polsby_popper': pp,
        'reock':         reock_lookup.get((plan, did)),
    })

# --- Write full raw results ---
with open(out_csv, 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=['plan','district_id','district_name',
                                           'polsby_popper','reock'])
    writer.writeheader()
    for r in rows:
        writer.writerow({
            'plan':          r['plan'],
            'district_id':   r['district_id'],
            'district_name': r['district_name'],
            'polsby_popper': round(r['polsby_popper'], 4) if r['polsby_popper'] is not None else '',
            'reock':         round(r['reock'], 4)         if r['reock']         is not None else '',
        })
print(f"Raw results written to: {out_csv}  ({len(rows)} districts)")

# --- Filter to most recent plan per state ---
def plan_state_year(plan):
    m = re.match(r'^([A-Z]+)-(\d{4})', plan)
    return (m.group(1), int(m.group(2))) if m else (None, 0)

latest_year = defaultdict(int)
for r in rows:
    state, year = plan_state_year(r['plan'])
    if state and year > latest_year[state]:
        latest_year[state] = year

def is_latest(plan):
    state, year = plan_state_year(plan)
    return state is not None and year == latest_year[state]

valid = [r for r in rows
         if r['polsby_popper'] is not None
         and r['reock'] is not None
         and is_latest(r['plan'])]

# --- Rank by each measure, then combine ---
pp_sorted    = sorted(valid, key=lambda r: r['polsby_popper'])
reock_sorted = sorted(valid, key=lambda r: r['reock'])

pp_rank    = {id(r): i+1 for i, r in enumerate(pp_sorted)}
reock_rank = {id(r): i+1 for i, r in enumerate(reock_sorted)}

for r in valid:
    r['pp_rank']    = pp_rank[id(r)]
    r['reock_rank'] = reock_rank[id(r)]
    r['avg_rank']   = (r['pp_rank'] + r['reock_rank']) / 2
    r['avg_score']  = (r['polsby_popper'] + r['reock']) / 2

ranked = sorted(valid, key=lambda r: (r['avg_rank'], r['avg_score']))

# Determine how many to export
top_n = len(ranked) if top_n_arg.lower() == 'all' else int(top_n_arg)
top_n = min(top_n, len(ranked))

# --- Print district table (top 40 or all if fewer) ---
display_n = min(top_n, 40)
print()
print("=" * 82)
print(f"MOST ILL-COMPACT DISTRICTS — ranked by average of PP rank + Reock rank")
print(f"(most recent plan per state; {len(ranked)} total districts; showing top {display_n})")
print("=" * 82)
print(f"{'Rk':<5} {'Plan':<28} {'Dist':<6} {'PP':>7} {'PPRk':>5} {'Reock':>7} {'ReRk':>5} {'AvgRk':>6}")
print("-" * 82)
for i, r in enumerate(ranked[:display_n], 1):
    print(f"{i:<5} {r['plan']:<28} {r['district_id']:<6} "
          f"{r['polsby_popper']:>7.4f} {r['pp_rank']:>5} "
          f"{r['reock']:>7.4f} {r['reock_rank']:>5} "
          f"{r['avg_rank']:>6.1f}")

# --- Plan-level summary ---
plan_data = defaultdict(list)
for r in valid:
    plan_data[r['plan']].append(r)

plan_summary = []
for plan, rs in plan_data.items():
    plan_summary.append({
        'plan':       plan,
        'n':          len(rs),
        'mean_pp':    sum(r['polsby_popper'] for r in rs) / len(rs),
        'mean_reock': sum(r['reock']         for r in rs) / len(rs),
        'min_pp':     min(r['polsby_popper'] for r in rs),
        'min_reock':  min(r['reock']         for r in rs),
    })
plan_summary.sort(key=lambda r: (r['mean_pp'] + r['mean_reock']) / 2)

print()
print("=" * 72)
print("PLAN SUMMARY (ranked by mean average score, lowest = least compact)")
print("=" * 72)
print(f"{'Plan':<32} {'N':>4} {'Mean PP':>9} {'Mean Reock':>11} {'Mean Avg':>9}")
print("-" * 72)
for r in plan_summary:
    avg = (r['mean_pp'] + r['mean_reock']) / 2
    print(f"{r['plan']:<32} {r['n']:>4} {r['mean_pp']:>9.4f} "
          f"{r['mean_reock']:>11.4f} {avg:>9.4f}")

# --- Write plan summary CSV ---
plan_csv = out_csv.replace('.csv', '_by_plan.csv')
with open(plan_csv, 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=['plan','n_districts',
                                           'mean_pp','mean_reock','mean_avg',
                                           'min_pp','min_reock'])
    writer.writeheader()
    for r in plan_summary:
        writer.writerow({
            'plan':        r['plan'],
            'n_districts': r['n'],
            'mean_pp':     round(r['mean_pp'],    4),
            'mean_reock':  round(r['mean_reock'], 4),
            'mean_avg':    round((r['mean_pp'] + r['mean_reock']) / 2, 4),
            'min_pp':      round(r['min_pp'],     4),
            'min_reock':   round(r['min_reock'],  4),
        })
print(f"\nPlan summary written to: {plan_csv}")

# --- Write full ranked CSV (all districts from latest plans) ---
ranked_csv = out_csv.replace('.csv', '_ranked.csv')
with open(ranked_csv, 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=['rank','plan','district_id',
                                           'polsby_popper','pp_rank',
                                           'reock','reock_rank','avg_rank'])
    writer.writeheader()
    for i, r in enumerate(ranked, 1):
        writer.writerow({
            'rank':         i,
            'plan':         r['plan'],
            'district_id':  r['district_id'],
            'polsby_popper':round(r['polsby_popper'], 4),
            'pp_rank':      r['pp_rank'],
            'reock':        round(r['reock'],         4),
            'reock_rank':   r['reock_rank'],
            'avg_rank':     round(r['avg_rank'],      1),
        })
print(f"Full ranked list written to: {ranked_csv}  ({len(ranked)} districts)")
print(f"SVGs will be generated for top {top_n} districts.")
PYEOF

# ── Step 3: Generate SVGs ─────────────────────────────────────────────────────
state_epsg() {
  case "$1" in
    AL) echo 2759 ;; AK) echo 3338 ;; AZ) echo 2762 ;; AR) echo 2764 ;;
    CA) echo 3311 ;; CO) echo 2773 ;; CT) echo 2775 ;; DE) echo 2776 ;;
    FL) echo 2777 ;; GA) echo 2780 ;; HI) echo 2784 ;; ID) echo 2788 ;;
    IL) echo 2790 ;; IN) echo 2792 ;; IA) echo 2794 ;; KS) echo 2796 ;;
    KY) echo 2798 ;; LA) echo 2800 ;; ME) echo 2802 ;; MD) echo 2804 ;;
    MA) echo 2805 ;; MI) echo 2808 ;; MN) echo 2811 ;; MS) echo 2813 ;;
    MO) echo 2816 ;; MT) echo 2818 ;; NE) echo 2819 ;; NV) echo 2821 ;;
    NH) echo 2823 ;; NJ) echo 2824 ;; NM) echo 2826 ;; NY) echo 2829 ;;
    NC) echo 3358 ;; ND) echo 2832 ;; OH) echo 2834 ;; OK) echo 2836 ;;
    OR) echo 2838 ;; PA) echo 3362 ;; RI) echo 2840 ;; SC) echo 3360 ;;
    SD) echo 2841 ;; TN) echo 2843 ;; TX) echo 2845 ;; UT) echo 2850 ;;
    VT) echo 2852 ;; VA) echo 2853 ;; WA) echo 2855 ;; WV) echo 2857 ;;
    WI) echo 2860 ;; WY) echo 2863 ;; *) echo "" ;;
  esac
}

mkdir -p "$SVG_DIR"
RANKED_CSV="compactness_results_ranked.csv"

echo ""
if [[ "$TOP_N" == "all" ]]; then
  echo "Generating SVGs for ALL ranked districts..."
else
  echo "Generating SVGs for top $TOP_N districts (set TOP_N=all to do every district)..."
fi

count=0
tail -n +2 "$RANKED_CSV" | while IFS=',' read -r rank plan district_id polsby_popper pp_rank reock reock_rank avg_rank; do
  # Stop after TOP_N rows (unless "all")
  if [[ "$TOP_N" != "all" ]] && [[ "$count" -ge "$TOP_N" ]]; then
    break
  fi
  count=$((count + 1))

  state=$(echo "$plan" | cut -d'-' -f1)
  epsg=$(state_epsg "$state")

  if [[ -z "$epsg" ]]; then
    echo "  [SKIP] rank $rank — no EPSG for state '$state'"
    continue
  fi

  geojson="$PLANS_DIR/${plan}.geojson"
  if [[ ! -f "$geojson" ]]; then
    echo "  [SKIP] rank $rank — file not found: $geojson"
    continue
  fi

  safe_id=$(echo "$district_id" | tr -d ' "')
  outsvg="${SVG_DIR}/rank${rank}_${plan}_district${safe_id}.svg"

  mapshaper "$geojson" name=district \
    -filter "id == \"${district_id}\"" \
    -i "../us_can_roads.json" name=roads \
    -i "../us-urban.json" name=urban \
    -clip source=district target=urban \
    -clip source=district target=roads \
    -proj crs=epsg:${epsg} target='*' \
    -style target=roads stroke="#aaa" stroke-width=0.6 \
    -style fill='rgba(0,0,0,0.1)' stroke='none' target=urban \
    -style fill='rgba(0,0,0,0.2)' stroke='rgba(0,0,0,0.8)' stroke-width=1 target=district \
    -o "$outsvg" format=svg target='*' 2>/dev/null \
  && echo "  [OK]   rank $rank — ${plan} D${district_id} PP=${polsby_popper} Reock=${reock}" \
  || echo "  [FAIL] rank $rank — ${plan} D${district_id}"

done

echo ""
echo "SVGs written to: $SVG_DIR/"

# ── Step 4: Build grid PNG ────────────────────────────────────────────────────
bash compactness_grid.sh
