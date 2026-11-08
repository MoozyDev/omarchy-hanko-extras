#!/bin/bash
# Hanko — "grow on hover" for the Omarchy bar.
#
# Works on YOUR clone of the built-in bar (~/.config/omarchy/plugins/$USER.bar,
# made by `omarchy plugin clone omarchy.bar`), never on Omarchy's own files.
# The clone keeps every built-in widget working; we only change how tall the
# strip is drawn. Windows do not move: the reserved space stays the normal
# bar height, and the extra height slides over them while the pointer is on
# the bar.
#
#   bar-patch.sh apply   <Bar.qml> [grow-px]
#   bar-patch.sh restore <Bar.qml>
#   bar-patch.sh status  <Bar.qml>

set -euo pipefail

MARK="HANKO-BAR"
cmd="${1:-}"
FILE="${2:-}"
GROW="${3:-18}"

die() { echo "hanko-bar: $*" >&2; exit 1; }
[[ -n $FILE && -f $FILE ]] || die "fichier introuvable : ${FILE:-<vide>}"
[[ $GROW =~ ^[0-9]+$ ]] || die "hauteur invalide : $GROW"

L1='      x: root.position === "right" ? parent.width - barWindow.thickness : 0'
L2='      y: root.position === "bottom" ? parent.height - barWindow.thickness : 0'
L3='      width: root.vertical ? barWindow.thickness : parent.width'
L4='      height: root.vertical ? parent.height : barWindow.thickness'

apply() {
  if grep -q "$MARK" "$FILE"; then echo "hanko-bar: déjà appliqué"; return 0; fi
  for l in "$L1" "$L2" "$L3" "$L4"; do
    [[ $(grep -cxF -- "$l" "$FILE" || true) == 1 ]] || die "ligne attendue absente (Omarchy a changé la barre) — rien modifié : $l"
  done
  local tmp; tmp=$(mktemp "${FILE}.hanko.XXXXXX")
  awk -v mark="$MARK" -v grow="$GROW" -v l1="$L1" -v l2="$L2" -v l3="$L3" -v l4="$L4" '
    $0 == l1 {
      print "      // " mark " BEGIN — the strip grows while hovered; the reserved zone does not"
      print "      property real hankoGrow: hankoHover.hovered && !root.barHidden ? " grow " : 0"
      print "      Behavior on hankoGrow { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }"
      print "      HoverHandler { id: hankoHover }"
      print "      // 1 px line on the edge facing the windows (specs/barre: filet #3a3330)."
      print "      Rectangle {"
      print "        z: 2"
      print "        color: \"#3a3330\""
      print "        width: root.vertical ? 1 : parent.width"
      print "        height: root.vertical ? parent.height : 1"
      print "        x: root.position === \"left\" ? parent.width - 1 : 0"
      print "        y: root.position === \"top\" ? parent.height - 1 : 0"
      print "      }"
      print "      // " mark " END"
      print "      x: root.position === \"right\" ? parent.width - barWindow.thickness - hankoGrow : 0 // " mark
      next
    }
    $0 == l2 { print "      y: root.position === \"bottom\" ? parent.height - barWindow.thickness - hankoGrow : 0 // " mark; next }
    $0 == l3 { print "      width: root.vertical ? barWindow.thickness + hankoGrow : parent.width // " mark; next }
    $0 == l4 { print "      height: root.vertical ? parent.height : barWindow.thickness + hankoGrow // " mark; next }
    { print }
  ' "$FILE" > "$tmp"
  cp -f "$FILE" "$FILE.hanko-orig"
  mv -f "$tmp" "$FILE"
  echo "hanko-bar: appliqué (+${GROW} px au survol)"
}

restore() {
  if ! grep -q "$MARK" "$FILE"; then echo "hanko-bar: déjà d'origine"; return 0; fi
  local tmp; tmp=$(mktemp "${FILE}.hanko.XXXXXX")
  awk -v mark="$MARK" -v l1="$L1" -v l2="$L2" -v l3="$L3" -v l4="$L4" '
    index($0, "// " mark " BEGIN") { skip = 1; next }
    skip && index($0, "// " mark " END") { skip = 0; next }
    skip { next }
    index($0, "// " mark) {
      if ($0 ~ /^      x:/) print l1
      else if ($0 ~ /^      y:/) print l2
      else if ($0 ~ /^      width:/) print l3
      else if ($0 ~ /^      height:/) print l4
      next
    }
    { print }
  ' "$FILE" > "$tmp"
  mv -f "$tmp" "$FILE"
  rm -f "$FILE.hanko-orig"
  echo "hanko-bar: barre d'origine remise"
}

case "$cmd" in
  apply) apply ;;
  restore) restore ;;
  status) grep -q "$MARK" "$FILE" && echo patched || echo original ;;
  *) echo "usage: $0 apply|restore|status <Bar.qml> [grow-px]" >&2; exit 2 ;;
esac
