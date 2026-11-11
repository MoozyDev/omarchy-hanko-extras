#!/bin/bash
# Hanko — bar icon hook for Omarchy 4.
#
# Every icon in the Omarchy bar is a Nerd Font character drawn by one shared
# component, BarIconButton.qml (package file, owned by root). This script adds
# a marked block to it: when ~/.config/omarchy/hanko/bar-icons/map.json maps
# the character to an SVG, that SVG is shown instead, in the colour the glyph
# would have had. Anything not in the map stays as Omarchy draws it. Widgets
# keep all their behaviour: only the picture changes. An entry can add an
# "accent" SVG, drawn on top in the theme's accent colour (a slash, a cross).
#
#   icons-patch.sh apply     add the hook (idempotent; run by the pacman hook)
#   icons-patch.sh restore   put back Omarchy's original file
#   icons-patch.sh status    print patched / original / missing
#
# Safety: every added line carries HANKO-ICONS; if an anchor is missing nothing
# is written; without map.json the bar looks exactly like Omarchy's.

set -euo pipefail

TARGET="${HANKO_BARICON:-/usr/share/omarchy/shell/Ui/BarIconButton.qml}"
# The QML block inserted before BarIconContent (kept in its own file, readable).
PART="${HANKO_ICON_PART:-$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/hanko-icon.qml.part}"
MARK="HANKO-ICONS"

die() { echo "hanko-icons: $*" >&2; exit 1; }
is_patched() { grep -q "$MARK" "$TARGET"; }
count() { grep -cxF -- "$1" "$TARGET" || true; }

apply() {
  [[ -f $TARGET ]] || die "introuvable : $TARGET (Omarchy 4 requis)"
  [[ -f $PART ]] || die "bloc QML introuvable : $PART"
  if is_patched; then echo "hanko-icons: déjà appliqué"; return 0; fi
  [[ $(count 'import qs.Commons') == 1 ]] || die "ancre 'import qs.Commons' absente — rien modifié"
  [[ $(count '        visible: root.iconComponent === null') == 1 ]] || die "ancre du glyphe absente — rien modifié"
  [[ $(count '      BarIconContent {') == 1 ]] || die "ancre 'BarIconContent' absente — rien modifié"

  local tmp
  tmp=$(mktemp "${TARGET}.hanko.XXXXXX")
  trap 'rm -f "$tmp"' EXIT
  awk -v mark="$MARK" -v part="$PART" '
    {
      if ($0 == "      BarIconContent {") {
        while ((getline line < part) > 0) print line
        close(part)
      }
      print
      if ($0 == "import qs.Commons") {
        print "import QtQuick.Window // " mark
        print "import Quickshell.Io // " mark
        print "import qs.Commons as HankoCommons // " mark
      }
      if ($0 == "        visible: root.iconComponent === null") print "        opacity: hankoIcon.ready ? 0 : 1 // " mark
    }
  ' "$TARGET" >"$tmp"
  install -m 644 "$tmp" "$TARGET"
  rm -f "$tmp"
  trap - EXIT
  echo "hanko-icons: appliqué ($TARGET)"
}

restore() {
  [[ -f $TARGET ]] || die "introuvable : $TARGET"
  if ! is_patched; then echo "hanko-icons: déjà d'origine"; return 0; fi
  local tmp
  tmp=$(mktemp "${TARGET}.hanko.XXXXXX")
  trap 'rm -f "$tmp"' EXIT
  awk -v mark="$MARK" '
    index($0, "// " mark " BEGIN") { skip = 1; next }
    skip && index($0, "// " mark " END") { skip = 0; dropblank = 1; next }
    skip { next }
    dropblank && $0 == "" { dropblank = 0; next }
    { dropblank = 0 }
    index($0, "// " mark) { next }
    { print }
  ' "$TARGET" >"$tmp"
  install -m 644 "$tmp" "$TARGET"
  rm -f "$tmp"
  trap - EXIT
  echo "hanko-icons: fichier d'origine remis"
}

case "${1:-}" in
  apply) apply ;;
  restore) restore ;;
  status) if [[ ! -f $TARGET ]]; then echo missing; elif is_patched; then echo patched; else echo original; fi ;;
  *) echo "usage: $0 apply|restore|status" >&2; exit 2 ;;
esac
