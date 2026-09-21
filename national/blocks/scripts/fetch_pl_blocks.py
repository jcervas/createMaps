#!/usr/bin/env python3
"""Pull 2020 PL 94-171 block-level demographics for the whole country.

    usage: fetch_pl_blocks.py <out_dir> [--jobs N] [--state FIPS ...]

One request per county (block wildcard inside a county), which is the smallest
number of calls the API allows for block geography. Counties that are too large
for a single response are retried tract by tract.

Needs a Census API key: CENSUS_API_KEY in the environment or in ~/.Renviron.
"""
import argparse
import csv
import gzip
import json
import os
import pathlib
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor

API = "https://api.census.gov/data/2020/dec/pl"

# Curated subset of the PL tables: total pop and VAP, each by race and by
# race x Hispanic origin, plus housing occupancy and group quarters. 43
# variables, which keeps each call under the API's 50-variable ceiling.
VARS = [
    "P1_001N", "P1_003N", "P1_004N", "P1_005N", "P1_006N", "P1_007N", "P1_008N", "P1_009N",
    "P2_001N", "P2_002N", "P2_005N", "P2_006N", "P2_007N", "P2_008N", "P2_009N", "P2_010N", "P2_011N",
    "P3_001N", "P3_003N", "P3_004N", "P3_005N", "P3_006N", "P3_007N", "P3_008N", "P3_009N",
    "P4_001N", "P4_002N", "P4_005N", "P4_006N", "P4_007N", "P4_008N", "P4_009N", "P4_010N", "P4_011N",
    "H1_001N", "H1_002N", "H1_003N",
    "P5_001N", "P5_003N", "P5_004N", "P5_005N", "P5_007N", "P5_008N",
]

# Friendlier column names, so the output reads without the PL data dictionary.
RENAME = {
    "P1_001N": "POP_TOTAL",   "P1_003N": "POP_WHITE",   "P1_004N": "POP_BLACK",
    "P1_005N": "POP_AIAN",    "P1_006N": "POP_ASIAN",   "P1_007N": "POP_NHPI",
    "P1_008N": "POP_OTHER",   "P1_009N": "POP_TWOPLUS",
    "P2_001N": "POP_TOTAL_P2", "P2_002N": "POP_HISP",
    "P2_005N": "POP_NH_WHITE", "P2_006N": "POP_NH_BLACK", "P2_007N": "POP_NH_AIAN",
    "P2_008N": "POP_NH_ASIAN", "P2_009N": "POP_NH_NHPI",  "P2_010N": "POP_NH_OTHER",
    "P2_011N": "POP_NH_TWOPLUS",
    "P3_001N": "VAP_TOTAL",   "P3_003N": "VAP_WHITE",   "P3_004N": "VAP_BLACK",
    "P3_005N": "VAP_AIAN",    "P3_006N": "VAP_ASIAN",   "P3_007N": "VAP_NHPI",
    "P3_008N": "VAP_OTHER",   "P3_009N": "VAP_TWOPLUS",
    "P4_001N": "VAP_TOTAL_P4", "P4_002N": "VAP_HISP",
    "P4_005N": "VAP_NH_WHITE", "P4_006N": "VAP_NH_BLACK", "P4_007N": "VAP_NH_AIAN",
    "P4_008N": "VAP_NH_ASIAN", "P4_009N": "VAP_NH_NHPI",  "P4_010N": "VAP_NH_OTHER",
    "P4_011N": "VAP_NH_TWOPLUS",
    "H1_001N": "HU_TOTAL",    "H1_002N": "HU_OCCUPIED",  "H1_003N": "HU_VACANT",
    "P5_001N": "GQ_TOTAL",    "P5_003N": "GQ_CORRECTIONAL", "P5_004N": "GQ_JUVENILE",
    "P5_005N": "GQ_NURSING",  "P5_007N": "GQ_NONINST",   "P5_008N": "GQ_COLLEGE",
}

OUT_COLS = ["GEOID20"] + [RENAME[v] for v in VARS]


