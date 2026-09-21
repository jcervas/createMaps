#!/usr/bin/env python3
"""Join the TIGER block spine to the PL 94-171 demographics, one state at a time.

    usage: merge_spine.py <tiger_raw_dir> <pl_raw_dir> <out.csv.gz>

TIGER supplies geography (parent codes, land/water area, internal point, urban
flag); PL supplies the counts. Where the two overlap -- total population and
total housing units -- the merge asserts they agree rather than carrying both,
so a mismatch surfaces as an error instead of a silently duplicated column.
"""
import csv
import gzip
import pathlib
import sys

FIPS_POSTAL = {
    "01": "AL", "02": "AK", "04": "AZ", "05": "AR", "06": "CA", "08": "CO", "09": "CT",
    "10": "DE", "11": "DC", "12": "FL", "13": "GA", "15": "HI", "16": "ID", "17": "IL",
    "18": "IN", "19": "IA", "20": "KS", "21": "KY", "22": "LA", "23": "ME", "24": "MD",
    "25": "MA", "26": "MI", "27": "MN", "28": "MS", "29": "MO", "30": "MT", "31": "NE",
    "32": "NV", "33": "NH", "34": "NJ", "35": "NM", "36": "NY", "37": "NC", "38": "ND",
    "39": "OH", "40": "OK", "41": "OR", "42": "PA", "44": "RI", "45": "SC", "46": "SD",
    "47": "TN", "48": "TX", "49": "UT", "50": "VT", "51": "VA", "53": "WA", "54": "WV",
    "55": "WI", "56": "WY", "60": "AS", "66": "GU", "69": "MP", "72": "PR", "78": "VI",
}

GEO_COLS = ["GEOID20", "ST", "STATEFP", "COUNTYFP", "TRACT", "BLKGRP", "BLOCKCE"]
TIGER_COLS = ["POP20", "HOUSING20", "ALAND20", "AWATER20",
              "INTPTLAT", "INTPTLON", "UR20", "UACE20", "FUNCSTAT20"]

# PL columns that duplicate something already present: P2/P4 totals restate the
# P1/P3 totals, and POP_TOTAL / HU_TOTAL restate TIGER's POP20 / HOUSING20.
PL_DROP = {"POP_TOTAL", "POP_TOTAL_P2", "VAP_TOTAL_P4", "HU_TOTAL"}


def tiger_index(path):
    """GEOID20 -> the TIGER fields, keyed for a streaming join."""
    out = {}
    with open(path, newline="") as fh:
        rdr = csv.reader(fh)
        hdr = next(rdr)
        i = {n: k for k, n in enumerate(hdr)}
        for r in rdr:
            out[r[i["GEOID20"]]] = (
                r[i["POP20"]], r[i["HOUSING20"]], r[i["ALAND20"]], r[i["AWATER20"]],
                f'{float(r[i["INTPTLAT20"]]):.7f}', f'{float(r[i["INTPTLON20"]]):.7f}',
                r[i["UR20"]], r[i["UACE20"]], r[i["FUNCSTAT20"]],
            )
    return out


def main():
    tiger_dir, pl_dir, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), sys.argv[3]

    pl_hdr = None
    for p in sorted(pl_dir.glob("*.csv.gz")):
        with gzip.open(p, "rt") as fh:
            pl_hdr = next(csv.reader(fh))
        break
    if pl_hdr is None:
        sys.exit(f"no PL files in {pl_dir}")
    pl_keep = [c for c in pl_hdr[1:] if c not in PL_DROP]
    pl_pos = {c: pl_hdr.index(c) for c in pl_hdr}

    totals = {"rows": 0, "pop": 0, "pop_mismatch": 0, "hu_mismatch": 0, "no_pl": 0}
    with gzip.open(out, "wt", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(GEO_COLS + TIGER_COLS + pl_keep)
        for tpath in sorted(tiger_dir.glob("*.csv")):
            st = tpath.stem
            tiger = tiger_index(tpath)
            pl = {}
            plpath = pl_dir / f"{st}.csv.gz"
            if plpath.exists():
                with gzip.open(plpath, "rt", newline="") as g:
                    rdr = csv.reader(g)
                    next(rdr)
                    for r in rdr:
                        pl[r[0]] = r
            blank = [""] * len(pl_keep)
            for geoid in sorted(tiger):
                t = tiger[geoid]
                rec = pl.get(geoid)
                if rec is None:
                    totals["no_pl"] += 1
                    vals = blank
                else:
                    if rec[pl_pos["POP_TOTAL"]] != t[0]:
                        totals["pop_mismatch"] += 1
                    if rec[pl_pos["HU_TOTAL"]] != t[1]:
                        totals["hu_mismatch"] += 1
                    vals = [rec[pl_pos[c]] for c in pl_keep]
                w.writerow([
                    geoid, FIPS_POSTAL.get(geoid[:2], ""), geoid[:2], geoid[:5],
                    geoid[:11], geoid[:12], geoid[11:15], *t, *vals,
                ])
                totals["rows"] += 1
                totals["pop"] += int(t[0])
            print(f"ok   {st} {FIPS_POSTAL.get(st,'??')}  {len(tiger)} blocks"
                  f"{'  (no PL data)' if not pl else ''}", file=sys.stderr)

    print(f"\nrows          {totals['rows']:,}", file=sys.stderr)
    print(f"population    {totals['pop']:,}", file=sys.stderr)
    print(f"blocks w/o PL {totals['no_pl']:,}", file=sys.stderr)
    print(f"POP20 vs PL total mismatches     {totals['pop_mismatch']:,}", file=sys.stderr)
    print(f"HOUSING20 vs PL total mismatches {totals['hu_mismatch']:,}", file=sys.stderr)


if __name__ == "__main__":
    main()
