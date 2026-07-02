#!/usr/bin/env python3
"""
Map ⌃⌥ + arrow to yabai --resize so one modifier does both grow and shrink:
  • Arrow toward the shared split = grow
  • Opposite arrow = shrink

Uses window split-type / split-child when set; otherwise uses frame vs display center.
Applies resize via yabai-smart-resize.py (BSP + floating fallback).
"""
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

YABAI = "/opt/homebrew/bin/yabai"
STEP = 50
SMART = Path(__file__).resolve().parent / "yabai-smart-resize.py"


def yabai_json(*args: str) -> dict | list:
    out = subprocess.check_output([YABAI, "-m", "query", *args], text=True)
    return json.loads(out)


def spec_from_split(
    split_type: str,
    split_child: str,
    direction: str,
) -> str | None:
    """Return face:dx:dy or None to fall back to heuristic."""
    st = (split_type or "none").lower()
    sc = (split_child or "none").lower().replace(" ", "_")

    if st == "vertical" and sc in ("first_child", "second_child"):
        if direction not in ("left", "right"):
            return None
        if sc == "second_child":
            if direction == "left":
                return f"left:-{STEP}:0"
            return f"left:{STEP}:0"
        if direction == "right":
            return f"right:{STEP}:0"
        return f"right:-{STEP}:0"

    if st == "horizontal" and sc in ("first_child", "second_child"):
        if direction not in ("up", "down"):
            return None
        if sc == "second_child":
            if direction == "up":
                return f"top:0:-{STEP}"
            return f"top:0:{STEP}"
        if direction == "down":
            return f"bottom:0:{STEP}"
        return f"bottom:0:-{STEP}"

    return None


def spec_from_heuristic(win: dict, direction: str) -> str:
    displays = yabai_json("--displays")
    did = win["display"]
    disp = next(d for d in displays if d["index"] == did)
    df = disp["frame"]
    wf = win["frame"]
    cx = wf["x"] + wf["w"] / 2
    cy = wf["y"] + wf["h"] / 2
    mx = df["x"] + df["w"] / 2
    my = df["y"] + df["h"] / 2

    if direction in ("left", "right"):
        if cx < mx:
            if direction == "right":
                return f"right:{STEP}:0"
            return f"right:-{STEP}:0"
        if direction == "left":
            return f"left:-{STEP}:0"
        return f"left:{STEP}:0"

    if cy < my:
        if direction == "down":
            return f"bottom:0:{STEP}"
        return f"bottom:0:-{STEP}"
    if direction == "up":
        return f"top:0:-{STEP}"
    return f"top:0:{STEP}"


def main() -> int:
    if len(sys.argv) != 2 or sys.argv[1] not in ("left", "right", "up", "down"):
        print("usage: yabai-arrow-resize.py left|right|up|down", file=sys.stderr)
        return 2

    direction = sys.argv[1]
    win = yabai_json("--windows", "--window")

    spec = spec_from_split(
        str(win.get("split-type", "none")),
        str(win.get("split-child", "none")),
        direction,
    )
    if spec is None:
        spec = spec_from_heuristic(win, direction)

    return subprocess.call([sys.executable, str(SMART), spec])


if __name__ == "__main__":
    raise SystemExit(main())
