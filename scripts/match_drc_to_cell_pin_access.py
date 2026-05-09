#!/usr/bin/env python3
"""Match route DRC markers to nearby report_cell_pin_access points."""

import argparse
import csv
import math
import re
from collections import Counter
from pathlib import Path


CELL_RE = re.compile(r"^Cell\s+(\S+)")
ACCESS_RE = re.compile(r"^\s+(Routable|Blocked)\s+(\S+)\(M2\)\s+\d+:\s+(.*)$")
POINT_RE = re.compile(r"\{([-0-9.]+)\s+([-0-9.]+)\}")


def parse_access(path):
    access = {}
    current_cell = None
    for line in path.read_text(errors="ignore").splitlines():
        match = CELL_RE.match(line)
        if match:
            current_cell = match.group(1)
            continue
        if current_cell is None:
            continue
        match = ACCESS_RE.match(line)
        if not match:
            continue
        status, pin, points_text = match.groups()
        for point in POINT_RE.finditer(points_text):
            x = float(point.group(1))
            y = float(point.group(2))
            access.setdefault(current_cell, []).append((pin, status, x, y))
    return access


def parse_marker_context(path):
    marker_cells = {}
    current_marker = None
    for line in path.read_text(errors="ignore").splitlines():
        if line.startswith("Marker "):
            current_marker = line.split(maxsplit=1)[1]
            marker_cells[current_marker] = set()
            continue
        stripped = line.strip()
        if current_marker and stripped.startswith("cell "):
            fields = stripped.split()
            if len(fields) >= 2:
                marker_cells[current_marker].add(fields[1])
        elif current_marker and stripped.startswith("cell     :"):
            cell = stripped.split(":", 1)[1].strip()
            marker_cells[current_marker].add(cell)
    return marker_cells


def marker_tag(error_id):
    return "all_{}".format(error_id)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--drc-markers", required=True, type=Path)
    parser.add_argument("--marker-context", required=True, type=Path)
    parser.add_argument("--pin-access", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--summary", required=True, type=Path)
    parser.add_argument("--threshold", type=float, default=0.08)
    args = parser.parse_args()

    access = parse_access(args.pin_access)
    marker_cells = parse_marker_context(args.marker_context)
    rows = list(csv.DictReader(args.drc_markers.open(), delimiter="\t"))

    args.out.parent.mkdir(parents=True, exist_ok=True)
    matched = []
    by_pin = Counter()
    by_status = Counter()
    by_ref_hint = Counter()
    unmatched = 0

    with args.out.open("w") as out:
        fields = [
            "error_id",
            "error_type",
            "error_layer",
            "cx",
            "cy",
            "cell",
            "pin",
            "access_status",
            "access_x",
            "access_y",
            "distance",
        ]
        writer = csv.DictWriter(out, fieldnames=fields, delimiter="\t")
        writer.writeheader()

        for row in rows:
            tag = marker_tag(row["error_id"])
            cx = float(row["cx"])
            cy = float(row["cy"])
            best = None
            for cell in marker_cells.get(tag, []):
                for pin, status, ax, ay in access.get(cell, []):
                    dist = math.hypot(cx - ax, cy - ay)
                    if best is None or dist < best[0]:
                        best = (dist, cell, pin, status, ax, ay)

            if best is None or best[0] > args.threshold:
                unmatched += 1
                continue

            dist, cell, pin, status, ax, ay = best
            matched.append(best)
            by_pin[pin] += 1
            by_status[status] += 1
            ref_hint = cell.rsplit("/", 1)[-1]
            by_ref_hint[ref_hint] += 1
            writer.writerow(
                {
                    "error_id": row["error_id"],
                    "error_type": row["error_type"],
                    "error_layer": row["error_layer"],
                    "cx": row["cx"],
                    "cy": row["cy"],
                    "cell": cell,
                    "pin": pin,
                    "access_status": status,
                    "access_x": "{:.4f}".format(ax),
                    "access_y": "{:.4f}".format(ay),
                    "distance": "{:.6f}".format(dist),
                }
            )

    with args.summary.open("w") as out:
        out.write("DRC to cell pin access coordinate match\n")
        out.write("drc_markers={}\n".format(args.drc_markers))
        out.write("marker_context={}\n".format(args.marker_context))
        out.write("pin_access={}\n".format(args.pin_access))
        out.write("threshold={:.3f}\n".format(args.threshold))
        out.write("markers={}\n".format(len(rows)))
        out.write("matched={}\n".format(len(matched)))
        out.write("unmatched={}\n\n".format(unmatched))

        out.write("By access status\n")
        for key, value in by_status.most_common():
            out.write("{:5d} {}\n".format(value, key))

        out.write("\nBy pin\n")
        for key, value in by_pin.most_common(30):
            out.write("{:5d} {}\n".format(value, key))

        out.write("\nMost repeated leaf cell names\n")
        for key, value in by_ref_hint.most_common(30):
            out.write("{:5d} {}\n".format(value, key))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
