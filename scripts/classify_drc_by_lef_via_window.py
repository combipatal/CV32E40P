#!/usr/bin/env python3
"""DRC-to-pin-access match를 LEF via-window class로 분류한다."""

import argparse
import csv
import re
from collections import Counter
from pathlib import Path

from analyze_lef_pin_via_windows import (
    center_window,
    parse_contact_codes,
    parse_lef,
    track_hits,
    window_status,
)


def parse_marker_context(path):
    refs = {}
    cell_re = re.compile(r"^\s*cell\s+(\S+)\s+ref=(\S+)\s+origin=([-0-9.]+)\s+([-0-9.]+)")
    for line in path.read_text(errors="ignore").splitlines():
        match = cell_re.match(line)
        if match:
            refs[match.group(1)] = match.group(2)
    return refs


def pin_verdict(macro, pin_name, req_x, req_y, track_start, track_pitch):
    shapes = [shape for shape in macro.pins.get(pin_name, []) if shape.layer == "M1"]
    if not shapes:
        return "NO_M1_PIN_SHAPES"

    any_window = False
    any_track_center = False
    for shape in shapes:
        wx1, wy1, wx2, wy2 = center_window(shape.rect, req_x, req_y)
        status = window_status((wx1, wy1, wx2, wy2))
        any_window = any_window or status == "HAS_LEGAL_CENTER_WINDOW"
        x_tracks = track_hits(wx1, wx2, track_start, track_pitch)
        y_tracks = track_hits(wy1, wy2, track_start, track_pitch)
        any_track_center = any_track_center or bool(x_tracks and y_tracks)

    if any_track_center:
        return "PIN_HAS_LEGAL_VIA1_TRACK_CENTER"
    if any_window:
        return "PIN_HAS_LEGAL_WINDOW_BUT_NO_DEFAULT_TRACK_CENTER"
    return "PIN_HAS_NO_LEGAL_VIA1_CENTER_WINDOW"


