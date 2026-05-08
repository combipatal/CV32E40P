#!/usr/bin/env python3
"""
SDFFARX1_RVT blocked access point와 route DRC marker의 위치 겹침을 분석한다.

입력:
  - blocked_access.by_ref_cell_pin.rpt
  - drc.detailed.rpt

출력:
  - sdffarx1_blocked_points.tsv
  - nearest_drc_per_sdffarx1_point.tsv
  - sdffarx1_hotspot_points.tsv
  - sdffarx1_overlap_summary.rpt
"""

import math
import os
import re
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

BLOCKED_REPORT = Path(
    os.environ.get(
        "BLOCKED_REPORT",
        ROOT / "7_Backend_ICC2/4_Report/trials/pin_access_blocked_detail/99_pin_access/blocked_access.by_ref_cell_pin.rpt",
    )
)
DRC_REPORT = Path(
    os.environ.get(
        "DRC_REPORT",
        ROOT / "7_Backend_ICC2/4_Report/06_route/drc_detail/drc.detailed.rpt",
    )
)
OUT_DIR = Path(
    os.environ.get(
        "OUT_DIR",
        ROOT / "7_Backend_ICC2/4_Report/trials/sdffarx1_hotspot_overlap/99_overlap",
    )
)

REF_NAME = "SDFFARX1_RVT"
HOTSPOT = (215.0, 195.0, 265.0, 265.0)
POINT_RE = re.compile(r"\{([-0-9.]+)\s+([-0-9.]+)\}")


def bucket20(x: float, y: float) -> str:
    bx = int(math.floor(x / 20.0) * 20)
    by = int(math.floor(y / 20.0) * 20)
    return f"{bx:03d}-{bx + 20:03d},{by:03d}-{by + 20:03d}"


def inside_hotspot(x: float, y: float) -> bool:
    x1, y1, x2, y2 = HOTSPOT
    return x1 <= x <= x2 and y1 <= y <= y2


def parse_blocked_points():
    rows = []

    with BLOCKED_REPORT.open() as fp:
        for line_no, line in enumerate(fp, start=1):
            parts = [part.strip() for part in line.rstrip("\n").split("|")]
            if len(parts) < 4:
                continue

            ref_name, cell_name, pin_name, detail = parts[:4]
            if ref_name != REF_NAME:
                continue

            for idx, (x_str, y_str) in enumerate(POINT_RE.findall(detail), start=1):
                x = float(x_str)
                y = float(y_str)
                rows.append(
                    {
                        "line_no": line_no,
                        "point_index": idx,
                        "ref_name": ref_name,
                        "cell_name": cell_name,
                        "pin_name": pin_name,
                        "x": x,
                        "y": y,
                        "bucket20": bucket20(x, y),
                        "inside_hotspot": "yes" if inside_hotspot(x, y) else "no",
                    }
                )

    return rows


def parse_drc_markers():
    rows = []
    current = {}

    with DRC_REPORT.open() as fp:
        for raw in fp:
            line = raw.strip()
            if line.startswith("Error ID"):
                current = {"error_id": line.split(":", 1)[1].strip()}
            elif line.startswith("Error Type"):
                current["error_type"] = line.split(":", 1)[1].strip()
            elif line.startswith("Error Layer"):
                current["error_layer"] = line.split(":", 1)[1].strip()
            elif line.startswith("Bbox"):
                points = POINT_RE.findall(line)
                if len(points) != 2:
                    continue
                (x1_str, y1_str), (x2_str, y2_str) = points
                x1 = float(x1_str)
                y1 = float(y1_str)
                x2 = float(x2_str)
                y2 = float(y2_str)
                cx = (x1 + x2) / 2.0
                cy = (y1 + y2) / 2.0
                current.update(
                    {
                        "x1": x1,
                        "y1": y1,
                        "x2": x2,
                        "y2": y2,
                        "cx": cx,
                        "cy": cy,
                        "bucket20": bucket20(cx, cy),
                        "inside_hotspot": "yes" if inside_hotspot(cx, cy) else "no",
                    }
                )
                rows.append(dict(current))
                current = {}

    return rows


def distance(point, marker) -> float:
    return math.hypot(float(point["x"]) - float(marker["cx"]), float(point["y"]) - float(marker["cy"]))


def write_tsv(path: Path, rows, fields):
    with path.open("w") as fp:
        fp.write("\t".join(fields) + "\n")
        for row in rows:
            fp.write("\t".join(str(row.get(field, "")) for field in fields) + "\n")


