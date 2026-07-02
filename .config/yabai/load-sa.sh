#!/usr/bin/env sh
# Load yabai scripting addition (needs NOPASSWD sudoers + nvram boot-arg on Apple Silicon).
set -eu
YABAI="${YABAI:-/opt/homebrew/bin/yabai}"
if [ ! -x "$YABAI" ]; then
  YABAI="$(command -v yabai 2>/dev/null || true)"
fi
if [ ! -x "$YABAI" ]; then
  echo "yabai load-sa: yabai binary not found" >&2
  exit 0
fi

_bootargs=$(nvram boot-args 2>/dev/null | sed 's/^boot-args[[:space:]]*//' | tr -d '\0' || true)
case "$_bootargs" in
  *-arm64e_preview_abi*) ;;
  *)
    echo "yabai load-sa: missing nvram -arm64e_preview_abi (reboot required after fixing). Run: $HOME/.config/yabai/install-yabai-sa.sh" >&2
    exit 0
    ;;
esac

if sudo -n "$YABAI" --load-sa 2>/dev/null; then
  exit 0
fi

if [ -t 0 ] && [ -t 1 ]; then
  sudo "$YABAI" --load-sa && exit 0
fi

echo "yabai load-sa: sudo without password failed; install sudoers: $HOME/.config/yabai/install-yabai-sa.sh" >&2
exit 0
