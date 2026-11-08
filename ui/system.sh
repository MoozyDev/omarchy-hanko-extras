#!/bin/bash
# Hanko — system part of the notification and OSD hook. Must run as root (sudo).
#
#   system.sh install     copy the patcher + pacman hook, then (re)apply the patch
#   system.sh uninstall   restore Omarchy's files, remove the patcher and hook

set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "hanko-ui: lancer avec sudo" >&2; exit 1; }

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LIB=/usr/local/lib/hanko
HOOK=/etc/pacman.d/hooks/hanko-ui.hook

case "${1:-}" in
  install)
    install -d -m 755 "$LIB" /etc/pacman.d/hooks
    install -m 755 "$HERE/ui-patch.sh" "$LIB/ui-patch.sh"
    install -m 644 "$HERE/hanko-ui.hook" "$HOOK"
    "$LIB/ui-patch.sh" restore
    "$LIB/ui-patch.sh" apply
    ;;
  uninstall)
    if [[ -x $LIB/ui-patch.sh ]]; then "$LIB/ui-patch.sh" restore; else bash "$HERE/ui-patch.sh" restore; fi
    rm -f "$HOOK" "$LIB/ui-patch.sh"
    rmdir "$LIB" 2>/dev/null || true
    echo "hanko-ui: désinstallé"
    ;;
  *)
    echo "usage: sudo $0 install|uninstall" >&2
    exit 2
    ;;
esac
