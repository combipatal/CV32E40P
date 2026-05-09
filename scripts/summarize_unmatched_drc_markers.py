#!/usr/bin/env python3
"""Summarize DRC markers that did not match nearby pin-access points."""

import argparse
import csv
from collections import Counter, defaultdict
from pathlib import Path
from typing import Dict, Set


def marker_tag(error_id: str) -> str:
    return "all_{}".format(error_id)


def read_matched_ids(path: Path) -> Set[str]:
    matched = set()
    with path.open() as handle:
        for row in csv.DictReader(handle, delimiter="\t"):
            matched.add(row["error_id"])
    return matched


def read_marker_rows(path: Path) -> Dict[str, Dict[str, str]]:
    rows = {}
    with path.open() as handle:
        for row in csv.DictReader(handle, delimiter="\t"):
            rows[row["error_id"]] = row
    return rows


def parse_marker_context(path: Path) -> Dict[str, Dict[str, Set[str]]]:
    context = defaultdict(lambda: {"refs": set(), "cells": set(), "pins": set(), "shapes": set(), "nets": set()})
    current_marker = ""
    current_pin = ""

    for raw in path.read_text(errors="ignore").splitlines():
        line = raw.rstrip()
        stripped = line.strip()

        if line.startswith("Marker "):
            current_marker = line.split(maxsplit=1)[1]
            current_pin = ""
            continue

        if not current_marker:
            continue

        if stripped.startswith("pin "):
            current_pin = stripped.split(maxsplit=1)[1]
            context[current_marker]["pins"].add(current_pin.rsplit("/", 1)[-1])
            continue

        if stripped.startswith("cell     :") and current_pin:
            context[current_marker]["cells"].add(stripped.split(":", 1)[1].strip())
            continue

        if stripped.startswith("ref_name :") and current_pin:
            context[current_marker]["refs"].add(stripped.split(":", 1)[1].strip())
            continue

        if stripped.startswith("cell ") and " ref=" in stripped:
            fields = stripped.split()
            context[current_marker]["cells"].add(fields[1])
            context[current_marker]["refs"].add(stripped.split(" ref=", 1)[1].split()[0])
            continue

        if stripped.startswith("layer :"):
            context[current_marker]["shapes"].add(stripped.split(":", 1)[1].strip())
            continue

        if stripped.startswith("net   :"):
            context[current_marker]["nets"].add(stripped.split(":", 1)[1].strip())

    return context


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--drc-markers", required=True, type=Path)
    parser.add_argument("--matched", required=True, type=Path)
    parser.add_argument("--marker-context", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--tsv", required=True, type=Path)
    args = parser.parse_args()

    marker_rows = read_marker_rows(args.drc_markers)
    matched_ids = read_matched_ids(args.matched)
    context = parse_marker_context(args.marker_context)
    unmatched_ids = sorted((set(marker_rows) - matched_ids), key=lambda value: int(value))

    by_type = Counter()
    by_layer = Counter()
    by_ref = Counter()
    by_pin = Counter()
    by_shape_layer = Counter()

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.tsv.parent.mkdir(parents=True, exist_ok=True)

    with args.tsv.open("w") as handle:
        fieldnames = [
            "error_id",
            "error_type",
            "error_layer",
            "cx",
            "cy",
            "refs",
            "pins",
            "shape_layers",
            "cells",
            "nets",
        ]
        writer = csv.DictWriter(handle, fieldnames=fieldnames, delimiter="\t")
        writer.writeheader()

        for error_id in unmatched_ids:
            row = marker_rows[error_id]
            tag = marker_tag(error_id)
            item = context[tag]

            by_type[row["error_type"]] += 1
            by_layer[row["error_layer"]] += 1
            for ref in item["refs"]:
                by_ref[ref] += 1
            for pin in item["pins"]:
                by_pin[pin] += 1
            for layer in item["shapes"]:
                by_shape_layer[layer] += 1

            writer.writerow(
                {
                    "error_id": error_id,
                    "error_type": row["error_type"],
                    "error_layer": row["error_layer"],
                    "cx": row["cx"],
                    "cy": row["cy"],
                    "refs": ",".join(sorted(item["refs"])),
                    "pins": ",".join(sorted(item["pins"])),
                    "shape_layers": ",".join(sorted(item["shapes"])),
                    "cells": ",".join(sorted(item["cells"])),
                    "nets": ",".join(sorted(item["nets"])),
                }
            )

    with args.out.open("w") as out:
        out.write("Unmatched DRC marker summary\n")
        out.write("drc_markers={}\n".format(args.drc_markers))
        out.write("matched={}\n".format(args.matched))
        out.write("marker_context={}\n".format(args.marker_context))
        out.write("total_markers={}\n".format(len(marker_rows)))
        out.write("matched_markers={}\n".format(len(matched_ids)))
        out.write("unmatched_markers={}\n\n".format(len(unmatched_ids)))

        out.write("By error type\n")
        for key, value in by_type.most_common():
            out.write("{:5d} {}\n".format(value, key))

        out.write("\nBy error layer\n")
        for key, value in by_layer.most_common():
            out.write("{:5d} {}\n".format(value, key))

        out.write("\nRefs touched by unmatched markers\n")
        for key, value in by_ref.most_common(40):
            out.write("{:5d} {}\n".format(value, key))

        out.write("\nPin leaf names touched by unmatched markers\n")
        for key, value in by_pin.most_common(40):
            out.write("{:5d} {}\n".format(value, key))

        out.write("\nShape layers touched by unmatched markers\n")
        for key, value in by_shape_layer.most_common():
            out.write("{:5d} {}\n".format(value, key))

        out.write("\nUnmatched marker detail\n")
        for error_id in unmatched_ids:
            row = marker_rows[error_id]
            item = context[marker_tag(error_id)]
            out.write(
                "{}\t{}\t{}\tcx={}\tcy={}\trefs={}\tpins={}\n".format(
                    error_id,
                    row["error_type"],
                    row["error_layer"],
                    row["cx"],
                    row["cy"],
                    ",".join(sorted(item["refs"])),
                    ",".join(sorted(item["pins"])),
                )
            )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
