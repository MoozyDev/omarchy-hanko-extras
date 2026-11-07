#!/bin/bash
# Hanko — system part of the lock screen hook. Must run as root (sudo).
#
#   system.sh install     copy the patcher + pacman hook, then apply the patch
#   system.sh uninstall   restore Omarchy's file, remove the patcher and hook

set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "hanko-lock: lancer avec sudo" >&2; exit 1; }

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LIB=/usr/local/lib/hanko
HOOK=/etc/pacman.d/hooks/hanko-lock.hook

case "${1:-}" in
  install)
    install -d -m 755 "$LIB" /etc/pacman.d/hooks
    install -m 755 "$HERE/lock-patch.sh" "$LIB/lock-patch.sh"
    install -m 644 "$HERE/hanko-lock.hook" "$HOOK"
    "$LIB/lock-patch.sh" apply
    ;;
  uninstall)
    if [[ -x $LIB/lock-patch.sh ]]; then
      "$LIB/lock-patch.sh" restore
    else
      bash "$HERE/lock-patch.sh" restore
    fi
    rm -f "$HOOK" "$LIB/lock-patch.sh"
    rmdir "$LIB" 2>/dev/null || true
    rm -rf /var/lib/hanko
    echo "hanko-lock: désinstallé"
    ;;
  *)
    echo "usage: sudo $0 install|uninstall" >&2
    exit 2
    ;;
esac
