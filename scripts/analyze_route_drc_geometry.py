#!/usr/bin/env python3
"""Route DRC marker geometry summary.

입력은 select_drc_representatives.py가 만든 all_drc_markers.tsv입니다.
목적은 fix trial이 아니라 원인 분해입니다.
"""

import argparse
import csv
from collections import Counter, defaultdict
from pathlib import Path


def parse_bbox(text):
    x1, y1, x2, y2 = [float(v) for v in text.split(",")]
    return x1, y1, x2, y2


def in_bbox(row, bbox):
    x1, y1, x2, y2 = bbox
    cx = float(row["cx"])
    cy = float(row["cy"])
    return x1 <= cx <= x2 and y1 <= cy <= y2


def nearest_stripe_distance(cx, stripe_centers, half_width):
    if not stripe_centers:
        return 999999.0
    return min(max(0.0, abs(cx - stripe_x) - half_width) for stripe_x in stripe_centers)


def residue(value, pitch):
    raw = value % pitch
    return min(raw, pitch - raw)


def rounded(value, ndigits=3):
    return f"{value:.{ndigits}f}"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--markers", required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--hotspot-bbox", default="215,195,265,265")
    parser.add_argument("--m2-pg-stripes", default="220,240,260")
    parser.add_argument("--m2-pg-half-width", type=float, default=0.2)
    parser.add_argument("--pitch", type=float, default=0.152)
    args = parser.parse_args()

    marker_path = Path(args.markers)
    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    hotspot = parse_bbox(args.hotspot_bbox)
    stripe_centers = [float(v) for v in args.m2_pg_stripes.split(",") if v]

    with marker_path.open() as fp:
        rows = list(csv.DictReader(fp, delimiter="\t"))

    hotspot_rows = [row for row in rows if in_bbox(row, hotspot)]

    def type_layer_counter(subset):
        c = Counter()
        for row in subset:
            c[(row["error_type"], row["error_layer"])] += 1
        return c

    stripe_bins = Counter()
    stripe_by_type: Counter[tuple[str, str, str]] = Counter()
    residue_by_type = defaultdict(Counter)

    for row in rows:
        cx = float(row["cx"])
        cy = float(row["cy"])
        dist = nearest_stripe_distance(cx, stripe_centers, args.m2_pg_half_width)
        if dist <= 0.25:
            d_bin = "<=0.25"
        elif dist <= 0.5:
            d_bin = "<=0.50"
        elif dist <= 1.0:
            d_bin = "<=1.00"
        elif dist <= 2.0:
            d_bin = "<=2.00"
        elif dist <= 5.0:
            d_bin = "<=5.00"
        else:
            d_bin = ">5.00"
        stripe_bins[d_bin] += 1
        stripe_by_type[(row["error_type"], row["error_layer"], d_bin)] += 1

        key = (row["error_type"], row["error_layer"])
        rx = rounded(residue(cx, args.pitch))
        ry = rounded(residue(cy, args.pitch))
        residue_by_type[key][(rx, ry)] += 1

    with out_path.open("w") as out:
        out.write("Route DRC geometry analysis\n\n")
        out.write(f"marker_file: {marker_path}\n")
        out.write(f"total_markers: {len(rows)}\n")
        out.write(f"hotspot_bbox: {hotspot}\n")
        out.write(f"hotspot_markers: {len(hotspot_rows)}\n")
        out.write(f"m2_pg_stripe_centers: {stripe_centers}\n")
        out.write(f"assumed_m2_pg_half_width: {args.m2_pg_half_width}\n")
        out.write(f"grid_pitch_for_residue_probe: {args.pitch}\n\n")

        out.write("All markers by type/layer:\n")
        for (typ, layer), count in type_layer_counter(rows).most_common():
            out.write(f"  {typ} | {layer}: {count}\n")

        out.write("\nHotspot markers by type/layer:\n")
        for (typ, layer), count in type_layer_counter(hotspot_rows).most_common():
            out.write(f"  {typ} | {layer}: {count}\n")

        out.write("\nDistance to nearest hotspot M2 PG stripe by all markers:\n")
        for key in ["<=0.25", "<=0.50", "<=1.00", "<=2.00", "<=5.00", ">5.00"]:
            out.write(f"  {key}: {stripe_bins[key]}\n")

        out.write("\nDistance to nearest hotspot M2 PG stripe by type/layer/bin, top 20:\n")
        for (typ, layer, d_bin), count in stripe_by_type.most_common(20):
            out.write(f"  {typ} | {layer} | {d_bin}: {count}\n")

        out.write("\nMost common center residues vs 0.152um pitch, by type/layer:\n")
        for key, counter in sorted(residue_by_type.items()):
            typ, layer = key
            out.write(f"  {typ} | {layer}\n")
            for (rx, ry), count in counter.most_common(8):
                out.write(f"    rx={rx} ry={ry}: {count}\n")


if __name__ == "__main__":
    main()
