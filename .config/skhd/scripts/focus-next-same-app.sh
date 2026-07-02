#!/usr/bin/env sh
# Cycle focus among visible windows of the frontmost app (Hammerspoon cmd+alt+ctrl+T).
exec python3 -c '
import json, subprocess, sys

def q(args):
    return json.loads(subprocess.check_output(["yabai", "-m", "query"] + args, text=True))

try:
    w = q(["--windows", "--window"])
except subprocess.CalledProcessError:
    sys.exit(0)
app, wid = w.get("app"), w.get("id")
if not app or wid is None:
    sys.exit(0)
visible = [
    x for x in q(["--windows"])
    if x.get("app") == app
    and not x.get("is-minimized")
    and not x.get("is-hidden")
]
ids = [x["id"] for x in visible if x.get("id") is not None]
if len(ids) < 2:
    sys.exit(0)
try:
    i = ids.index(wid)
except ValueError:
    i = 0
nxt = ids[(i + 1) % len(ids)]
subprocess.run(["yabai", "-m", "window", str(nxt), "--focus"], capture_output=True)
'
