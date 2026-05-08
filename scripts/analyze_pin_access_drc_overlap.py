#!/usr/bin/env python3
"""
blocked access point와 route DRC bbox 위치를 비교하는 report-only 분석기.

ICC2를 다시 돌리지 않고, 이미 생성된 text report만 읽어서 다음을 만든다.
  1. blocked access point table
  2. DRC marker table
  3. blocked access별 nearest DRC marker
  4. 50um hotspot bucket overlap summary
"""

import math
import re
from collections import Counter, defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

BLOCKED_REPORT = ROOT / "7_Backend_ICC2/4_Report/trials/pin_access_blocked_detail/99_pin_access/blocked_access.by_ref_cell_pin.rpt"
DRC_REPORT = ROOT / "7_Backend_ICC2/4_Report/06_route/drc_detail/drc.detailed.rpt"
OUT_DIR = ROOT / "7_Backend_ICC2/4_Report/trials/pin_access_drc_overlap/99_overlap"

POINT_RE = re.compile(r"\{([-0-9.]+)\s+([-0-9.]+)\}")


def bucket50(x: float, y: float) -> str:
    bx = int(math.floor(x / 50.0) * 50)
    by = int(math.floor(y / 50.0) * 50)
    return f"{bx:03d}-{bx + 50:03d},{by:03d}-{by + 50:03d}"


def parse_blocked_points():
    rows = []

    with BLOCKED_REPORT.open() as fp:
        for line_no, line in enumerate(fp, start=1):
            line = line.rstrip("\n")
            parts = [part.strip() for part in line.split("|")]
            if len(parts) < 4:
                continue

            ref_name, cell_name, pin_name, detail = parts[:4]
            points = POINT_RE.findall(detail)
            if not points:
                continue

            for idx, (x_str, y_str) in enumerate(points, start=1):
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
                        "bucket50": bucket50(x, y),
                        "detail": detail,
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
                        "bucket50": bucket50(cx, cy),
                    }
                )
                rows.append(dict(current))
                current = {}

    return rows


def distance(point, marker):
    px = float(point["x"])
    py = float(point["y"])
    mx = float(marker["cx"])
    my = float(marker["cy"])
    return math.hypot(px - mx, py - my)


def write_tsv(path, rows, fields):
    with path.open("w") as fp:
        fp.write("\t".join(fields) + "\n")
        for row in rows:
            fp.write("\t".join(str(row.get(field, "")) for field in fields) + "\n")


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    blocked_points = parse_blocked_points()
    drc_markers = parse_drc_markers()

    nearest_rows = []
    radius_counts = Counter()
    nearest_type_counts = Counter()
    nearest_layer_counts = Counter()

    for point in blocked_points:
        nearest = min(drc_markers, key=lambda marker: distance(point, marker))
        dist = distance(point, nearest)
        if dist <= 2.0:
            radius_counts["<=2um"] += 1
        if dist <= 5.0:
            radius_counts["<=5um"] += 1
        if dist <= 10.0:
            radius_counts["<=10um"] += 1
        if dist <= 25.0:
            radius_counts["<=25um"] += 1
        if dist <= 50.0:
            radius_counts["<=50um"] += 1

        nearest_type_counts[str(nearest.get("error_type", ""))] += 1
        nearest_layer_counts[str(nearest.get("error_layer", ""))] += 1

        nearest_rows.append(
            {
                "ref_name": point["ref_name"],
                "cell_name": point["cell_name"],
                "pin_name": point["pin_name"],
                "point_x": f"{float(point['x']):.4f}",
                "point_y": f"{float(point['y']):.4f}",
                "point_bucket50": point["bucket50"],
                "nearest_error_id": nearest.get("error_id", ""),
                "nearest_type": nearest.get("error_type", ""),
                "nearest_layer": nearest.get("error_layer", ""),
                "nearest_cx": f"{float(nearest['cx']):.4f}",
                "nearest_cy": f"{float(nearest['cy']):.4f}",
                "nearest_bucket50": nearest.get("bucket50", ""),
                "distance_um": f"{dist:.4f}",
            }
        )

    blocked_bucket_counts = Counter(str(row["bucket50"]) for row in blocked_points)
    drc_bucket_counts = Counter(str(row["bucket50"]) for row in drc_markers)
    overlap_buckets = sorted(
        set(blocked_bucket_counts) & set(drc_bucket_counts),
        key=lambda bucket: (-(blocked_bucket_counts[bucket] + drc_bucket_counts[bucket]), bucket),
    )

    by_ref_pin = Counter((str(row["ref_name"]), str(row["pin_name"])) for row in blocked_points)

    write_tsv(
        OUT_DIR / "blocked_access_points.tsv",
        blocked_points,
        ["ref_name", "cell_name", "pin_name", "x", "y", "bucket50", "line_no", "point_index"],
    )
    write_tsv(
        OUT_DIR / "drc_markers.tsv",
        drc_markers,
        ["error_id", "error_type", "error_layer", "cx", "cy", "bucket50", "x1", "y1", "x2", "y2"],
    )
    write_tsv(
        OUT_DIR / "nearest_drc_per_blocked_point.tsv",
        nearest_rows,
        [
            "ref_name",
            "cell_name",
            "pin_name",
            "point_x",
            "point_y",
            "point_bucket50",
            "nearest_error_id",
            "nearest_type",
            "nearest_layer",
            "nearest_cx",
            "nearest_cy",
            "nearest_bucket50",
            "distance_um",
        ],
    )

    with (OUT_DIR / "hotspot_overlap_50um.rpt").open("w") as fp:
        fp.write("50um bucket overlap between blocked access points and route DRC markers\n\n")
        fp.write("bucket50 | blocked_points | drc_markers\n")
        fp.write("----------------------------------------\n")
        for bucket in overlap_buckets:
            fp.write(f"{bucket} | {blocked_bucket_counts[bucket]} | {drc_bucket_counts[bucket]}\n")

    with (OUT_DIR / "overlap_summary.rpt").open("w") as fp:
        fp.write("Pin access / DRC overlap summary\n\n")
        fp.write(f"blocked_point_count={len(blocked_points)}\n")
        fp.write(f"drc_marker_count={len(drc_markers)}\n")
        fp.write(f"overlap_bucket50_count={len(overlap_buckets)}\n")
        fp.write("\nNearest DRC radius counts:\n")
        for key in ["<=2um", "<=5um", "<=10um", "<=25um", "<=50um"]:
            fp.write(f"  {key}: {radius_counts[key]}\n")
        fp.write("\nNearest DRC type counts:\n")
        for key, value in nearest_type_counts.most_common():
            fp.write(f"  {key}: {value}\n")
        fp.write("\nNearest DRC layer counts:\n")
        for key, value in nearest_layer_counts.most_common():
            fp.write(f"  {key}: {value}\n")
        fp.write("\nBlocked points by ref/pin:\n")
        for (ref_name, pin_name), value in by_ref_pin.most_common():
            fp.write(f"  {ref_name}/{pin_name}: {value}\n")
        fp.write("\nTop blocked access buckets:\n")
        for bucket, value in blocked_bucket_counts.most_common(20):
            fp.write(f"  {bucket}: blocked_points={value}, drc_markers={drc_bucket_counts[bucket]}\n")
        fp.write("\nTop DRC buckets:\n")
        for bucket, value in drc_bucket_counts.most_common(20):
            fp.write(f"  {bucket}: drc_markers={value}, blocked_points={blocked_bucket_counts[bucket]}\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
