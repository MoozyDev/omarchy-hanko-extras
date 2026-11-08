#!/bin/bash
# Hanko — system part of the bar style hook. Must run as root (sudo).
#
#   system.sh install     copy the patcher + pacman hook, then (re)apply the patch
#   system.sh uninstall   restore Omarchy's files, remove the patcher and hook

set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "hanko-barstyle: lancer avec sudo" >&2; exit 1; }

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LIB=/usr/local/lib/hanko
HOOK=/etc/pacman.d/hooks/hanko-barstyle.hook

case "${1:-}" in
  install)
    install -d -m 755 "$LIB" /etc/pacman.d/hooks
    install -m 755 "$HERE/barstyle-patch.sh" "$LIB/barstyle-patch.sh"
    install -m 644 "$HERE/hanko-barstyle.hook" "$HOOK"
    "$LIB/barstyle-patch.sh" restore
    "$LIB/barstyle-patch.sh" apply
    ;;
  uninstall)
    if [[ -x $LIB/barstyle-patch.sh ]]; then "$LIB/barstyle-patch.sh" restore; else bash "$HERE/barstyle-patch.sh" restore; fi
    rm -f "$HOOK" "$LIB/barstyle-patch.sh"
    rmdir "$LIB" 2>/dev/null || true
    echo "hanko-barstyle: désinstallé"
    ;;
  *)
    echo "usage: sudo $0 install|uninstall" >&2
    exit 2
    ;;
esac
