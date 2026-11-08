#!/bin/bash
# Hanko — notification and OSD hook for Omarchy 4.
#
# Notifications (specs/notifications): application name as a small header in
#   the dark accent, a 4 px accent band on critical ones, a 24 px slide in.
# OSD, the volume / brightness gauge (specs/osd): 8 % from the bottom, black
#   card, 4 px gauge on a dark track, accent for volume and cream for brightness.
#
# Both are package files (owned by root). The marked lines only take effect
# while ~/.config/omarchy/hanko/ui.json says {"on": true}, so `hanko ui on|off`
# switches the look without sudo.
#
#   ui-patch.sh apply | restore | status

set -euo pipefail

TOAST="${HANKO_TOAST:-/usr/share/omarchy/shell/plugins/notifications/Toast.qml}"
OSD="${HANKO_OSD:-/usr/share/omarchy/shell/plugins/osd/Osd.qml}"
MARK="HANKO-UI"

die() { echo "hanko-ui: $*" >&2; exit 1; }
once() { [[ $(grep -cxF -- "$1" "$2" || true) == 1 ]]; }

# Exact OSD lines and their Hanko versions.
O1='      anchors.bottomMargin: Style.space(67)'
N1='      anchors.bottomMargin: root.hankoOn ? Math.round(panel.height * 0.08) : Style.space(67) // '"$MARK"
O2='      color: Util.alpha(Commons.Color.background, 0.97)'
N2='      color: root.hankoOn ? Commons.Color.background : Util.alpha(Commons.Color.background, 0.97) // '"$MARK"
O3='          height: Math.max(Style.space(6), Style.spacing.sm)'
N3='          height: root.hankoOn ? 4 : Math.max(Style.space(6), Style.spacing.sm) // '"$MARK"
O4='          color: Util.alpha(Commons.Color.popups.text, 0.45)'
N4='          color: root.hankoOn ? "#3a3330" : Util.alpha(Commons.Color.popups.text, 0.45) // '"$MARK"
O5='            color: Commons.Color.accent'
# Exact Toast lines: the card's text block also counts the Hanko header.
T1='      headline.height + (hasBody ? column.spacing + bodyBox.height : 0)'
U1='      card.hankoHeaderBlock + headline.height + (hasBody ? column.spacing + bodyBox.height : 0) // '"$MARK"
T2='      headline.height + (hasBody ? column.spacing + bodyBox.restHeight : 0)'
U2='      card.hankoHeaderBlock + headline.height + (hasBody ? column.spacing + bodyBox.restHeight : 0) // '"$MARK"
N5='            color: (root.hankoOn && (root.iconKey === "brightness" || root.iconKey === "display")) ? Commons.Color.foreground : Commons.Color.accent // '"$MARK"

flag_block() {
  # flag_block <id of the root item>
  cat <<EOF
  property bool hankoOn: false // $MARK
  property color hankoAccentDark: "#c2340f" // $MARK
  FileView { // $MARK
    path: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/omarchy/hanko/ui.json" // $MARK
    blockLoading: true // $MARK
    watchChanges: true // $MARK
    printErrors: false // $MARK
    onFileChanged: reload() // $MARK
    onLoaded: { try { var u = JSON.parse(text()); $1.hankoOn = u.on === true; if (u.accentDark) $1.hankoAccentDark = u.accentDark } catch (e) { $1.hankoOn = false } } // $MARK
    onLoadFailed: $1.hankoOn = false // $MARK
  } // $MARK
EOF
}

