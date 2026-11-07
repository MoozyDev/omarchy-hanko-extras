#!/bin/bash
# Hanko — lock screen skin hook for Omarchy 4.
#
# Omarchy draws its lock screen in LockView.qml (package file, owned by root).
# The password check lives in Service.qml next to it and is NOT touched here.
# This script adds three marked lines and one Loader to LockView.qml so that an
# optional user file, ~/.config/omarchy/lock-skin/Skin.qml, can move the
# password field and draw widgets on top of the wallpaper.
#
#   lock-patch.sh apply     add the hook (idempotent; run by the pacman hook)
#   lock-patch.sh restore   put back Omarchy's original file
#   lock-patch.sh status    print patched / original / missing
#
# Safety rules:
#   - Every inserted line carries the marker HANKO-LOCK, so it can be removed.
#   - If an anchor line is missing (Omarchy changed the file), nothing is written.
#   - If qmllint is available and rejects the result, nothing is written.
#   - Without a Skin.qml the Loader loads nothing and the lock looks stock.

set -euo pipefail

TARGET="${HANKO_LOCKVIEW:-/usr/share/omarchy/shell/plugins/lock/LockView.qml}"
STATE_DIR="${HANKO_LOCK_STATE:-/var/lib/hanko}"
ORIG="$STATE_DIR/LockView.qml.orig"
MARK="HANKO-LOCK"

die() { echo "hanko-lock: $*" >&2; exit 1; }

is_patched() { grep -q "$MARK" "$TARGET"; }

count() { grep -cE "$1" "$TARGET" || true; }

apply() {
  [[ -f $TARGET ]] || die "introuvable : $TARGET (Omarchy 4 requis)"
  if is_patched; then
    echo "hanko-lock: déjà appliqué"
    return 0
  fi

  # Each anchor must exist exactly once, or Omarchy changed the file and we stop.
  [[ $(count '^import QtQuick\.Effects$') == 1 ]] || die "ancre 'import QtQuick.Effects' absente — rien modifié"
  [[ $(count '^    MultiEffect \{$') == 1 ]] || die "ancre 'MultiEffect' absente — rien modifié"
  [[ $(count '^      id: inputField$') == 1 ]] || die "ancre 'id: inputField' absente — rien modifié"
  grep -qE '^    BorderSurface \{$' "$TARGET" || die "ancre 'BorderSurface' absente — rien modifié"

  mkdir -p "$STATE_DIR"
  cp -f "$TARGET" "$ORIG"

  local tmp
  tmp=$(mktemp "${TARGET}.hanko.XXXXXX")
  trap 'rm -f "$tmp"' EXIT

  # The Loader goes right before the BorderSurface whose next line is
  # "id: inputField", so skin widgets draw above the wallpaper and the
  # click-to-focus MouseArea, and below the password field.
  awk -v mark="$MARK" '
    { lines[NR] = $0 }
    END {
      for (i = 1; i <= NR; i++) {
        line = lines[i]
        if (line == "    BorderSurface {" && lines[i + 1] == "      id: inputField") {
          print "    // " mark " BEGIN — optional skin: ~/.config/omarchy/lock-skin/Skin.qml"
          print "    Loader {"
          print "      id: hankoLockSkin"
          print "      anchors.fill: parent"
          print "      readonly property string skinDir: (Quickshell.env(\"XDG_CONFIG_HOME\") || (Quickshell.env(\"HOME\") + \"/.config\")) + \"/omarchy/lock-skin\""
          print "      active: Quickshell.env(\"HANKO_LOCK_SKIN\") !== \"off\""
          print "      source: active ? \"file://\" + skinDir + \"/Skin.qml\" : \"\""
          print "      onLoaded: {"
          print "        if (\"lockView\" in item) item.lockView = root"
          print "        if (\"inputField\" in item) item.inputField = inputField"
          print "        if (\"wallpaper\" in item) item.wallpaper = wallpaper"
          print "        if (\"wallpaperEffect\" in item) item.wallpaperEffect = hankoWallpaperEffect"
          print "      }"
          print "    }"
          print "    // " mark " END"
          print ""
        }
        print line
        if (line == "import QtQuick.Effects") print "import Quickshell // " mark
        if (line == "    MultiEffect {") print "      id: hankoWallpaperEffect // " mark
      }
    }
  ' "$TARGET" > "$tmp"

  if command -v /usr/lib/qt6/bin/qmllint >/dev/null 2>&1; then
    # Only syntax errors matter here; unresolved shell imports are expected.
    if /usr/lib/qt6/bin/qmllint "$tmp" 2>&1 | grep -qiE '^Error: .*(syntax|Expected token|Unexpected token)'; then
      die "le fichier modifié ne passe pas qmllint — rien modifié"
    fi
  fi

  install -m 644 "$tmp" "$TARGET"
  rm -f "$tmp"
  trap - EXIT
  echo "hanko-lock: appliqué ($TARGET)"
}

restore() {
  [[ -f $TARGET ]] || die "introuvable : $TARGET"
  if ! is_patched; then
    echo "hanko-lock: déjà d'origine"
    return 0
  fi
  local tmp
  tmp=$(mktemp "${TARGET}.hanko.XXXXXX")
  trap 'rm -f "$tmp"' EXIT
  # Strip our block and marked lines; this works even if the saved original
  # belongs to an older Omarchy version.
  awk -v mark="$MARK" '
    index($0, "// " mark " BEGIN") { skip = 1; next }
    skip && index($0, "// " mark " END") { skip = 0; dropblank = 1; next }
    skip { next }
    dropblank && $0 == "" { dropblank = 0; next }
    { dropblank = 0 }
    index($0, "// " mark) { next }
    { print }
  ' "$TARGET" > "$tmp"
  install -m 644 "$tmp" "$TARGET"
  rm -f "$tmp"
  trap - EXIT
  echo "hanko-lock: fichier d'origine remis"
}

status() {
  if [[ ! -f $TARGET ]]; then echo "missing"
  elif is_patched; then echo "patched"
  else echo "original"
  fi
}

case "${1:-}" in
  apply) apply ;;
  restore) restore ;;
  status) status ;;
  *) echo "usage: $0 apply|restore|status" >&2; exit 2 ;;
esac
