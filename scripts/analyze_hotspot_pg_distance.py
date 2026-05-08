#!/usr/bin/env python3
"""
hotspot DRC marker와 PG shape 사이 거리를 계산한다.

입력:
  - all_drc_markers.tsv
  - hotspot_pg_shapes.tsv

출력:
  - hotspot_drc_pg_distance.tsv
  - hotspot_drc_pg_distance_summary.rpt
"""

import csv
import math
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MARKERS = ROOT / "7_Backend_ICC2/4_Report/trials/drc_marker_context/99_marker_context/all_drc_markers.tsv"
PG_SHAPES = ROOT / "7_Backend_ICC2/4_Report/trials/root_cause_probe/99_pg_distance/hotspot_pg_shapes.tsv"
OUT_DIR = ROOT / "7_Backend_ICC2/4_Report/trials/root_cause_probe/99_pg_distance"

HOTSPOT = (215.0, 195.0, 265.0, 265.0)


def read_tsv(path: Path):
    with path.open() as fp:
        return list(csv.DictReader(fp, delimiter="\t"))


def inside_hotspot(marker):
    x = float(marker["cx"])
    y = float(marker["cy"])
    x1, y1, x2, y2 = HOTSPOT
    return x1 <= x <= x2 and y1 <= y <= y2


def point_rect_distance(x, y, shape):
    sx1 = float(shape["x1"])
    sy1 = float(shape["y1"])
    sx2 = float(shape["x2"])
    sy2 = float(shape["y2"])

    dx = max(sx1 - x, 0.0, x - sx2)
    dy = max(sy1 - y, 0.0, y - sy2)
    return math.hypot(dx, dy)


def distance_bin(distance):
    if distance <= 0.25:
        return "<=0.25um"
    if distance <= 0.50:
        return "<=0.50um"
    if distance <= 1.00:
        return "<=1.00um"
    if distance <= 2.00:
        return "<=2.00um"
    if distance <= 5.00:
        return "<=5.00um"
    return ">5.00um"


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    markers = [row for row in read_tsv(MARKERS) if inside_hotspot(row)]
    pg_shapes = [row for row in read_tsv(PG_SHAPES) if row["layer"] == "M2"]

    rows = []
    for marker in markers:
        x = float(marker["cx"])
        y = float(marker["cy"])
        nearest = None
        nearest_distance = None
        for shape in pg_shapes:
            distance = point_rect_distance(x, y, shape)
            if nearest_distance is None or distance < nearest_distance:
                nearest = shape
                nearest_distance = distance

        row = dict(marker)
        if nearest is None:
            row.update(
                {
                    "nearest_pg_net": "",
                    "nearest_pg_shape": "",
                    "nearest_pg_distance_um": "",
                    "nearest_pg_distance_bin": "NO_PG_SHAPE",
                }
            )
        else:
            row.update(
                {
                    "nearest_pg_net": nearest["net"],
                    "nearest_pg_shape": nearest["shape_name"],
                    "nearest_pg_distance_um": f"{nearest_distance:.4f}",
                    "nearest_pg_distance_bin": distance_bin(nearest_distance),
                }
            )
        rows.append(row)

    fields = [
        "error_id",
        "error_type",
        "error_layer",
        "cx",
        "cy",
        "bucket20",
        "nearest_pg_net",
        "nearest_pg_shape",
        "nearest_pg_distance_um",
        "nearest_pg_distance_bin",
    ]

    with (OUT_DIR / "hotspot_drc_pg_distance.tsv").open("w") as fp:
        writer = csv.DictWriter(fp, delimiter="\t", fieldnames=fields)
        writer.writeheader()
        for row in rows:
            writer.writerow({field: row.get(field, "") for field in fields})

    by_bin = Counter(row["nearest_pg_distance_bin"] for row in rows)
    by_type_bin = Counter((row["error_type"], row["error_layer"], row["nearest_pg_distance_bin"]) for row in rows)
    numeric_distances = [
        float(row["nearest_pg_distance_um"])
        for row in rows
        if row["nearest_pg_distance_um"] != ""
    ]

    with (OUT_DIR / "hotspot_drc_pg_distance_summary.rpt").open("w") as fp:
        fp.write("Hotspot DRC to M2 PG distance summary\n\n")
        fp.write(f"hotspot_bbox={HOTSPOT}\n")
        fp.write(f"hotspot_marker_count={len(markers)}\n")
        fp.write(f"m2_pg_shape_count={len(pg_shapes)}\n")
        fp.write("\nDistance bins, non-cumulative:\n")
        for bucket, count in by_bin.most_common():
            fp.write(f"  {bucket}: {count}\n")
        fp.write("\nDistance bins, cumulative:\n")
        for threshold in [0.25, 0.50, 1.00, 2.00, 5.00]:
            count = sum(1 for distance in numeric_distances if distance <= threshold)
            fp.write(f"  <= {threshold:.2f}um: {count}\n")
        count = sum(1 for distance in numeric_distances if distance > 5.00)
        fp.write(f"  > 5.00um: {count}\n")
        fp.write("\nBy type/layer/bin:\n")
        for (error_type, error_layer, bucket), count in by_type_bin.most_common():
            fp.write(f"  {error_type} | {error_layer} | {bucket}: {count}\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
