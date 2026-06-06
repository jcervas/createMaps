#!/bin/bash
# compactness.sh
# Calculates Polsby-Popper compactness for every district in every plan
# under mid-decade-redistricting/mid-decade/, then rank-orders results.
#
# Output: compactness_results.csv  (one row per district)
#         compactness_by_plan.csv  (plan-level summary)
#
# Requires: mapshaper, python3

set -euo pipefail

PLANS_DIR="../mid-decade-redistricting/mid-decade"
OUTFILE="compactness_results.csv"
TMPDIR_LOCAL=$(mktemp -d)

# Header
echo "plan,district_id,district_name,polsby_popper" > "$OUTFILE"

for geojson in "$PLANS_DIR"/*.geojson; do
  plan=$(basename "$geojson" .geojson)
  tmpcsv="$TMPDIR_LOCAL/${plan}.csv"

  mapshaper "$geojson" \
    -each 'polsby_popper = (4 * Math.PI * this.area) / Math.pow(this.perimeter, 2)' \
    -o "$tmpcsv" format=csv 2>/dev/null

  # Append rows with plan name prepended (skip header line)
  tail -n +2 "$tmpcsv" | awk -v plan="$plan" -F',' \
    'BEGIN{OFS=","} {print plan, $1, $2, $NF}' >> "$OUTFILE"
done

rm -rf "$TMPDIR_LOCAL"

echo "Raw results written to: $OUTFILE"
echo ""

# Sort and summarise with python3
python3 - "$OUTFILE" <<'PYEOF'
import csv, sys
from collections import defaultdict

infile = sys.argv[1]

rows = []
with open(infile) as f:
    reader = csv.DictReader(f)
    for r in reader:
        try:
            pp = float(r['polsby_popper'])
        except (ValueError, KeyError):
            pp = None
        rows.append({
            'plan':          r['plan'],
            'district_id':   r['district_id'],
            'district_name': r['district_name'],
            'pp':            pp,
        })

# --- Keep only the most recent plan per state ---
import re
from collections import defaultdict

def plan_state_year(plan):
    m = re.match(r'^([A-Z]+)-(\d{4})', plan)
    if m:
        return m.group(1), int(m.group(2))
    return None, 0

# Find the most recent year for each state
latest_year = defaultdict(int)
for r in rows:
    state, year = plan_state_year(r['plan'])
    if state and year > latest_year[state]:
        latest_year[state] = year

# Keep only districts from the latest plan for each state
def is_latest(plan):
    state, year = plan_state_year(plan)
    return state is not None and year == latest_year[state]

# --- District-level ranking (ascending PP = least compact first) ---
valid = [r for r in rows if r['pp'] is not None and is_latest(r['plan'])]
ranked = sorted(valid, key=lambda r: r['pp'])

print("=" * 70)
print(f"{'MOST ILL-COMPACT DISTRICTS (ranked, lowest Polsby-Popper first)'}")
print("=" * 70)
print(f"{'Rank':<6} {'Plan':<30} {'District':<12} {'Polsby-Popper':>14}")
print("-" * 70)
for i, r in enumerate(ranked[:40], 1):
    name = r['district_name'] if r['district_name'] != r['district_id'] else ''
    label = f"{r['district_id']} {name}".strip()
    print(f"{i:<6} {r['plan']:<30} {label:<12} {r['pp']:>14.4f}")

# --- Plan-level summary ---
plan_data = defaultdict(list)
for r in valid:
    plan_data[r['plan']].append(r['pp'])

plan_summary = []
for plan, scores in plan_data.items():
    plan_summary.append({
        'plan':     plan,
        'n':        len(scores),
        'mean_pp':  sum(scores) / len(scores),
        'min_pp':   min(scores),
        'max_pp':   max(scores),
    })
plan_summary.sort(key=lambda r: r['mean_pp'])

print("\n" + "=" * 70)
print("PLAN SUMMARY (ranked by mean Polsby-Popper, lowest = least compact)")
print("=" * 70)
print(f"{'Plan':<35} {'N':>4} {'Mean PP':>9} {'Min PP':>9} {'Max PP':>9}")
print("-" * 70)
for r in plan_summary:
    print(f"{r['plan']:<35} {r['n']:>4} {r['mean_pp']:>9.4f} {r['min_pp']:>9.4f} {r['max_pp']:>9.4f}")

# --- Write plan summary CSV ---
plan_csv = infile.replace('.csv', '_by_plan.csv')
with open(plan_csv, 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=['plan','n_districts','mean_pp','min_pp','max_pp'])
    writer.writeheader()
    for r in plan_summary:
        writer.writerow({'plan': r['plan'], 'n_districts': r['n'],
                         'mean_pp': round(r['mean_pp'], 4),
                         'min_pp':  round(r['min_pp'],  4),
                         'max_pp':  round(r['max_pp'],  4)})

print(f"\nPlan summary written to: {plan_csv}")

# --- Write top-25 list for SVG generation ---
top25_csv = infile.replace('.csv', '_top25.csv')
with open(top25_csv, 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=['rank','plan','district_id','pp'])
    writer.writeheader()
    for i, r in enumerate(ranked[:25], 1):
        writer.writerow({'rank': i, 'plan': r['plan'],
                         'district_id': r['district_id'],
                         'pp': round(r['pp'], 4)})
print(f"Top-25 list written to: {top25_csv}")
PYEOF

# ── Generate SVGs for the 25 most ill-compact districts ──────────────────────
# Return EPSG code for a given state abbreviation
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

SVG_DIR="compactness_svgs"
mkdir -p "$SVG_DIR"

echo ""
echo "Generating SVGs for top-25 most ill-compact districts..."

TOP25_CSV="compactness_results_top25.csv"

# Skip header row
tail -n +2 "$TOP25_CSV" | while IFS=',' read -r rank plan district_id pp; do
  # Extract state abbreviation: first field before the first '-'
  state=$(echo "$plan" | cut -d'-' -f1)
  epsg=$(state_epsg "$state")

  if [[ -z "$epsg" ]]; then
    echo "  [SKIP] rank $rank — no EPSG for state '$state' (plan: $plan)"
    continue
  fi

  geojson="$PLANS_DIR/${plan}.geojson"
  if [[ ! -f "$geojson" ]]; then
    echo "  [SKIP] rank $rank — file not found: $geojson"
    continue
  fi

  # Sanitise district_id for use in filename (strip spaces/quotes)
  safe_id=$(echo "$district_id" | tr -d ' "')
  outsvg="${SVG_DIR}/rank${rank}_${plan}_district${safe_id}.svg"

  mapshaper "$geojson" name=district \
    -filter "id == \"${district_id}\"" \
    -i "../us-urban.json" name=urban \
    -proj crs=epsg:${epsg} target='*' \
    -clip source=district target=urban \
    -style fill='rgba(0,0,0,0.1)' stroke='none' target=urban \
    -style fill='rgba(0,0,0,0.2)' stroke='rgba(0,0,0,0.8)' stroke-width=1 target=district \
    -o "$outsvg" format=svg target='*' 2>/dev/null \
  && echo "  [OK]   rank $rank — ${plan} district ${district_id} (PP=${pp}) → $(basename "$outsvg")" \
  || echo "  [FAIL] rank $rank — ${plan} district ${district_id}"

done

echo ""
echo "SVGs written to: $SVG_DIR/"


bash compactness_grid.sh
