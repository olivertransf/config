#!/usr/bin/env python3
"""
Try `yabai -m window --resize <face:dx:dy>` (BSP). If that fails, apply the
same geometry change for floating windows using abs move + resize.

BSP-only failures (e.g. iTerm floating) show up as 'bsp node fence' in stderr.
"""
from __future__ import annotations

import json
import subprocess
import sys

YABAI = "/opt/homebrew/bin/yabai"
MIN_W = 200
MIN_H = 120


def yabai(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run([YABAI, "-m", *args], capture_output=True, text=True)


def bsp_resize_failed(res: subprocess.CompletedProcess[str]) -> bool:
    blob = (res.stderr or "") + (res.stdout or "")
    b = blob.lower()
    if res.returncode != 0:
        return True
    return any(
        s in b
        for s in (
            "fence",
            "cannot locate",
            "unable to",
            "cannot resize",
        )
    )


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: yabai-smart-resize.py 'left:-50:0'", file=sys.stderr)
        return 2

    spec = sys.argv[1]
    parts = spec.split(":")
    if len(parts) != 3:
        print("expected face:dx:dy", file=sys.stderr)
        return 2

    face, dx_s, dy_s = parts
    try:
        dx, dy = int(dx_s), int(dy_s)
    except ValueError:
        return 2

    r = yabai("window", "--resize", spec)
    if not bsp_resize_failed(r):
        return 0

    q = yabai("query", "--windows", "--window")
    if q.returncode != 0:
        return 1
    win = json.loads(q.stdout)
    if not win.get("is-floating"):
        return 1

    f = win["frame"]
    x, y, w, h = int(f["x"]), int(f["y"]), int(f["w"]), int(f["h"])

    if face == "left":
        x, w = x + dx, w - dx
    elif face == "right":
        w = w + dx
    elif face == "top":
        y, h = y + dy, h - dy
    elif face == "bottom":
        h = h + dy
    else:
        return 1

    w = max(MIN_W, w)
    h = max(MIN_H, h)

    yabai("window", "--resize", f"abs:{w}:{h}")
    yabai("window", "--move", f"abs:{x}:{y}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