rewrite() {
  # rewrite <file> <from1> <to1> ... — whole-line literal replacement
  local file="$1"; shift
  local -a pairs=("$@")
  local tmp line i
  tmp=$(mktemp "${file}.hanko.XXXXXX")
  while IFS= read -r line || [[ -n $line ]]; do
    for ((i = 0; i < ${#pairs[@]}; i += 2)); do
      if [[ $line == "${pairs[i]}" ]]; then line="${pairs[i + 1]}"; break; fi
    done
    printf '%s\n' "$line"
  done <"$file" >"$tmp"
  install -m 644 "$tmp" "$file"
  rm -f "$tmp"
}

insert() {
  # insert <file> <awk program>  (variables: mark, flag)
  local file="$1" prog="$2" root="$3" tmp
  tmp=$(mktemp "${file}.hanko.XXXXXX")
  awk -v mark="$MARK" -v flag="$(flag_block "$root")" "$prog" "$file" >"$tmp"
  install -m 644 "$tmp" "$file"
  rm -f "$tmp"
}

apply() {
  [[ -f $TOAST && -f $OSD ]] || die "fichiers Omarchy introuvables (Omarchy 4 requis)"
  if grep -q "$MARK" "$TOAST" && grep -q "$MARK" "$OSD"; then echo "hanko-ui: déjà appliqué"; return 0; fi
  if grep -q "$MARK" "$TOAST" || grep -q "$MARK" "$OSD"; then die "fichiers à moitié modifiés — lance d'abord : $0 restore"; fi

  once 'import Quickshell' "$TOAST" || die "ancre 'import Quickshell' absente (notifications) — rien modifié"
  once '  transformOrigin: Item.Top' "$TOAST" || die "ancre 'transformOrigin' absente (notifications) — rien modifié"
  once "  // The keyboard's card is tinted with the theme's hover fill, buttons and all." "$TOAST" || die "ancre de la carte absente (notifications) — rien modifié"
  once '        // Title, marks, and when it arrived.' "$TOAST" || die "ancre du titre absente (notifications) — rien modifié"
  once '  id: root' "$OSD" || die "ancre 'id: root' absente (OSD) — rien modifié"
  for l in "$T1" "$T2"; do once "$l" "$TOAST" || die "ligne attendue absente (notifications) — rien modifié : ${l:0:60}…"; done
  for l in "$O1" "$O2" "$O3" "$O4" "$O5"; do once "$l" "$OSD" || die "ligne attendue absente (OSD) — rien modifié : ${l:0:60}…"; done

  insert "$TOAST" '
    $0 == "import Quickshell" { print; print "import Quickshell.Io // " mark; next }
    $0 == "  transformOrigin: Item.Top" {
      print
      print flag
      print "  readonly property string hankoHeaderText: String(card.row.source || card.row.app || \"\").toUpperCase() // " mark
      print "  readonly property bool hankoHeaderShown: card.hankoOn && !card.anonymous && hankoHeaderText !== \"\" // " mark
      print "  readonly property real hankoHeaderBlock: hankoHeaderShown ? hankoHeader.implicitHeight + column.spacing : 0 // " mark
      print "  property real hankoSlide: 0 // " mark
      print "  transform: Translate { x: card.hankoSlide } // " mark
      print "  NumberAnimation { id: hankoSlideAnim; target: card; property: \"hankoSlide\"; from: 24; to: 0; duration: 180; easing.type: Easing.OutCubic } // " mark
      print "  Component.onCompleted: if (card.hankoOn) hankoSlideAnim.start() // " mark
      next
    }
    $0 == "  // The keyboard'"'"'s card is tinted with the theme'"'"'s hover fill, buttons and all." {
      print "  Rectangle { // " mark
      print "    visible: card.hankoOn && card.critical // " mark
      print "    x: plate.x; y: plate.y; width: plate.width; height: 4; z: 3 // " mark
      print "    color: Commons.Color.accent // " mark
      print "  } // " mark
      print
      next
    }
    $0 == "        // Title, marks, and when it arrived." {
      print "        Text { // " mark
      print "          id: hankoHeader // " mark
      print "          visible: card.hankoHeaderShown // " mark
      print "          width: parent.width // " mark
      print "          elide: Text.ElideRight // " mark
      print "          textFormat: Text.PlainText // " mark
      print "          text: card.hankoHeaderText // " mark
      print "          color: card.hankoAccentDark // " mark
      print "          font.family: \"SpaceMono Nerd Font\" // " mark
      print "          font.pixelSize: 11 // " mark
      print "          font.letterSpacing: 1.5 // " mark
      print "          opacity: card.contentOpacity // " mark
      print "        } // " mark
      print
      next
    }
    { print }
  ' card

  insert "$OSD" '
    $0 == "  id: root" { print; print flag; next }
    { print }
  ' root
  rewrite "$TOAST" "$T1" "$U1" "$T2" "$U2"
  rewrite "$OSD" "$O1" "$N1" "$O2" "$N2" "$O3" "$N3" "$O4" "$N4" "$O5" "$N5"
  echo "hanko-ui: appliqué"
}

restore() {
  local f tmp
  rewrite "$TOAST" "$U1" "$T1" "$U2" "$T2"
  rewrite "$OSD" "$N1" "$O1" "$N2" "$O2" "$N3" "$O3" "$N4" "$O4" "$N5" "$O5"
  for f in "$TOAST" "$OSD"; do
    grep -q "$MARK" "$f" || continue
    tmp=$(mktemp "${f}.hanko.XXXXXX")
    grep -vF "// $MARK" "$f" >"$tmp" || true
    install -m 644 "$tmp" "$f"
    rm -f "$tmp"
  done
  echo "hanko-ui: fichiers d'origine remis"
}

case "${1:-}" in
  apply) apply ;;
  restore) restore ;;
  status)
    if [[ ! -f $TOAST || ! -f $OSD ]]; then echo missing
    elif grep -q "$MARK" "$TOAST" && grep -q "$MARK" "$OSD"; then echo patched
    else echo original
    fi
    ;;
  *) echo "usage: $0 apply|restore|status" >&2; exit 2 ;;
esac
