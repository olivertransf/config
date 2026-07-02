#!/usr/bin/env sh
# Hammerspoon-style snap: yabai --grid only affects floated windows; float first if tiled.
# Usage: yabai-apply-grid.sh ROWS:COLS:X:Y:W:H
set -eu
GRID="${1:?grid arg}"
export YABAI_GRID="$GRID"
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

exec python3 -c '
import json, os, shutil, subprocess, sys

grid = os.environ["YABAI_GRID"]
yabai = shutil.which("yabai")
if not yabai:
    for p in ("/opt/homebrew/bin/yabai", "/usr/local/bin/yabai"):
        if os.path.isfile(p) and os.access(p, os.X_OK):
            yabai = p
            break
if not yabai:
    sys.exit(0)

def run(args):
    subprocess.run(args, capture_output=True, text=True)

try:
    out = subprocess.check_output([yabai, "-m", "query", "--windows", "--window"], text=True)
except (subprocess.CalledProcessError, FileNotFoundError):
    sys.exit(0)
w = json.loads(out)
if not w.get("is-floating"):
    run([yabai, "-m", "window", "--toggle", "float"])
run([yabai, "-m", "window", "--grid", grid])
'
