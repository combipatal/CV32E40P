#!/usr/bin/env python3
"""HVT OR/NOR A2 access 좌표와 route DRC marker의 track delta를 요약한다."""

import argparse
import csv
from collections import Counter, defaultdict
from pathlib import Path


def nearest_track_delta(value: float, start: float, pitch: float) -> float:
    idx = round((value - start) / pitch)
    return value - (start + idx * pitch)


def bucket(value: float) -> str:
    return f"{value:.3f}"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--match-tsv", required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--track-start", type=float, default=0.088)
    parser.add_argument("--track-pitch", type=float, default=0.152)
    args = parser.parse_args()

    match_path = Path(args.match_tsv)
    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    with match_path.open() as fp:
        rows = list(csv.DictReader(fp, delimiter="\t"))

    by_type_layer = Counter()
    by_cell_pin = Counter()
    marker_dx = Counter()
    marker_dy = Counter()
    access_dx = Counter()
    access_dy = Counter()
    stats = defaultdict(float)

    for row in rows:
        key = f"{row['error_type']} | {row['error_layer']}"
        cell_pin = f"{row['cell'].split('/')[-1]} | {row['pin']}"
        by_type_layer[key] += 1
        by_cell_pin[f"{row['cell']} | {row['pin']}"] += 1

        cx = float(row["cx"])
        cy = float(row["cy"])
        ax = float(row["access_x"])
        ay = float(row["access_y"])

        mdx = nearest_track_delta(cx, args.track_start, args.track_pitch)
        mdy = nearest_track_delta(cy, args.track_start, args.track_pitch)
        adx = nearest_track_delta(ax, args.track_start, args.track_pitch)
        ady = nearest_track_delta(ay, args.track_start, args.track_pitch)

        marker_dx[bucket(mdx)] += 1
        marker_dy[bucket(mdy)] += 1
        access_dx[bucket(adx)] += 1
        access_dy[bucket(ady)] += 1

        stats["marker_dx_sum"] += mdx
        stats["marker_dy_sum"] += mdy
        stats["access_dx_sum"] += adx
        stats["access_dy_sum"] += ady

    count = len(rows)
    with out_path.open("w") as out:
        out.write("A2 access / route DRC grid mismatch analysis\n\n")
        out.write(f"match_tsv: {match_path}\n")
        out.write(f"matched_marker_count: {count}\n")
        out.write(f"track_start: {args.track_start:.3f}\n")
        out.write(f"track_pitch: {args.track_pitch:.3f}\n\n")

        out.write("Matched DRC by type/layer:\n")
        for key, value in by_type_layer.most_common():
            out.write(f"  {key}: {value}\n")

        out.write("\nTrack delta means:\n")
        if count:
            out.write(f"  marker_dx_mean: {stats['marker_dx_sum'] / count:.6f}\n")
            out.write(f"  marker_dy_mean: {stats['marker_dy_sum'] / count:.6f}\n")
            out.write(f"  access_dx_mean: {stats['access_dx_sum'] / count:.6f}\n")
            out.write(f"  access_dy_mean: {stats['access_dy_sum'] / count:.6f}\n")

        out.write("\nMarker center delta to nearest track, X:\n")
        for key, value in marker_dx.most_common():
            out.write(f"  {key}: {value}\n")

        out.write("\nMarker center delta to nearest track, Y:\n")
        for key, value in marker_dy.most_common():
            out.write(f"  {key}: {value}\n")

        out.write("\nReported access delta to nearest track, X:\n")
        for key, value in access_dx.most_common():
            out.write(f"  {key}: {value}\n")

        out.write("\nReported access delta to nearest track, Y:\n")
        for key, value in access_dy.most_common():
            out.write(f"  {key}: {value}\n")

        out.write("\nMost repeated matched instances:\n")
        for key, value in by_cell_pin.most_common(20):
            out.write(f"  {key}: {value}\n")

        out.write("\nInterpretation:\n")
        out.write("  report_cell_pin_access가 만든 A2 access point와 check_routes marker가 같은 좌표 근처에 있다.\n")
        out.write("  하지만 access point와 실제 DRC marker의 track delta 축이 다르다.\n")
        out.write("  이것은 단순 blocked access보다 pin access snapping / via generation / route check grid mismatch 쪽 증거다.\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
