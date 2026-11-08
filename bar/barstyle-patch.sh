#!/bin/bash
# Hanko — bar style hook for Omarchy 4 (specs/barre/fiche.md).
#
#   active workspace: its number in black on an accent pill
#                     (instead of Omarchy's layout glyph)
#   clock:            in capitals
#
# Both widgets are package files (owned by root). This adds marked lines to
# them; the style only shows while ~/.config/omarchy/hanko/bar-style says "on",
# so `hanko barstyle on|off` switches it live without sudo.
#
#   barstyle-patch.sh apply | restore | status
#
# Safety: every added line carries HANKO-BARSTYLE; if an anchor is missing in
# either file nothing is written.

set -euo pipefail

WS="${HANKO_WORKSPACES:-/usr/share/omarchy/shell/plugins/bar/widgets/Workspaces.qml}"
CLOCK="${HANKO_CLOCK:-/usr/share/omarchy/shell/plugins/panels/clock/BarWidget.qml}"
MARK="HANKO-BARSTYLE"

WS_TEXT='        text: shown ? root.modeGlyph(root.activeMode) : (slot === root.slots ? "0" : String(slot))'
WS_TEXT_NEW='        text: (shown && !root.hankoStyle) ? root.modeGlyph(root.activeMode) : (slot === root.slots ? "0" : String(slot)) // '"$MARK"
CLOCK_TEXT='    text: root.vertical ? "" : root.displayText'
CLOCK_TEXT_NEW='    text: root.vertical ? "" : (root.hankoStyle ? root.displayText.toUpperCase() : root.displayText) // '"$MARK"

die() { echo "hanko-barstyle: $*" >&2; exit 1; }
once() { [[ $(grep -cxF -- "$1" "$2" || true) == 1 ]]; }

# The flag watcher both files get, right after their root "id: root".
flag_block() {
  cat <<EOF
  property bool hankoStyle: false // $MARK
  FileView { // $MARK
    path: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/omarchy/hanko/bar-style" // $MARK
    watchChanges: true // $MARK
    printErrors: false // $MARK
    onFileChanged: reload() // $MARK
    onLoaded: root.hankoStyle = text().trim() === "on" // $MARK
    onLoadFailed: root.hankoStyle = false // $MARK
  } // $MARK
EOF
}

patch_file() {
  # patch_file <file> <awk program>
  local file="$1" prog="$2" tmp
  tmp=$(mktemp "${file}.hanko.XXXXXX")
  awk -v mark="$MARK" -v flag="$(flag_block)" "$prog" "$file" >"$tmp"
  install -m 644 "$tmp" "$file"
  rm -f "$tmp"
}

apply() {
  [[ -f $WS && -f $CLOCK ]] || die "fichiers Omarchy introuvables (Omarchy 4 requis)"
  if grep -q "$MARK" "$WS" && grep -q "$MARK" "$CLOCK"; then echo "hanko-barstyle: déjà appliqué"; return 0; fi
  grep -q "$MARK" "$WS" && die "Workspaces.qml à moitié modifié — lance d'abord : $0 restore"
  grep -q "$MARK" "$CLOCK" && die "BarWidget.qml (horloge) à moitié modifié — lance d'abord : $0 restore"
  once '  id: root' "$WS" || die "ancre 'id: root' absente dans Workspaces.qml — rien modifié"
  once 'import qs.Commons' "$WS" || die "ancre 'import qs.Commons' absente dans Workspaces.qml — rien modifié"
  once "$WS_TEXT" "$WS" || die "ligne du texte des bureaux absente — rien modifié"
  once '        required property int index' "$WS" || die "ancre 'required property int index' absente — rien modifié"
  once '  id: root' "$CLOCK" || die "ancre 'id: root' absente dans l'horloge — rien modifié"
  once "$CLOCK_TEXT" "$CLOCK" || die "ligne du texte de l'horloge absente — rien modifié"
  grep -qxF 'import Quickshell.Io' "$CLOCK" || die "import Quickshell.Io absent de l'horloge — rien modifié"

  patch_file "$WS" '
    $0 == "  id: root" { print; print flag; next }
    $0 == "import qs.Commons" { print; print "import qs.Commons as HankoCommons // " mark; next }
    $0 == "        text: shown ? root.modeGlyph(root.activeMode) : (slot === root.slots ? \"0\" : String(slot))" {
      print "        text: (shown && !root.hankoStyle) ? root.modeGlyph(root.activeMode) : (slot === root.slots ? \"0\" : String(slot)) // " mark
      next
    }
    $0 == "        required property int index" {
      print
      print "        foreground: (shown && root.hankoStyle) ? \"#121010\" : root.bar.barForeground // " mark
      print "        Rectangle { // " mark
      print "          visible: shown && root.hankoStyle // " mark
      print "          z: -1 // " mark
      print "          anchors.centerIn: parent // " mark
      print "          width: Math.max(parent.width - 2, 1) // " mark
      print "          height: Math.max(Math.min(parent.height - 10, parent.width + 2), 1) // " mark
      print "          color: HankoCommons.Color.accent // " mark
      print "        } // " mark
      next
    }
    { print }
  '
  patch_file "$CLOCK" '
    $0 == "  id: root" { print; print flag; next }
    $0 == "    text: root.vertical ? \"\" : root.displayText" {
      print "    text: root.vertical ? \"\" : (root.hankoStyle ? root.displayText.toUpperCase() : root.displayText) // " mark
      next
    }
    { print }
  '
  echo "hanko-barstyle: appliqué"
}

restore_file() {
  local file="$1" orig_text="$2" tmp
  grep -q "$MARK" "$file" || return 0
  tmp=$(mktemp "${file}.hanko.XXXXXX")
  awk -v mark="$MARK" -v orig="$orig_text" '
    index($0, "// " mark) {
      if ($0 ~ /^ +text: /) print orig
      next
    }
    { print }
  ' "$file" >"$tmp"
  install -m 644 "$tmp" "$file"
  rm -f "$tmp"
}

restore() {
  restore_file "$WS" "$WS_TEXT"
  restore_file "$CLOCK" "$CLOCK_TEXT"
  echo "hanko-barstyle: fichiers d'origine remis"
}

status() {
  if [[ ! -f $WS || ! -f $CLOCK ]]; then echo missing
  elif grep -q "$MARK" "$WS" && grep -q "$MARK" "$CLOCK"; then echo patched
  else echo original
  fi
}

case "${1:-}" in
  apply) apply ;;
  restore) restore ;;
  status) status ;;
  *) echo "usage: $0 apply|restore|status" >&2; exit 2 ;;
esac
