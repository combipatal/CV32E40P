#!/usr/bin/env python3
"""LEF pin metal이 기본 VIA1 contact를 받을 수 있는지 정적 분석한다."""

import argparse
import re
from collections import defaultdict
from pathlib import Path


class PinShape:
    def __init__(self, layer, rect):
        self.layer = layer
        self.rect = rect


class Macro:
    def __init__(self, name):
        self.name = name
        self.size_x = 0.0
        self.size_y = 0.0
        self.pins = defaultdict(list)


def parse_lef(path):
    macros = {}
    current = None
    pin_name = None
    layer = None

    macro_re = re.compile(r"^\s*MACRO\s+(\S+)")
    pin_re = re.compile(r"^\s*PIN\s+(\S+)")
    layer_re = re.compile(r"^\s*LAYER\s+(\S+)\s*;")
    rect_re = re.compile(
        r"^\s*RECT\s+([-0-9.]+)\s+([-0-9.]+)\s+([-0-9.]+)\s+([-0-9.]+)\s*;"
    )
    size_re = re.compile(r"^\s*SIZE\s+([-0-9.]+)\s+BY\s+([-0-9.]+)\s*;")

    for line in path.read_text(errors="ignore").splitlines():
        if current is None:
            match = macro_re.match(line)
            if match:
                current = Macro(match.group(1))
            continue

        if line.strip() == f"END {current.name}":
            macros[current.name] = current
            current = None
            pin_name = None
            layer = None
            continue

        match = size_re.match(line)
        if match:
            current.size_x = float(match.group(1))
            current.size_y = float(match.group(2))
            continue

        match = pin_re.match(line)
        if match:
            pin_name = match.group(1)
            layer = None
            continue

        if pin_name and line.strip() == f"END {pin_name}":
            pin_name = None
            layer = None
            continue

        if not pin_name:
            continue

        match = layer_re.match(line)
        if match:
            layer = match.group(1)
            continue

        match = rect_re.match(line)
        if match and layer:
            rect = tuple(float(match.group(i)) for i in range(1, 5))
            current.pins[pin_name].append(PinShape(layer, rect))

    return macros


def parse_contact_codes(path):
    text = path.read_text(errors="ignore")
    block_re = re.compile(r'ContactCode\s+"([^"]+)"\s*\{(.*?)\n\}', re.S)
    attr_re = re.compile(r"^\s*(\S+)\s*=\s*(\S+)", re.M)
    contacts = {}

    for name, body in block_re.findall(text):
        attrs = {key: value for key, value in attr_re.findall(body)}
        required = [
            "cutWidth",
            "cutHeight",
            "upperLayerEncWidth",
            "upperLayerEncHeight",
            "lowerLayerEncWidth",
            "lowerLayerEncHeight",
        ]
        if not all(key in attrs for key in required):
            continue

        contacts[name] = {
            "cut_w": float(attrs["cutWidth"]),
            "cut_h": float(attrs["cutHeight"]),
            "upper_enc_w": float(attrs["upperLayerEncWidth"]),
            "upper_enc_h": float(attrs["upperLayerEncHeight"]),
            "lower_enc_w": float(attrs["lowerLayerEncWidth"]),
            "lower_enc_h": float(attrs["lowerLayerEncHeight"]),
            "lower_layer": attrs.get("lowerLayer", "").strip('"'),
            "upper_layer": attrs.get("upperLayer", "").strip('"'),
            "is_default": attrs.get("isDefaultContact", "0") == "1",
            "excluded_for_signal": attrs.get("excludedForSignalRoute", "0") == "1",
        }
    return contacts


def parse_lef_arg(value):
    if "=" not in value:
        raise argparse.ArgumentTypeError("--lef must be tag=path")
    tag, path = value.split("=", 1)
    return tag, Path(path)


def parse_target(value):
    if ":" not in value or "/" not in value:
        raise argparse.ArgumentTypeError("--target must be tag:MACRO/PIN")
    tag, rest = value.split(":", 1)
    macro, pin = rest.split("/", 1)
    return tag, macro, pin


def center_window(rect, req_x, req_y):
    x1, y1, x2, y2 = rect
    return x1 + req_x, y1 + req_y, x2 - req_x, y2 - req_y


def window_status(window):
    wx1, wy1, wx2, wy2 = window
    if wx1 <= wx2 and wy1 <= wy2:
        return "HAS_LEGAL_CENTER_WINDOW"
    if wx1 > wx2 and wy1 > wy2:
        return "NO_WINDOW_X_AND_Y"
    if wx1 > wx2:
        return "NO_WINDOW_X"
    return "NO_WINDOW_Y"


