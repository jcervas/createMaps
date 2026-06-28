#!/usr/bin/env python3
"""
normalize_plans.py — canonicalize the per-state plan files in Congressional-Plans/.

Most state GeoJSONs already carry `state`, `state-district`, and `year` (and have
shed the DRA label fields `labelx`/`labely`). A few older exports — e.g. LA-2026 —
were exported without those identity fields and still carry the label fields, so
downstream tools that read the per-state files (build_national.py, compactness.sh)
see NA. This step makes every file uniform:

  - year           <- the year in the filename (e.g. LA-2026.geojson -> 2026)
  - state          <- the state in the filename
  - state-district <- f"{state}-{id:02d}" from the feature id (when missing)
  - drops labelx / labely (DRA label-position hints not used downstream)

Only files that actually change are rewritten, so it's idempotent and doesn't churn
the already-uniform files. Run it before build_national.py / compactness when a new
plan is dropped in.

Usage:  python3 normalize_plans.py   (operates in place on ../Congressional-Plans)
"""
import json, os, re, glob

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "Congressional-Plans")
DROP = ("labelx", "labely")
NAME_RE = re.compile(r"^([A-Z]{2})-(\d{4})")

def main():
    changed_files = 0
    for path in sorted(glob.glob(os.path.join(DATA_DIR, "*.geojson"))):
        m = NAME_RE.match(os.path.basename(path))
        if not m:
            continue
        state, year = m.group(1), int(m.group(2))
        data = json.load(open(path))
        touched = False
        for feat in data.get("features", []):
            p = feat.setdefault("properties", {})
            if p.get("year") != year:
                p["year"] = year; touched = True
            if p.get("state") is None:
                p["state"] = state; touched = True
            if p.get("state-district") is None and p.get("id") is not None:
                p["state-district"] = f"{state}-{int(p['id']):02d}"; touched = True
            for k in DROP:
                if k in p:
                    del p[k]; touched = True
        if touched:
            json.dump(data, open(path, "w"))
            changed_files += 1
            print(f"  normalized {os.path.basename(path)}")
    print(f"{changed_files} file(s) normalized." if changed_files else "All plan files already uniform.")

if __name__ == "__main__":
    main()
