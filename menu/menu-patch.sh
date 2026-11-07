#!/bin/bash
# Hanko — "wide and low" Omarchy menu (spec: specs/lanceur/fiche.md, choice B).
#
# Works on YOUR clone of the built-in menu (~/.config/omarchy/plugins/$USER.menu,
# made by `omarchy plugin clone omarchy.menu`), never on Omarchy's own files.
#   - card 50 % of the screen width (instead of 300 px)
#   - 6 rows visible (plus a peek of the next one); the list scrolls inside
#   - centred at 45 % of the height (instead of 50 %)
#
#   menu-patch.sh apply   <Menu.qml>
#   menu-patch.sh restore <Menu.qml>
#   menu-patch.sh status  <Menu.qml>

set -euo pipefail

MARK="HANKO-MENU"
cmd="${1:-}"
FILE="${2:-}"

die() { echo "hanko-menu: $*" >&2; exit 1; }
[[ -n $FILE && -f $FILE ]] || die "fichier introuvable : ${FILE:-<vide>}"

# Each pair: the exact original line, then its Hanko version.
O1='  property int cardWidth: Math.min(root.dmenuActive ? Style.space(root.dmenuWidth) : ((root.activeMenu === "trigger.capture.screenrecord" || root.activeMenu === "appearance.font" || root.activeMenu === "update.kernel") ? Style.space(520) : Style.space(300)), panel.width - Style.gapsOut * 2)'
N1='  property int cardWidth: Math.min(Math.max(root.dmenuActive ? Style.space(root.dmenuWidth) : Style.space(300), Math.round(panel.width * 0.5)), panel.width - Style.gapsOut * 2) // '"$MARK"
O2='  property int visibleRowsHeight: root.dmenuActive ? dmenuRowListHeight(layoutSerial, displayModel.count, filterText) : rowListHeight(layoutSerial, displayModel.count, filterText, searchDivider)'
N2='  property int visibleRowsHeight: Math.min(root.dmenuActive ? dmenuRowListHeight(layoutSerial, displayModel.count, filterText) : rowListHeight(layoutSerial, displayModel.count, filterText, searchDivider), (baseRowHeight + rowSpacing) * 6 + rowPeek) // '"$MARK"
O3='    readonly property int centeredTop: Math.max(Style.gapsOut, Math.round((height - root.cardHeight) / 2))'
N3='    readonly property int centeredTop: Math.max(Style.gapsOut, Math.round(height * 0.45 - root.cardHeight / 2)) // '"$MARK"

rewrite() {
  # rewrite <from1> <to1> <from2> <to2> ... — whole-line, literal replacement.
  local -a pairs=("$@")
  local tmp line i done_any=0
  tmp=$(mktemp "${FILE}.hanko.XXXXXX")
  while IFS= read -r line || [[ -n $line ]]; do
    for ((i = 0; i < ${#pairs[@]}; i += 2)); do
      if [[ $line == "${pairs[i]}" ]]; then line="${pairs[i + 1]}"; done_any=1; break; fi
    done
    printf '%s\n' "$line"
  done <"$FILE" >"$tmp"
  mv -f "$tmp" "$FILE"
  return $((1 - done_any))
}

case "$cmd" in
  apply)
    if grep -q "$MARK" "$FILE"; then echo "hanko-menu: déjà appliqué"; exit 0; fi
    for l in "$O1" "$O2" "$O3"; do
      [[ $(grep -cxF -- "$l" "$FILE" || true) == 1 ]] || die "ligne attendue absente (Omarchy a changé le menu) — rien modifié : ${l:0:70}…"
    done
    rewrite "$O1" "$N1" "$O2" "$N2" "$O3" "$N3"
    echo "hanko-menu: appliqué (large et bas)"
    ;;
  restore)
    if ! grep -q "$MARK" "$FILE"; then echo "hanko-menu: déjà d'origine"; exit 0; fi
    rewrite "$N1" "$O1" "$N2" "$O2" "$N3" "$O3" || true
    echo "hanko-menu: menu d'origine remis"
    ;;
  status)
    grep -q "$MARK" "$FILE" && echo patched || echo original
    ;;
  *) echo "usage: $0 apply|restore|status <Menu.qml>" >&2; exit 2 ;;
esac
