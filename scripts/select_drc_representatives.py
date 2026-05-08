#!/usr/bin/env python3
"""
ICC2 detailed DRC report에서 대표 marker를 고른다.

출력은 두 개다.
  1. all_drc_markers.tsv: 전체 marker 좌표 테이블
  2. representative_drc_markers.tsv: type/layer별 앞쪽 대표 marker
"""

import math
import re
from collections import Counter, defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DRC_REPORT = ROOT / "7_Backend_ICC2/4_Report/06_route/drc_detail/drc.detailed.rpt"
OUT_DIR = ROOT / "7_Backend_ICC2/4_Report/trials/drc_marker_context/99_marker_context"

POINT_RE = re.compile(r"\{([-0-9.]+)\s+([-0-9.]+)\}")


def bucket20(x: float, y: float) -> str:
    bx = int(math.floor(x / 20.0) * 20)
    by = int(math.floor(y / 20.0) * 20)
    return f"{bx:03d}-{bx + 20:03d},{by:03d}-{by + 20:03d}"


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
                    }
                )
                rows.append(dict(current))
                current = {}

    return rows


def write_tsv(path: Path, rows, fields):
    with path.open("w") as fp:
        fp.write("\t".join(fields) + "\n")
        for row in rows:
            fp.write("\t".join(str(row.get(field, "")) for field in fields) + "\n")


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    markers = parse_drc_markers()

    fields = [
        "tag",
        "error_id",
        "error_type",
        "error_layer",
        "cx",
        "cy",
        "bucket20",
        "x1",
        "y1",
        "x2",
        "y2",
    ]

    by_type_layer = defaultdict(list)
    for marker in markers:
        by_type_layer[(marker["error_type"], marker["error_layer"])].append(marker)

    representatives = []
    seen_ids = set()
    for (error_type, error_layer), group in sorted(by_type_layer.items()):
        for idx, marker in enumerate(group[:3], start=1):
            row = dict(marker)
            row["tag"] = f"{error_type.replace(' ', '_')}_{error_layer.replace(' ', '_')}_{idx}"
            representatives.append(row)
            seen_ids.add(row["error_id"])

    bucket_counts = Counter(str(row["bucket20"]) for row in markers)
    by_bucket = defaultdict(list)
    for marker in markers:
        by_bucket[str(marker["bucket20"])].append(marker)

    for bucket, _count in bucket_counts.most_common(5):
        for idx, marker in enumerate(by_bucket[bucket][:3], start=1):
            if marker["error_id"] in seen_ids:
                continue
            row = dict(marker)
            safe_bucket = bucket.replace(",", "_").replace("-", "to")
            row["tag"] = f"Hotspot_{safe_bucket}_{idx}"
            representatives.append(row)
            seen_ids.add(row["error_id"])

    write_tsv(OUT_DIR / "all_drc_markers.tsv", markers, fields[1:])
    write_tsv(OUT_DIR / "representative_drc_markers.tsv", representatives, fields)

    type_layer_counts = Counter((row["error_type"], row["error_layer"]) for row in markers)

    with (OUT_DIR / "representative_summary.rpt").open("w") as fp:
        fp.write("DRC representative marker summary\n\n")
        fp.write(f"drc_marker_count={len(markers)}\n")
        fp.write(f"representative_count={len(representatives)}\n")
        fp.write("\nBy type/layer:\n")
        for (error_type, error_layer), count in type_layer_counts.most_common():
            fp.write(f"  {error_type} | {error_layer}: {count}\n")
        fp.write("\nTop 20um buckets:\n")
        for bucket, count in bucket_counts.most_common(20):
            fp.write(f"  {bucket}: {count}\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
