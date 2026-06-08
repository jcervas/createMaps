#!/usr/bin/env python3
"""
organize.py — Move downloaded DRA block assignment CSVs into a tidy
era × chamber folder structure.

Run this from the dra-block-assignments root after dra_server.py has
finished receiving all files:

    python3 scripts/organize.py

Output layout
-------------
    116th-118th/congress/       40-43 congressional maps (pre-2020 census)
    2018/lower/                 ~48 state house maps
    2018/upper/                 ~46 state senate maps
    2020/congress/              ~43 congressional maps
    2020/lower/                 ~44 state house maps
    2020/upper/                 ~45 state senate maps
    2020/legislature/            5 combined-chamber maps (NE unicameral etc.)
    2022-2026/congress/         ~57 congressional maps
    2022-2026/lower/            ~54 state house maps
    2022-2026/upper/            ~53 state senate maps
    2022-2026/legislature/       5 combined-chamber maps
    2022-2026/council/           1 DC Council map
    other/                      miscellaneous (DC 2012, etc.)
"""
import os, shutil, re

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def get_era(fname):
    if '116th' in fname or '118th' in fname: return '116th-118th'
    if '2018' in fname: return '2018'
    if '2020' in fname: return '2020'
    if re.search(r'202[2-9]|20[3-9]\d', fname): return '2022-2026'
    return 'other'


def get_chamber(fname):
    if 'Congressional' in fname or 'Congress' in fname: return 'congress'
    if 'Upper' in fname or 'State Senate' in fname:     return 'upper'
    if 'Lower' in fname or 'State House' in fname:      return 'lower'
    if 'Legislature' in fname:                           return 'legislature'
    if 'Council' in fname:                               return 'council'
    return 'other'


def main():
    files = [
        f for f in os.listdir(BASE)
        if f.endswith('.csv') and f != 'dra_maps_lookup.csv'
    ]
    if not files:
        print('No CSV files found at root — already organized, or nothing downloaded yet.')
        return

    moved = 0
    for fname in sorted(files):
        era     = get_era(fname)
        chamber = get_chamber(fname)
        dest    = os.path.join(BASE, era, chamber)
        os.makedirs(dest, exist_ok=True)
        shutil.move(os.path.join(BASE, fname), os.path.join(dest, fname))
        moved += 1

    print(f'Moved {moved} files. Folder summary:')
    for era in sorted(os.listdir(BASE)):
        era_path = os.path.join(BASE, era)
        if not os.path.isdir(era_path) or era == 'scripts':
            continue
        for chamber in sorted(os.listdir(era_path)):
            ch_path = os.path.join(era_path, chamber)
            if not os.path.isdir(ch_path):
                continue
            n = len([f for f in os.listdir(ch_path) if f.endswith('.csv')])
            print(f'  {era}/{chamber}/  ({n} files)')


if __name__ == '__main__':
    main()