def class_name(ref, pin, verdict):
    if verdict == "PIN_HAS_NO_LEGAL_VIA1_CENTER_WINDOW":
        return "blocked_access_no_via_window"
    if verdict == "PIN_HAS_LEGAL_WINDOW_BUT_NO_DEFAULT_TRACK_CENTER":
        return "legal_window_no_default_track_center"
    if verdict == "PIN_HAS_LEGAL_VIA1_TRACK_CENTER" and pin == "A2" and (
        ref.startswith("NOR2") or ref.startswith("OR2")
    ):
        return "or_nor_a2_legal_track_edge_snapping"
    if verdict == "PIN_HAS_LEGAL_VIA1_TRACK_CENTER":
        return "legal_track_center_other"
    return "unclassified"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--match-tsv", required=True, type=Path)
    parser.add_argument("--marker-context", required=True, type=Path)
    parser.add_argument("--tech-file", required=True, type=Path)
    parser.add_argument("--hvt-lef", required=True, type=Path)
    parser.add_argument("--contact", default="VIA12SQ_C")
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--detail-out", required=True, type=Path)
    parser.add_argument("--m1-track-start", type=float, default=0.088)
    parser.add_argument("--m1-track-pitch", type=float, default=0.152)
    args = parser.parse_args()

    refs = parse_marker_context(args.marker_context)
    macros = parse_lef(args.hvt_lef)
    contacts = parse_contact_codes(args.tech_file)
    contact = contacts[args.contact]
    req_x = contact["cut_w"] / 2.0 + contact["lower_enc_w"]
    req_y = contact["cut_h"] / 2.0 + contact["lower_enc_h"]

    rows = list(csv.DictReader(args.match_tsv.open(), delimiter="\t"))
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.detail_out.parent.mkdir(parents=True, exist_ok=True)

    by_class = Counter()
    by_ref_pin = Counter()
    by_ref_pin_class = Counter()
    by_error_layer_class = Counter()
    by_unique_access = {}
    missing = Counter()
    details = []

    verdict_cache = {}
    for row in rows:
        cell = row["cell"]
        pin = row["pin"]
        ref = refs.get(cell)
        if ref is None:
            missing["cell_ref"] += 1
            ref = "UNKNOWN_REF"
            verdict = "MISSING_REF"
            klass = "unclassified"
        elif ref not in macros:
            missing["lef_macro"] += 1
            verdict = "MISSING_MACRO"
            klass = "unclassified"
        else:
            key = (ref, pin)
            if key not in verdict_cache:
                verdict_cache[key] = pin_verdict(
                    macros[ref],
                    pin,
                    req_x,
                    req_y,
                    args.m1_track_start,
                    args.m1_track_pitch,
                )
            verdict = verdict_cache[key]
            klass = class_name(ref, pin, verdict)

        by_class[klass] += 1
        by_ref_pin[(ref, pin)] += 1
        by_ref_pin_class[(ref, pin, klass)] += 1
        by_error_layer_class[(row["error_type"], row["error_layer"], klass)] += 1
        access_key = (cell, pin, row["access_x"], row["access_y"])
        by_unique_access.setdefault(access_key, (ref, pin, klass, verdict))
        details.append((row, ref, verdict, klass))

    with args.detail_out.open("w") as out:
        fields = list(rows[0].keys()) + ["ref", "via_window_verdict", "via_window_class"]
        writer = csv.DictWriter(out, fieldnames=fields, delimiter="\t")
        writer.writeheader()
        for row, ref, verdict, klass in details:
            item = dict(row)
            item["ref"] = ref
            item["via_window_verdict"] = verdict
            item["via_window_class"] = klass
            writer.writerow(item)

    unique_class = Counter(item[2] for item in by_unique_access.values())
    unique_ref_pin_class = Counter((item[0], item[1], item[2]) for item in by_unique_access.values())

    with args.out.open("w") as out:
        out.write("DRC matched pin classification by LEF via-window\n\n")
        out.write(f"match_tsv: {args.match_tsv}\n")
        out.write(f"marker_context: {args.marker_context}\n")
        out.write(f"tech_file: {args.tech_file}\n")
        out.write(f"hvt_lef: {args.hvt_lef}\n")
        out.write(f"contact: {args.contact}\n")
        out.write(f"required_center_margin_on_M1: x={req_x:.4f} y={req_y:.4f}\n")
        out.write(f"matched_marker_rows: {len(rows)}\n")
        out.write(f"unique_access_points: {len(by_unique_access)}\n\n")

        out.write("Missing inputs:\n")
        if missing:
            for key, value in missing.items():
                out.write(f"  {key}: {value}\n")
        else:
            out.write("  none\n")

        out.write("\nBy marker row class:\n")
        for key, value in by_class.most_common():
            out.write(f"  {value:5d} {key}\n")

        out.write("\nBy unique access point class:\n")
        for key, value in unique_class.most_common():
            out.write(f"  {value:5d} {key}\n")

        out.write("\nBy ref/pin/class marker rows:\n")
        for (ref, pin, klass), value in by_ref_pin_class.most_common(30):
            out.write(f"  {value:5d} {ref}/{pin} {klass}\n")

        out.write("\nBy ref/pin/class unique access points:\n")
        for (ref, pin, klass), value in unique_ref_pin_class.most_common(30):
            out.write(f"  {value:5d} {ref}/{pin} {klass}\n")

        out.write("\nBy error layer and class:\n")
        for (etype, layer, klass), value in by_error_layer_class.most_common(40):
            out.write(f"  {value:5d} {etype} {layer} {klass}\n")

        out.write("\nInterpretation:\n")
        out.write("  blocked_access_no_via_window is a true LEF pin-window problem for default VIA12SQ_C.\n")
        out.write("  legal_window_no_default_track_center is a track-grid mismatch problem.\n")
        out.write("  or_nor_a2_legal_track_edge_snapping has legal track centers, so remaining DRC likely comes from edge access plus generated VIA1/M2 snapping/check-grid behavior.\n")


if __name__ == "__main__":
    main()
