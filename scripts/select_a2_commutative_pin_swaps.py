#!/usr/bin/env python3
"""Select commutative A1/A2 pin swaps for matched A2 route DRC cells."""

import argparse
import csv
from pathlib import Path

from analyze_a2_lef_access_alignment import parse_marker_context


COMMUTATIVE_REFS = {
    "NOR2X0_HVT",
    "NOR2X1_HVT",
    "NOR2X2_HVT",
    "NOR2X4_HVT",
    "OR2X1_HVT",
    "OR2X2_HVT",
    "OR2X4_HVT",
}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--match-tsv", required=True)
    parser.add_argument("--marker-context", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()

    rows = list(csv.DictReader(Path(args.match_tsv).open(), delimiter="\t"))
    cell_context = parse_marker_context(Path(args.marker_context))

    selected = {}
    for row in rows:
        if row["pin"] != "A2":
            continue
        cell = row["cell"]
        if cell not in cell_context:
            continue
        ref, _ox, _oy = cell_context[cell]
        if ref not in COMMUTATIVE_REFS:
            continue
        selected[cell] = ref

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w") as out:
        out.write("cell\tref\tpin_a\tpin_b\treason\n")
        for cell in sorted(selected):
            ref = selected[cell]
            out.write(
                "{}\t{}\tA1\tA2\tmatched_A2_route_DRC_commutative_swap\n".format(cell, ref)
            )

    print("selected_pin_swaps={}".format(len(selected)))
    by_ref = {}
    for ref in selected.values():
        by_ref[ref] = by_ref.get(ref, 0) + 1
    for ref in sorted(by_ref):
        print("{}={}".format(ref, by_ref[ref]))


if __name__ == "__main__":
    main()
