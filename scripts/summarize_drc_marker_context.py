#!/usr/bin/env python3
"""Summarize ICC2 DRC marker context reports."""

import argparse
from collections import Counter, defaultdict
from pathlib import Path
from typing import Optional, Set


def read_swapped_cells(path: Optional[Path]) -> Set[str]:
    if path is None or not path.exists():
        return set()

    cells = set()
    for line in path.read_text().splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        fields = line.split("\t")
        if len(fields) >= 1 and fields[0] != "cell":
            cells.add(fields[0])
    return cells


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--context", required=True, type=Path)
    parser.add_argument("--swap-file", type=Path)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()

    swapped_cells = read_swapped_cells(args.swap_file)
    marker_count = 0
    current_marker = ""
    current_pin = ""
    marker_refs = defaultdict(set)
    marker_cells = defaultdict(set)
    marker_pins = defaultdict(set)
    marker_pin_names = defaultdict(set)
    marker_swapped = defaultdict(set)

    for raw in args.context.read_text().splitlines():
        line = raw.rstrip()
        if line.startswith("Marker "):
            current_marker = line.split(maxsplit=1)[1]
            marker_count += 1
            current_pin = ""
            continue

        stripped = line.strip()
        if stripped.startswith("pin "):
            current_pin = stripped.split(maxsplit=1)[1]
            marker_pins[current_marker].add(current_pin)
            pin_leaf = current_pin.rsplit("/", 1)[-1]
            marker_pin_names[current_marker].add(pin_leaf)
            continue

        if stripped.startswith("ref_name :") and current_pin:
            ref = stripped.split(":", 1)[1].strip()
            marker_refs[current_marker].add(ref)
            continue

        if stripped.startswith("cell     :") and current_pin:
            cell = stripped.split(":", 1)[1].strip()
            marker_cells[current_marker].add(cell)
            if cell in swapped_cells:
                marker_swapped[current_marker].add(cell)
            continue

        if stripped.startswith("cell ") and " ref=" in stripped:
            cell = stripped.split()[1]
            ref = stripped.split(" ref=", 1)[1].split()[0]
            marker_cells[current_marker].add(cell)
            marker_refs[current_marker].add(ref)
            if cell in swapped_cells:
                marker_swapped[current_marker].add(cell)

    ref_marker_count = Counter()
    ref_occurrence_count = Counter()
    pin_leaf_count = Counter()
    cell_marker_count = Counter()
    swapped_marker_count = 0

    for marker, refs in marker_refs.items():
        for ref in refs:
            ref_marker_count[ref] += 1
    for refs in marker_refs.values():
        for ref in refs:
            ref_occurrence_count[ref] += 1
    for pins in marker_pin_names.values():
        for pin in pins:
            pin_leaf_count[pin] += 1
    for marker, cells in marker_cells.items():
        for cell in cells:
            cell_marker_count[cell] += 1
        if marker_swapped.get(marker):
            swapped_marker_count += 1

    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open("w") as out:
        out.write("DRC marker context summary\n")
        out.write(f"context={args.context}\n")
        out.write(f"markers={marker_count}\n")
        out.write(f"markers_with_swapped_cells={swapped_marker_count}\n")
        out.write(f"swap_file={args.swap_file or ''}\n")
        out.write("\nTop refs by marker count\n")
        for ref, count in ref_marker_count.most_common(30):
            out.write(f"{count:5d} {ref}\n")
        out.write("\nTop pin leaf names by marker count\n")
        for pin, count in pin_leaf_count.most_common(30):
            out.write(f"{count:5d} {pin}\n")
        out.write("\nTop cells by marker count\n")
        for cell, count in cell_marker_count.most_common(50):
            marker_swapped_flag = " swapped" if cell in swapped_cells else ""
            out.write(f"{count:5d} {cell}{marker_swapped_flag}\n")
        out.write("\nMarkers with swapped cells\n")
        for marker in sorted(marker_swapped):
            cells = " ".join(sorted(marker_swapped[marker]))
            refs = " ".join(sorted(marker_refs[marker]))
            pins = " ".join(sorted(marker_pin_names[marker]))
            out.write(f"{marker}\trefs={refs}\tpins={pins}\tcells={cells}\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
