#!/usr/bin/env python3
"""A2 access point와 실제 DRC marker bbox의 geometry 차이를 요약한다."""

import argparse
import csv
from collections import Counter
from pathlib import Path


def bucket(value: float, ndigits: int = 3) -> str:
    return f"{value:.{ndigits}f}"


def nearest_track_delta(value: float, start: float, pitch: float) -> float:
    idx = round((value - start) / pitch)
    return value - (start + idx * pitch)


def read_tsv(path: Path):
    with path.open() as fp:
        return list(csv.DictReader(fp, delimiter="\t"))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--match-tsv", required=True)
    parser.add_argument("--drc-markers", required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--track-start", type=float, default=0.088)
    parser.add_argument("--track-pitch", type=float, default=0.152)
    args = parser.parse_args()

    match_rows = read_tsv(Path(args.match_tsv))
    marker_rows = read_tsv(Path(args.drc_markers))
    marker_by_id = {row["error_id"]: row for row in marker_rows}

    by_layer_type = Counter()
    by_shift = Counter()
    by_layer_shift = Counter()
    by_bbox = Counter()
    by_layer_bbox = Counter()
    by_marker_track = Counter()
    by_access_track = Counter()
    missing_marker = 0
    examples = []

    for row in match_rows:
        marker = marker_by_id.get(row["error_id"])
        if marker is None:
            missing_marker += 1
            continue

        layer = row["error_layer"]
        error_type = row["error_type"]
        cx = float(row["cx"])
        cy = float(row["cy"])
        ax = float(row["access_x"])
        ay = float(row["access_y"])
        x1 = float(marker["x1"])
        y1 = float(marker["y1"])
        x2 = float(marker["x2"])
        y2 = float(marker["y2"])

        dx = cx - ax
        dy = cy - ay
        width = x2 - x1
        height = y2 - y1
        mdx = nearest_track_delta(cx, args.track_start, args.track_pitch)
        mdy = nearest_track_delta(cy, args.track_start, args.track_pitch)
        adx = nearest_track_delta(ax, args.track_start, args.track_pitch)
        ady = nearest_track_delta(ay, args.track_start, args.track_pitch)

        layer_type = f"{error_type} | {layer}"
        shift_key = f"dx={bucket(dx)} dy={bucket(dy)}"
        bbox_key = f"w={bucket(width)} h={bucket(height)}"
        marker_track_key = f"dx={bucket(mdx)} dy={bucket(mdy)}"
        access_track_key = f"dx={bucket(adx)} dy={bucket(ady)}"

        by_layer_type[layer_type] += 1
        by_shift[shift_key] += 1
        by_layer_shift[f"{layer_type} | {shift_key}"] += 1
        by_bbox[bbox_key] += 1
        by_layer_bbox[f"{layer_type} | {bbox_key}"] += 1
        by_marker_track[f"{layer_type} | {marker_track_key}"] += 1
        by_access_track[f"{layer_type} | {access_track_key}"] += 1

        if len(examples) < 24:
            examples.append(
                (
                    row["error_id"],
                    layer_type,
                    row["cell"],
                    row["pin"],
                    cx,
                    cy,
                    ax,
                    ay,
                    dx,
                    dy,
                    width,
                    height,
                    mdx,
                    mdy,
                    adx,
                    ady,
                )
            )

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    with out_path.open("w") as out:
        out.write("A2 marker shape geometry analysis\n\n")
        out.write(f"match_tsv: {args.match_tsv}\n")
        out.write(f"drc_markers: {args.drc_markers}\n")
        out.write(f"matched_rows: {len(match_rows)}\n")
        out.write(f"missing_marker_rows: {missing_marker}\n")
        out.write(f"track_start: {args.track_start:.3f}\n")
        out.write(f"track_pitch: {args.track_pitch:.3f}\n\n")

        out.write("Matched DRC by type/layer:\n")
        for key, value in by_layer_type.most_common():
            out.write(f"  {key}: {value}\n")

        out.write("\nMarker center minus report_cell_pin_access point:\n")
        for key, value in by_shift.most_common():
            out.write(f"  {key}: {value}\n")

        out.write("\nMarker center shift by layer/type:\n")
        for key, value in by_layer_shift.most_common():
            out.write(f"  {key}: {value}\n")

        out.write("\nDRC marker bbox dimensions:\n")
        for key, value in by_bbox.most_common():
            out.write(f"  {key}: {value}\n")

        out.write("\nDRC marker bbox dimensions by layer/type:\n")
        for key, value in by_layer_bbox.most_common():
            out.write(f"  {key}: {value}\n")

        out.write("\nMarker center track delta by layer/type:\n")
        for key, value in by_marker_track.most_common():
            out.write(f"  {key}: {value}\n")

        out.write("\nAccess point track delta by layer/type:\n")
        for key, value in by_access_track.most_common():
            out.write(f"  {key}: {value}\n")

        out.write("\nExamples:\n")
        for item in examples:
            (
                error_id,
                layer_type,
                cell,
                pin,
                cx,
                cy,
                ax,
                ay,
                dx,
                dy,
                width,
                height,
                mdx,
                mdy,
                adx,
                ady,
            ) = item
            out.write(
                "  "
                f"id={error_id} {layer_type} cell={cell} pin={pin} "
                f"marker=({cx:.3f},{cy:.3f}) access=({ax:.3f},{ay:.3f}) "
                f"shift=({dx:.3f},{dy:.3f}) bbox=({width:.3f},{height:.3f}) "
                f"marker_track=({mdx:.3f},{mdy:.3f}) "
                f"access_track=({adx:.3f},{ady:.3f})\n"
            )

        out.write("\nInterpretation:\n")
        out.write("  report_cell_pin_access의 A2 access point는 대부분 track 위에 있다.\n")
        out.write("  그러나 check_routes marker 중심은 반복적인 x shift와 bbox dimension을 가진다.\n")
        out.write("  즉 문제는 blocked pin이 아니라 access point에서 생성된 M2/VIA1 shape의 snapping 또는 route/check grid 쪽이다.\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