def radius_counter(rows):
    counts = Counter()
    for row in rows:
        value = float(row["distance_um"])
        for radius in [1.0, 2.0, 5.0, 10.0, 25.0, 50.0]:
            if value <= radius:
                counts[f"<={radius:.0f}um"] += 1
    return counts


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    blocked = parse_blocked_points()
    drc = parse_drc_markers()
    hotspot_drc = [row for row in drc if row["inside_hotspot"] == "yes"]

    nearest_rows = []
    for point in blocked:
        nearest = min(drc, key=lambda marker: distance(point, marker))
        dist = distance(point, nearest)
        nearest_rows.append(
            {
                "cell_name": point["cell_name"],
                "pin_name": point["pin_name"],
                "point_x": f"{point['x']:.4f}",
                "point_y": f"{point['y']:.4f}",
                "point_bucket20": point["bucket20"],
                "point_inside_hotspot": point["inside_hotspot"],
                "nearest_error_id": nearest.get("error_id", ""),
                "nearest_type": nearest.get("error_type", ""),
                "nearest_layer": nearest.get("error_layer", ""),
                "nearest_cx": f"{nearest['cx']:.4f}",
                "nearest_cy": f"{nearest['cy']:.4f}",
                "nearest_bucket20": nearest.get("bucket20", ""),
                "nearest_inside_hotspot": nearest.get("inside_hotspot", ""),
                "distance_um": f"{dist:.4f}",
            }
        )

    hotspot_points = [row for row in nearest_rows if row["point_inside_hotspot"] == "yes"]
    near_hotspot_drc = [row for row in nearest_rows if row["nearest_inside_hotspot"] == "yes"]

    point_fields = [
        "ref_name",
        "cell_name",
        "pin_name",
        "x",
        "y",
        "bucket20",
        "inside_hotspot",
        "line_no",
        "point_index",
    ]
    nearest_fields = [
        "cell_name",
        "pin_name",
        "point_x",
        "point_y",
        "point_bucket20",
        "point_inside_hotspot",
        "nearest_error_id",
        "nearest_type",
        "nearest_layer",
        "nearest_cx",
        "nearest_cy",
        "nearest_bucket20",
        "nearest_inside_hotspot",
        "distance_um",
    ]

    write_tsv(OUT_DIR / "sdffarx1_blocked_points.tsv", blocked, point_fields)
    write_tsv(OUT_DIR / "nearest_drc_per_sdffarx1_point.tsv", nearest_rows, nearest_fields)
    write_tsv(OUT_DIR / "sdffarx1_hotspot_points.tsv", hotspot_points, nearest_fields)

    by_pin = Counter(row["pin_name"] for row in blocked)
    by_bucket = Counter(row["bucket20"] for row in blocked)
    by_nearest_type = Counter(row["nearest_type"] for row in nearest_rows)
    by_nearest_layer = Counter(row["nearest_layer"] for row in nearest_rows)
    by_hotspot_pin = Counter(row["pin_name"] for row in hotspot_points)

    radius_all = radius_counter(nearest_rows)
    radius_hotspot_points = radius_counter(hotspot_points)

    with (OUT_DIR / "sdffarx1_overlap_summary.rpt").open("w") as fp:
        fp.write("SDFFARX1_RVT blocked access / route DRC overlap summary\n\n")
        fp.write(f"blocked_report={BLOCKED_REPORT}\n")
        fp.write(f"drc_report={DRC_REPORT}\n")
        fp.write(f"hotspot_bbox={HOTSPOT}\n\n")

        fp.write(f"sdffarx1_blocked_point_count={len(blocked)}\n")
        fp.write(f"route_drc_marker_count={len(drc)}\n")
        fp.write(f"hotspot_drc_marker_count={len(hotspot_drc)}\n")
        fp.write(f"sdffarx1_blocked_points_inside_hotspot={len(hotspot_points)}\n")
        fp.write(f"sdffarx1_points_with_nearest_drc_inside_hotspot={len(near_hotspot_drc)}\n\n")

        fp.write("Nearest DRC radius counts, all SDFFARX1 points:\n")
        for key in ["<=1um", "<=2um", "<=5um", "<=10um", "<=25um", "<=50um"]:
            fp.write(f"  {key}: {radius_all[key]}\n")
        fp.write("\nNearest DRC radius counts, SDFFARX1 points inside hotspot:\n")
        for key in ["<=1um", "<=2um", "<=5um", "<=10um", "<=25um", "<=50um"]:
            fp.write(f"  {key}: {radius_hotspot_points[key]}\n")

        fp.write("\nBlocked points by pin:\n")
        for pin_name, count in by_pin.most_common():
            fp.write(f"  {pin_name}: {count}\n")

        fp.write("\nHotspot blocked points by pin:\n")
        for pin_name, count in by_hotspot_pin.most_common():
            fp.write(f"  {pin_name}: {count}\n")

        fp.write("\nNearest DRC type counts:\n")
        for error_type, count in by_nearest_type.most_common():
            fp.write(f"  {error_type}: {count}\n")

        fp.write("\nNearest DRC layer counts:\n")
        for error_layer, count in by_nearest_layer.most_common():
            fp.write(f"  {error_layer}: {count}\n")

        fp.write("\nTop SDFFARX1 blocked buckets:\n")
        for bucket, count in by_bucket.most_common(20):
            fp.write(f"  {bucket}: {count}\n")

        fp.write("\nSDFFARX1 hotspot blocked points:\n")
        for row in hotspot_points:
            fp.write(
                "  "
                f"{row['cell_name']} {row['pin_name']} "
                f"point=({row['point_x']},{row['point_y']}) "
                f"nearest={row['nearest_type']} {row['nearest_layer']} "
                f"dist={row['distance_um']}um\n"
            )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
