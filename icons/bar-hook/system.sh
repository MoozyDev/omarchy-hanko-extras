#!/bin/bash
# Hanko — system part of the bar icon hook. Must run as root (sudo).
#
#   system.sh install     copy the patcher + pacman hook, then apply the patch
#   system.sh uninstall   restore Omarchy's file, remove the patcher and hook

set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "hanko-icons: lancer avec sudo" >&2; exit 1; }

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LIB=/usr/local/lib/hanko
HOOK=/etc/pacman.d/hooks/hanko-icons.hook

case "${1:-}" in
  install)
    install -d -m 755 "$LIB" /etc/pacman.d/hooks
    install -m 755 "$HERE/icons-patch.sh" "$LIB/icons-patch.sh"
    install -m 644 "$HERE/hanko-icon.qml.part" "$LIB/hanko-icon.qml.part"
    install -m 644 "$HERE/hanko-icons.hook" "$HOOK"
    # Re-apply from scratch so an older version of the hook is replaced.
    "$LIB/icons-patch.sh" restore
    "$LIB/icons-patch.sh" apply
    ;;
  uninstall)
    if [[ -x $LIB/icons-patch.sh ]]; then "$LIB/icons-patch.sh" restore; else bash "$HERE/icons-patch.sh" restore; fi
    rm -f "$HOOK" "$LIB/icons-patch.sh" "$LIB/hanko-icon.qml.part"
    rmdir "$LIB" 2>/dev/null || true
    echo "hanko-icons: désinstallé"
    ;;
  *)
    echo "usage: sudo $0 install|uninstall" >&2
    exit 2
    ;;
esac
