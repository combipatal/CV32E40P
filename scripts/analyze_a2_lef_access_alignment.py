#!/usr/bin/env python3
"""Compare matched A2 DRC/access points against SAED32 HVT LEF pin geometry.

The input match TSV comes from the ICC2 coordinate match between check_routes
markers and report_cell_pin_access points.  This script keeps the analysis
offline: it uses marker context for ref/origin, parses the HVT LEF, infers the
cell orientation that places the access point inside A2, and reports whether
the local access point has enough M1 pin metal for the default VIA1 enclosure.
"""

import argparse
import csv
import re
from collections import Counter, defaultdict
from pathlib import Path


class PinShape:
    def __init__(self, layer, rect):
        self.layer = layer
        self.rect = rect


class Macro:
    def __init__(self, name):
        self.name = name
        self.size_x = 0.0
        self.size_y = 0.0
        self.pins = defaultdict(list)


def parse_lef(path):
    macros = {}
    current = None
    pin_name = None
    layer = None

    macro_re = re.compile(r"^\s*MACRO\s+(\S+)")
    pin_re = re.compile(r"^\s*PIN\s+(\S+)")
    layer_re = re.compile(r"^\s*LAYER\s+(\S+)\s*;")
    rect_re = re.compile(
        r"^\s*RECT\s+([-0-9.]+)\s+([-0-9.]+)\s+([-0-9.]+)\s+([-0-9.]+)\s*;"
    )
    size_re = re.compile(r"^\s*SIZE\s+([-0-9.]+)\s+BY\s+([-0-9.]+)\s*;")

    for line in path.read_text(errors="ignore").splitlines():
        if current is None:
            match = macro_re.match(line)
            if match:
                current = Macro(match.group(1))
            continue

        if line.strip() == f"END {current.name}":
            macros[current.name] = current
            current = None
            pin_name = None
            layer = None
            continue

        match = size_re.match(line)
        if match:
            current.size_x = float(match.group(1))
            current.size_y = float(match.group(2))
            continue

        match = pin_re.match(line)
        if match:
            pin_name = match.group(1)
            layer = None
            continue

        if pin_name and line.strip() == f"END {pin_name}":
            pin_name = None
            layer = None
            continue

        if not pin_name:
            continue

        match = layer_re.match(line)
        if match:
            layer = match.group(1)
            continue

        match = rect_re.match(line)
        if match and layer:
            rect = tuple(float(match.group(i)) for i in range(1, 5))
            current.pins[pin_name].append(PinShape(layer, rect))

    return macros


def parse_marker_context(path):
    cells = {}
    cell_re = re.compile(r"^\s*cell\s+(\S+)\s+ref=(\S+)\s+origin=([-0-9.]+)\s+([-0-9.]+)")
    for line in path.read_text(errors="ignore").splitlines():
        match = cell_re.match(line)
        if match:
            cells[match.group(1)] = (
                match.group(2),
                float(match.group(3)),
                float(match.group(4)),
            )
    return cells


def orient_to_local(gx, gy, ox, oy, width, height, orient):
    dx = gx - ox
    dy = gy - oy
    if orient == "R0":
        return dx, dy
    if orient == "MX":
        return dx, -dy
    if orient == "MY":
        return -dx, dy
    if orient == "R180":
        return -dx, -dy
    if orient == "R0_UR":
        return dx, dy + height
    if orient == "MX_UR":
        return dx, height - dy
    if orient == "MY_UR":
        return width - dx, dy
    if orient == "R180_UR":
        return width - dx, height - dy
    raise ValueError(orient)


def contains(rect, x, y, margin=1e-6):
    x1, y1, x2, y2 = rect
    return x1 - margin <= x <= x2 + margin and y1 - margin <= y <= y2 + margin


def nearest_track_delta(value, start, pitch):
    idx = round((value - start) / pitch)
    return value - (start + idx * pitch)


def bucket(value, ndigits=3):
    return f"{value:.{ndigits}f}"


def best_orientation(row, cell_info, macro):
    gx = float(row["access_x"])
    gy = float(row["access_y"])
    _ref, ox, oy = cell_info
    orientations = ["R0", "MX", "MY", "R180", "R0_UR", "MX_UR", "MY_UR", "R180_UR"]
    m1_rects = [shape.rect for shape in macro.pins["A2"] if shape.layer == "M1"]

    best = ("unknown", 0.0, 0.0, -1)
    for orient in orientations:
        lx, ly = orient_to_local(gx, gy, ox, oy, macro.size_x, macro.size_y, orient)
        score = sum(1 for rect in m1_rects if contains(rect, lx, ly, margin=0.010))
        if score > best[3]:
            best = (orient, lx, ly, score)
    return best


