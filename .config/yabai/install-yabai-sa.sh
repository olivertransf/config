#!/usr/bin/env sh
# One-time (or after yabai upgrade): nvram boot-arg for Apple Silicon SA + passwordless sudo for --load-sa.
set -eu
YABAI="$(command -v yabai)"
HASH="$(shasum -a 256 "$YABAI" | awk '{print $1}')"
USER_NAME="$(whoami)"
SUDOERS_LINE="${USER_NAME} ALL=(root) NOPASSWD: sha256:${HASH} ${YABAI} --load-sa"
SUDOERS_FILE="/private/etc/sudoers.d/yabai"

echo "==> yabai: $YABAI"
echo "==> sha256: $HASH"

_current="$(nvram boot-args 2>/dev/null | sed 's/^boot-args[[:space:]]*//' | tr -d '\0' || true)"
if printf '%s' "$_current" | grep -q -- '-arm64e_preview_abi'; then
  echo "==> nvram boot-args already contains -arm64e_preview_abi"
else
  if [ -n "$_current" ]; then
    echo "==> appending -arm64e_preview_abi to existing boot-args"
    sudo nvram boot-args="${_current} -arm64e_preview_abi"
  else
    echo "==> setting nvram boot-args=-arm64e_preview_abi"
    sudo nvram boot-args="-arm64e_preview_abi"
  fi
  echo "==> REBOOT once so the boot-arg takes effect, then log in again."
fi

echo "==> installing $SUDOERS_FILE"
printf '%s\n' "$SUDOERS_LINE" | sudo tee "$SUDOERS_FILE" >/dev/null
sudo chmod 440 "$SUDOERS_FILE"
if sudo visudo -c -f "$SUDOERS_FILE" 2>/dev/null; then
  echo "==> sudoers syntax OK"
else
  echo "==> warning: visudo -c failed; check $SUDOERS_FILE" >&2
fi

echo "==> trying load-sa now (works only after reboot if boot-arg was just set)"
sudo -n "$YABAI" --load-sa 2>/dev/null && echo "==> load-sa OK" || echo "==> load-sa skipped or failed until reboot / Dock ready"

echo "Done."
