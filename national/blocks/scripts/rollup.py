#!/usr/bin/env python3
"""Aggregate the national block spine to any geography defined by an equivalency.

    usage: rollup.py <spine.csv.gz> <assignment.csv> <out.csv> [--key COL] [--to COL]
                     [--state ST ...]

The assignment file is any two-or-more column CSV whose first column (or --key)
holds a 15-digit GEOID20 and whose --to column holds the target geography --
a district number, a DMA code, whatever. Every numeric column of the spine is
summed; block counts come along as N_BLOCKS. Blocks in the spine that the
assignment does not mention are reported as unassigned rather than dropped
silently, which is how a stale or partial equivalency gives itself away.
"""
import argparse
import csv
import gzip
import sys

SKIP = {"GEOID20", "ST", "STATEFP", "COUNTYFP", "TRACT", "BLKGRP", "BLOCKCE",
        "INTPTLAT", "INTPTLON", "UR20", "UACE20", "FUNCSTAT20"}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("spine")
    ap.add_argument("assignment")
    ap.add_argument("out")
    ap.add_argument("--key", default=None, help="GEOID column in the assignment file")
    ap.add_argument("--to", default=None, help="target-geography column (default: 2nd column)")
    ap.add_argument("--state", nargs="*", default=[], help="limit to these postal codes")
    args = ap.parse_args()

    with open(args.assignment, newline="") as fh:
        rdr = csv.reader(fh)
        hdr = next(rdr)
        kcol = hdr.index(args.key) if args.key else 0
        tcol = hdr.index(args.to) if args.to else 1
        assign = {r[kcol].strip().zfill(15): r[tcol].strip() for r in rdr if len(r) > max(kcol, tcol)}
    print(f"{len(assign):,} block assignments -> {len(set(assign.values()))} target areas",
          file=sys.stderr)

    states = set(args.state)
    agg, unassigned, unassigned_pop, matched = {}, 0, 0, 0
    with gzip.open(args.spine, "rt", newline="") as fh:
        rdr = csv.reader(fh)
        hdr = next(rdr)
        i = {n: k for k, n in enumerate(hdr)}
        num = [n for n in hdr if n not in SKIP]
        npos = [i[n] for n in num]
        st_i, pop_i = i["ST"], i["POP20"]
        for r in rdr:
            if states and r[st_i] not in states:
                continue
            target = assign.get(r[0])
            if target is None:
                unassigned += 1
                unassigned_pop += int(r[pop_i] or 0)
                continue
            matched += 1
            row = agg.setdefault(target, [0] * (len(num) + 1))
            row[0] += 1
            for j, p in enumerate(npos, start=1):
                v = r[p]
                if v:
                    row[j] += int(v)

    with open(args.out, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["AREA", "N_BLOCKS"] + num)
        for target in sorted(agg, key=lambda t: (len(t), t)):
            w.writerow([target] + agg[target])

    print(f"matched {matched:,} blocks into {len(agg)} areas -> {args.out}", file=sys.stderr)
    if unassigned:
        print(f"WARNING: {unassigned:,} blocks ({unassigned_pop:,} people) "
              f"had no assignment", file=sys.stderr)


if __name__ == "__main__":
    main()
