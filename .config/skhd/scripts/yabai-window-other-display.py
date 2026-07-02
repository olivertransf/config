#!/usr/bin/env python3
"""
Move focused window to the other display (typical 2-monitor setup).

`yabai -m window --display next` is sometimes wrong in one direction; sending
an explicit display index is usually symmetric. Falls back to next/prev.
"""
from __future__ import annotations

import json
import subprocess
import sys

YABAI = "/opt/homebrew/bin/yabai"


def query(*args: str):
    out = subprocess.check_output([YABAI, "-m", "query", *args], text=True)
    return json.loads(out)


def send(target: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [YABAI, "-m", "window", "--display", target],
        capture_output=True,
        text=True,
    )


def main() -> int:
    try:
        displays = query("--displays")
        win = query("--windows", "--window")
    except (subprocess.CalledProcessError, json.JSONDecodeError, FileNotFoundError):
        return 1

    indices = sorted(d["index"] for d in displays)
    if len(indices) < 2:
        return 1

    here = win.get("display")
    if here not in indices:
        here = indices[0]

    if len(indices) == 2:
        a, b = indices[0], indices[1]
        other = b if here == a else a
        for attempt in (str(other), "next", "prev"):
            r = send(attempt)
            if r.returncode == 0:
                return 0
        return 1

    pos = indices.index(here)
    nxt = indices[(pos + 1) % len(indices)]
    return 0 if send(str(nxt)).returncode == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
