#!/usr/bin/env python3
"""
report_cell_pin_access -details 결과를 ref/cell/pin 단위로 요약한다.

입력:
  argv[1] = report_cell_pin_access.same_refs.details.rpt
  argv[2] = same_ref_cells.list
  argv[3] = output directory
"""

import re
import sys
from collections import Counter
from pathlib import Path


CELL_RE = re.compile(r"^Cell\s+(.+)$")
PIN_RE = re.compile(r"^\s+Pin\s+(\S+)\s+--")
BLOCKED_RE = re.compile(r"^\s+Blocked\s+(\S+)\s+(\d+):")
POINT_RE = re.compile(r"\{([-0-9.]+)\s+([-0-9.]+)\}")


def read_ref_map(path):
    ref_map = {}
    with path.open() as fp:
        for raw in fp:
            line = raw.strip()
            if not line:
                continue
            if " ref=" not in line:
                continue
            cell_name, rest = line.split(" ref=", 1)
            ref_name = rest.split()[0]
            ref_map[cell_name] = ref_name
    return ref_map


def parse_report(path, ref_map):
    rows = []
    current_cell = ""
    current_pin = ""

    with path.open() as fp:
        for raw in fp:
            line = raw.rstrip("\n")
            m_cell = CELL_RE.match(line)
            if m_cell:
                current_cell = m_cell.group(1)
                current_pin = ""
                continue

            m_pin = PIN_RE.match(line)
            if m_pin:
                current_pin = m_pin.group(1)
                continue

            m_blocked = BLOCKED_RE.match(line)
            if not m_blocked:
                continue

            blocked_count = int(m_blocked.group(2))
            if blocked_count == 0:
                continue

            ref_name = ref_map.get(current_cell, "UNKNOWN_REF")
            points = POINT_RE.findall(line)
            rows.append(
                {
                    "ref_name": ref_name,
                    "cell_name": current_cell,
                    "pin_name": current_pin,
                    "blocked_count": blocked_count,
                    "point_count": len(points),
                    "detail": line.strip(),
                }
            )

    return rows


def write_outputs(rows, out_dir):
    out_dir.mkdir(parents=True, exist_ok=True)

    by_ref = Counter(row["ref_name"] for row in rows)
    by_pin = Counter(row["pin_name"] for row in rows)
    by_ref_pin = Counter((row["ref_name"], row["pin_name"]) for row in rows)

    with (out_dir / "blocked_access.by_ref_cell_pin.rpt").open("w") as fp:
        for row in rows:
            fp.write(
                "{} | {} | {} | {}\n".format(
                    row["ref_name"],
                    row["cell_name"],
                    row["pin_name"],
                    row["detail"],
                )
            )

    with (out_dir / "blocked_access.compact_summary.rpt").open("w") as fp:
        fp.write("Blocked access compact summary\n\n")
        fp.write("line_level_blocked_entries={}\n\n".format(len(rows)))
        fp.write("By ref:\n")
        for key, value in by_ref.most_common():
            fp.write("{:7d} {}\n".format(value, key))
        fp.write("\nBy pin:\n")
        for key, value in by_pin.most_common():
            fp.write("{:7d} {}\n".format(value, key))
        fp.write("\nBy ref/pin:\n")
        for (ref_name, pin_name), value in by_ref_pin.most_common():
            fp.write("{:7d} {}/{}\n".format(value, ref_name, pin_name))


def main(argv):
    if len(argv) != 4:
        sys.stderr.write("usage: summarize_cell_pin_access.py <details.rpt> <same_ref_cells.list> <out_dir>\n")
        return 2

    detail_path = Path(argv[1])
    ref_path = Path(argv[2])
    out_dir = Path(argv[3])

    ref_map = read_ref_map(ref_path)
    rows = parse_report(detail_path, ref_map)
    write_outputs(rows, out_dir)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