def m1_via_window_score(macro, lx, ly, via_w, enc_x, enc_y):
    req_x = via_w / 2.0 + enc_x
    req_y = via_w / 2.0 + enc_y
    for shape in macro.pins["A2"]:
        if shape.layer != "M1":
            continue
        x1, y1, x2, y2 = shape.rect
        if x1 + req_x <= lx <= x2 - req_x and y1 + req_y <= ly <= y2 - req_y:
            return "full_m1_enclosure_ok"
        if contains(shape.rect, lx, ly, margin=1e-6):
            return "inside_m1_but_enclosure_tight"
    return "not_inside_m1"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--lef", required=True)
    parser.add_argument("--match-tsv", required=True)
    parser.add_argument("--marker-context", required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--track-start", type=float, default=0.088)
    parser.add_argument("--track-pitch", type=float, default=0.152)
    parser.add_argument("--via1-cut-width", type=float, default=0.050)
    parser.add_argument("--via1-m1-enc-x", type=float, default=0.030)
    parser.add_argument("--via1-m1-enc-y", type=float, default=0.005)
    args = parser.parse_args()

    macros = parse_lef(Path(args.lef))
    cells = parse_marker_context(Path(args.marker_context))
    rows = list(csv.DictReader(Path(args.match_tsv).open(), delimiter="\t"))

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    by_ref = Counter()
    by_ref_status = Counter()
    by_orient = Counter()
    local_x = defaultdict(Counter)
    local_y = defaultdict(Counter)
    access_dx = defaultdict(Counter)
    access_dy = defaultdict(Counter)
    missing = Counter()
    examples = []

    seen = set()
    for row in rows:
        cell = row["cell"]
        # M2 and VIA1 often describe the same failed access. Count unique cell/pin/coordinate once.
        key = (cell, row["pin"], row["access_x"], row["access_y"])
        if key in seen:
            continue
        seen.add(key)

        if cell not in cells:
            missing["cell_context"] += 1
            continue
        ref, _ox, _oy = cells[cell]
        if ref not in macros:
            missing["lef_macro"] += 1
            continue

        macro = macros[ref]
        orient, lx, ly, score = best_orientation(row, cells[cell], macro)
        status = m1_via_window_score(
            macro, lx, ly, args.via1_cut_width, args.via1_m1_enc_x, args.via1_m1_enc_y
        )

        by_ref[ref] += 1
        by_ref_status[(ref, status)] += 1
        by_orient[(ref, orient)] += 1
        local_x[ref][bucket(lx)] += 1
        local_y[ref][bucket(ly)] += 1
        access_dx[ref][bucket(nearest_track_delta(float(row["access_x"]), args.track_start, args.track_pitch))] += 1
        access_dy[ref][bucket(nearest_track_delta(float(row["access_y"]), args.track_start, args.track_pitch))] += 1

        if len(examples) < 20:
            examples.append((cell, ref, orient, lx, ly, status, row["access_x"], row["access_y"]))

    with out_path.open("w") as out:
        out.write("A2 LEF access alignment analysis\n\n")
        out.write(f"lef: {args.lef}\n")
        out.write(f"match_tsv: {args.match_tsv}\n")
        out.write(f"marker_context: {args.marker_context}\n")
        out.write(f"unique_access_points: {len(seen)}\n")
        out.write(f"track_start: {args.track_start:.3f}\n")
        out.write(f"track_pitch: {args.track_pitch:.3f}\n")
        out.write(
            "via1_m1_requirement: cut_width={:.3f}, enc_x={:.3f}, enc_y={:.3f}\n\n".format(
                args.via1_cut_width, args.via1_m1_enc_x, args.via1_m1_enc_y
            )
        )

        out.write("Missing inputs:\n")
        for key, count in missing.items():
            out.write(f"  {key}: {count}\n")

        out.write("\nUnique matched A2 access points by ref:\n")
        for ref, count in by_ref.most_common():
            out.write(f"  {ref}: {count}\n")

        out.write("\nM1 enclosure status by ref:\n")
        for (ref, status), count in by_ref_status.most_common():
            out.write(f"  {ref} | {status}: {count}\n")

        out.write("\nInferred orientation by ref:\n")
        for (ref, orient), count in by_orient.most_common():
            out.write(f"  {ref} | {orient}: {count}\n")

        for ref in sorted(by_ref):
            out.write(f"\nRef {ref} local access X buckets:\n")
            for val, count in local_x[ref].most_common(12):
                out.write(f"  {val}: {count}\n")
            out.write(f"Ref {ref} local access Y buckets:\n")
            for val, count in local_y[ref].most_common(12):
                out.write(f"  {val}: {count}\n")
            out.write(f"Ref {ref} global access track delta X:\n")
            for val, count in access_dx[ref].most_common():
                out.write(f"  {val}: {count}\n")
            out.write(f"Ref {ref} global access track delta Y:\n")
            for val, count in access_dy[ref].most_common():
                out.write(f"  {val}: {count}\n")

            macro = macros[ref]
            out.write(f"Ref {ref} LEF A2 shapes:\n")
            for shape in macro.pins["A2"]:
                out.write(f"  {shape.layer} RECT {shape.rect}\n")

        out.write("\nExamples:\n")
        for cell, ref, orient, lx, ly, status, gx, gy in examples:
            out.write(
                f"  {cell} ref={ref} orient={orient} global=({gx},{gy}) "
                f"local=({lx:.3f},{ly:.3f}) status={status}\n"
            )

        out.write("\nInterpretation:\n")
        out.write("  full_m1_enclosure_ok means the access point has enough A2 M1 metal for default VIA1 M1 enclosure.\n")
        out.write("  inside_m1_but_enclosure_tight means the access point is on the pin but too close to an M1 pin edge.\n")
        out.write("  If most points are full_m1_enclosure_ok, the remaining off-grid is less likely pure LEF pin-metal width.\n")
        out.write("  Then focus should move to generated via/access snapping or route/check grid policy.\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