def track_hits(lo, hi, start, pitch):
    if lo > hi:
        return []
    first = int((lo - start) // pitch) - 2
    hits = []
    for idx in range(first, first + 200):
        pos = start + idx * pitch
        if lo - 1e-9 <= pos <= hi + 1e-9:
            hits.append(pos)
        if pos > hi + pitch:
            break
    return hits


def fmt(value):
    return f"{value:.4f}"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--tech-file", required=True)
    parser.add_argument("--contact", default="VIA12SQ_C")
    parser.add_argument("--lef", action="append", type=parse_lef_arg, required=True)
    parser.add_argument("--target", action="append", type=parse_target, required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--m1-track-start", type=float, default=0.088)
    parser.add_argument("--m1-track-pitch", type=float, default=0.152)
    args = parser.parse_args()

    contacts = parse_contact_codes(Path(args.tech_file))
    if args.contact not in contacts:
        raise SystemExit(f"missing contact code: {args.contact}")
    contact = contacts[args.contact]

    lefs = {}
    for tag, path in args.lef:
        lefs[tag] = (path, parse_lef(path))

    req_x = contact["cut_w"] / 2.0 + contact["lower_enc_w"]
    req_y = contact["cut_h"] / 2.0 + contact["lower_enc_h"]

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    with out_path.open("w") as out:
        out.write("LEF pin via-center window analysis\n\n")
        out.write(f"tech_file: {args.tech_file}\n")
        out.write(f"contact: {args.contact}\n")
        out.write(
            "contact_detail: lower={} upper={} cut={}x{} lower_enc={}x{} upper_enc={}x{} default={} excluded_for_signal={}\n".format(
                contact["lower_layer"],
                contact["upper_layer"],
                fmt(contact["cut_w"]),
                fmt(contact["cut_h"]),
                fmt(contact["lower_enc_w"]),
                fmt(contact["lower_enc_h"]),
                fmt(contact["upper_enc_w"]),
                fmt(contact["upper_enc_h"]),
                contact["is_default"],
                contact["excluded_for_signal"],
            )
        )
        out.write(f"required_center_margin_on_M1: x={fmt(req_x)} y={fmt(req_y)}\n")
        out.write(f"m1_track_grid: start={fmt(args.m1_track_start)} pitch={fmt(args.m1_track_pitch)}\n\n")

        for tag, macro_name, pin_name in args.target:
            out.write(f"Target {tag}:{macro_name}/{pin_name}\n")
            if tag not in lefs:
                out.write("  status: MISSING_LEF_TAG\n\n")
                continue

            lef_path, macros = lefs[tag]
            out.write(f"  lef: {lef_path}\n")
            if macro_name not in macros:
                out.write("  status: MISSING_MACRO\n\n")
                continue

            macro = macros[macro_name]
            shapes = [shape for shape in macro.pins.get(pin_name, []) if shape.layer == "M1"]
            out.write(f"  macro_size: {fmt(macro.size_x)} x {fmt(macro.size_y)}\n")
            out.write(f"  m1_shape_count: {len(shapes)}\n")
            if not shapes:
                out.write("  status: NO_M1_PIN_SHAPES\n\n")
                continue

            any_window = False
            any_track_center = False
            for index, shape in enumerate(shapes, start=1):
                x1, y1, x2, y2 = shape.rect
                wx1, wy1, wx2, wy2 = center_window(shape.rect, req_x, req_y)
                status = window_status((wx1, wy1, wx2, wy2))
                x_tracks = track_hits(wx1, wx2, args.m1_track_start, args.m1_track_pitch)
                y_tracks = track_hits(wy1, wy2, args.m1_track_start, args.m1_track_pitch)
                rect_has_track_center = bool(x_tracks and y_tracks)
                any_window = any_window or status == "HAS_LEGAL_CENTER_WINDOW"
                any_track_center = any_track_center or rect_has_track_center
                out.write(
                    "  shape_{}: rect=({} {} {} {}) size={}x{} center_window=({} {} {} {}) status={} m1_track_center={}\n".format(
                        index,
                        fmt(x1),
                        fmt(y1),
                        fmt(x2),
                        fmt(y2),
                        fmt(x2 - x1),
                        fmt(y2 - y1),
                        fmt(wx1),
                        fmt(wy1),
                        fmt(wx2),
                        fmt(wy2),
                        status,
                        rect_has_track_center,
                    )
                )
                if x_tracks or y_tracks:
                    out.write(
                        "    track_hits: x={} y={}\n".format(
                            ",".join(fmt(v) for v in x_tracks[:8]) or "none",
                            ",".join(fmt(v) for v in y_tracks[:8]) or "none",
                        )
                    )

            if any_track_center:
                verdict = "PIN_HAS_LEGAL_VIA1_TRACK_CENTER"
            elif any_window:
                verdict = "PIN_HAS_LEGAL_WINDOW_BUT_NO_DEFAULT_TRACK_CENTER"
            else:
                verdict = "PIN_HAS_NO_LEGAL_VIA1_CENTER_WINDOW"
            out.write(f"  verdict: {verdict}\n\n")

        out.write("Interpretation:\n")
        out.write("  PIN_HAS_NO_LEGAL_VIA1_CENTER_WINDOW means the LEF M1 pin rectangle is too narrow for the default VIA12SQ_C M1 enclosure.\n")
        out.write("  PIN_HAS_LEGAL_WINDOW_BUT_NO_DEFAULT_TRACK_CENTER means geometry permits a via, but the default M1 track grid does not land inside the legal window.\n")
        out.write("  PIN_HAS_LEGAL_VIA1_TRACK_CENTER means the raw LEF pin rectangle is probably not the only cause; focus on access snapping, via policy, or local obstructions.\n")


if __name__ == "__main__":
    main()