def api_key():
    key = os.environ.get("CENSUS_API_KEY")
    if key:
        return key.strip()
    renviron = pathlib.Path.home() / ".Renviron"
    if renviron.exists():
        m = re.search(r"^\s*CENSUS_API_KEY\s*=\s*['\"]?([^'\"\s]+)", renviron.read_text(), re.M)
        if m:
            return m.group(1)
    sys.exit("No Census API key found (set CENSUS_API_KEY or add it to ~/.Renviron)")


def get(params, key, tries=4):
    url = f"{API}?{urllib.parse.urlencode(params)}&key={key}"
    last = None
    for attempt in range(tries):
        try:
            with urllib.request.urlopen(url, timeout=300) as r:
                return json.loads(r.read().decode())
        except (urllib.error.URLError, json.JSONDecodeError, TimeoutError, OSError) as e:
            last = e
            time.sleep(2 ** attempt)
    raise RuntimeError(f"{params!r}: {last}")


def counties(key, states):
    rows = get({"get": "NAME", "for": "county:*"}, key)
    out = [(r[1], r[2]) for r in rows[1:]]
    return sorted(c for c in out if not states or c[0] in states)


def rows_for(state, county, key):
    """All block records in one county, falling back to tract-sized chunks."""
    base = {"get": ",".join(VARS), "for": "block:*"}
    try:
        return get({**base, "in": f"state:{state} county:{county} tract:*"}, key)
    except RuntimeError:
        tracts = get({"get": "NAME", "for": "tract:*", "in": f"state:{state} county:{county}"}, key)
        merged = None
        for t in tracts[1:]:
            chunk = get({**base, "in": f"state:{state} county:{county} tract:{t[3]}"}, key)
            if merged is None:
                merged = chunk
            else:
                merged.extend(chunk[1:])
        return merged or [[]]


def fetch_county(job):
    """Cache one county's blocks to its own file, so a crash resumes cheaply."""
    state, county, cache, key = job
    dst = cache / f"{state}{county}.csv.gz"
    if dst.exists() and dst.stat().st_size > 0:
        return state, county, -1
    data = rows_for(state, county, key)
    n = 0
    tmp = dst.with_suffix(".tmp")
    with gzip.open(tmp, "wt", newline="") as fh:
        w = csv.writer(fh)
        if data and data[0]:
            idx = {name: i for i, name in enumerate(data[0])}
            pos = [idx[v] for v in VARS]
            g = [idx[c] for c in ("state", "county", "tract", "block")]
            for r in data[1:]:
                w.writerow(["".join(r[i] for i in g)] + [r[i] for i in pos])
                n += 1
    tmp.rename(dst)
    return state, county, n


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out_dir")
    ap.add_argument("--jobs", type=int, default=12)
    ap.add_argument("--state", nargs="*", default=[])
    args = ap.parse_args()

    key = api_key()
    out_dir = pathlib.Path(args.out_dir)
    cache = out_dir / "counties"
    cache.mkdir(parents=True, exist_ok=True)
    todo = counties(key, set(args.state))
    print(f"{len(todo)} counties", file=sys.stderr)

    done = 0
    with ThreadPoolExecutor(max_workers=args.jobs) as ex:
        jobs = [(st, co, cache, key) for st, co in todo]
        for state, county, n in ex.map(fetch_county, jobs):
            done += 1
            if done % 100 == 0 or n >= 0:
                print(f"[{done}/{len(todo)}] {state}{county} "
                      f"{'cached' if n < 0 else str(n) + ' blocks'}", file=sys.stderr)

    # Roll the county cache up into one file per state.
    by_state = {}
    for st, co in todo:
        by_state.setdefault(st, []).append(co)
    for state in sorted(by_state):
        dst = out_dir / f"{state}.csv.gz"
        total = 0
        with gzip.open(dst, "wt", newline="") as fh:
            fh.write(",".join(OUT_COLS) + "\n")
            for co in by_state[state]:
                src = cache / f"{state}{co}.csv.gz"
                if not src.exists():
                    print(f"MISSING {state}{co}", file=sys.stderr)
                    continue
                with gzip.open(src, "rt") as g:
                    for line in g:
                        fh.write(line)
                        total += 1
        print(f"ok   {state}  {total} blocks", file=sys.stderr)


if __name__ == "__main__":
    main()
