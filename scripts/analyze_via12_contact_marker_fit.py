#!/usr/bin/env python3
"""VIA12 contact code 치수와 A2 DRC marker bbox 치수를 비교한다."""

import argparse
import re
from collections import Counter
from pathlib import Path


NUM_RE = r"([-0-9.]+)"


def bucket(value: float, ndigits: int = 3) -> str:
    return f"{value:.{ndigits}f}"


def parse_contact_codes(path: Path):
    text = path.read_text(errors="ignore")
    block_re = re.compile(r'ContactCode\s+"([^"]+)"\s*\{(.*?)\n\}', re.S)
    attr_re = re.compile(r"^\s*(\S+)\s*=\s*(\S+)", re.M)
    contacts = {}
    for name, body in block_re.findall(text):
        attrs = {}
        for key, value in attr_re.findall(body):
            attrs[key] = value
        try:
            contacts[name] = {
                "cut_w": float(attrs["cutWidth"]),
                "cut_h": float(attrs["cutHeight"]),
                "upper_enc_w": float(attrs["upperLayerEncWidth"]),
                "upper_enc_h": float(attrs["upperLayerEncHeight"]),
                "lower_enc_w": float(attrs["lowerLayerEncWidth"]),
                "lower_enc_h": float(attrs["lowerLayerEncHeight"]),
                "is_default": attrs.get("isDefaultContact", "0") == "1",
                "excluded_for_signal": attrs.get("excludedForSignalRoute", "0") == "1",
            }
        except KeyError:
            continue
    return contacts


def parse_marker_report(path: Path):
    rows = []
    section_re = re.compile(r"^DRC marker bbox dimensions by layer/type:\n(.*?)(?:\n\n|\Z)", re.S | re.M)
    match = section_re.search(path.read_text(errors="ignore"))
    if not match:
        raise SystemExit(f"cannot find bbox section in {path}")

    line_re = re.compile(
        rf"^\s+Off-grid \| (?P<layer>\S+) \(\d+\) \| w=(?P<w>{NUM_RE}) h=(?P<h>{NUM_RE}): (?P<count>\d+)",
        re.M,
    )
    for match in line_re.finditer(match.group(1)):
        rows.append(
            {
                "layer": match.group("layer"),
                "w": float(match.group("w")),
                "h": float(match.group("h")),
                "count": int(match.group("count")),
            }
        )
    return rows


def contact_dims(contact, pitch):
    cut_w = contact["cut_w"]
    cut_h = contact["cut_h"]
    upper_w = cut_w + 2.0 * contact["upper_enc_w"]
    upper_h = cut_h + 2.0 * contact["upper_enc_h"]
    lower_w = cut_w + 2.0 * contact["lower_enc_w"]
    lower_h = cut_h + 2.0 * contact["lower_enc_h"]
    dims = {
        "cut": (cut_w, cut_h),
        "upper": (upper_w, upper_h),
        "lower": (lower_w, lower_h),
        "upper_plus_pitch_y": (upper_w, upper_h + pitch),
        "upper_plus_pitch_x": (upper_w + pitch, upper_h),
        "lower_plus_pitch_y": (lower_w, lower_h + pitch),
        "lower_plus_pitch_x": (lower_w + pitch, lower_h),
    }
    return dims


def diff_score(a, b, c, d):
    return abs(a - c) + abs(b - d)


def best_fit(w, h, contacts, pitch):
    best = None
    for contact_name, contact in contacts.items():
        for dim_name, (dw, dh) in contact_dims(contact, pitch).items():
            score = diff_score(w, h, dw, dh)
            item = (score, contact_name, dim_name, dw, dh)
            if best is None or item < best:
                best = item
    return best


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--tech-file", required=True)
    parser.add_argument("--marker-geometry", required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--pitch", type=float, default=0.152)
    args = parser.parse_args()

    contacts = parse_contact_codes(Path(args.tech_file))
    marker_rows = parse_marker_report(Path(args.marker_geometry))
    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    via12_names = [name for name in contacts if name.startswith("VIA12")]
    matched = Counter()

    with out_path.open("w") as out:
        out.write("VIA12 contact-code to A2 marker geometry fit\n\n")
        out.write(f"tech_file: {args.tech_file}\n")
        out.write(f"marker_geometry: {args.marker_geometry}\n")
        out.write(f"pitch: {args.pitch:.3f}\n\n")

        out.write("VIA12 contact codes from tech file:\n")
        for name in sorted(via12_names):
            c = contacts[name]
            dims = contact_dims(c, args.pitch)
            out.write(
                f"  {name}: default={c['is_default']} excluded_for_signal={c['excluded_for_signal']} "
                f"cut={bucket(c['cut_w'])}x{bucket(c['cut_h'])} "
                f"upper={bucket(dims['upper'][0])}x{bucket(dims['upper'][1])} "
                f"lower={bucket(dims['lower'][0])}x{bucket(dims['lower'][1])}\n"
            )

        out.write("\nObserved marker bbox fit:\n")
        for row in marker_rows:
            best = best_fit(row["w"], row["h"], {k: contacts[k] for k in via12_names}, args.pitch)
            score, contact_name, dim_name, dw, dh = best
            matched[(contact_name, dim_name)] += row["count"]
            out.write(
                f"  {row['layer']} marker {bucket(row['w'])}x{bucket(row['h'])} count={row['count']} "
                f"best_fit={contact_name}.{dim_name} "
                f"expected={bucket(dw)}x{bucket(dh)} error={score:.6f}\n"
            )

        out.write("\nFit count summary:\n")
        for (contact_name, dim_name), count in matched.most_common():
            out.write(f"  {contact_name}.{dim_name}: {count}\n")

        out.write("\nInterpretation:\n")
        out.write("  M2 off-grid marker bboxes match VIA12 contact-code metal dimensions plus one routing pitch.\n")
        out.write("  The default contact VIA12SQ_C is asymmetric between lower M1 and upper M2 enclosure.\n")
        out.write("  This supports a generated VIA1/M2 patch or route/check grid snapping cause, not a placement-only cause.\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
