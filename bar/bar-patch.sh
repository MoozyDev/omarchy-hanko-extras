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
# The content grows with the strip: on a horizontal bar the left, center and
# right sections are scaled by (thickness + grow) / thickness, each from its own
# side (left edge, middle, right edge), so icons, text and buttons get bigger
# and stay readable. Scaling is a transform, so clicks, tooltips and panels
# follow it; icons are drawn at twice their size and stay sharp.
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
# The horizontal bar's sections, scaled with the strip (see the header).
HB='      id: horizontalBar'
VB='      id: verticalBar'
SL='        LeftModules {'
SC='        CenterModules {'
SR='        RightModules {'
SS='        CenterSections {'
# Where the center group reaches on each side of the middle (asymmetric: its
# begin and end lists hang off the centered box), and where the horizontal
# bar's own Item starts, to compute a scale that never overlaps.
CSB='    property bool besideRight: false'
CMS='    CenterSections {'
CMG='    CenterGestureArea { anchors.fill: parent }'
FILL='        anchors.fill: parent'

apply() {
  if grep -q "$MARK" "$FILE"; then echo "hanko-bar: déjà appliqué"; return 0; fi
  for l in "$L1" "$L2" "$L3" "$L4" "$HB" "$VB" "$CSB" "$CMS" "$CMG"; do
    [[ $(grep -cxF -- "$l" "$FILE" || true) == 1 ]] || die "ligne attendue absente (Omarchy a changé la barre) — rien modifié : $l"
  done
  for l in "$SL" "$SC" "$SR"; do
    [[ $(grep -cxF -- "$l" "$FILE" || true) -ge 1 ]] || die "section attendue absente (Omarchy a changé la barre) — rien modifié : $l"
  done
  local tmp; tmp=$(mktemp "${FILE}.hanko.XXXXXX")
  awk -v mark="$MARK" -v grow="$GROW" -v l1="$L1" -v l2="$L2" -v l3="$L3" -v l4="$L4" \
      -v hb="$HB" -v vb="$VB" -v sl="$SL" -v sc="$SC" -v sr="$SR" -v ss="$SS" \
      -v csb="$CSB" -v cms="$CMS" -v cmg="$CMG" -v fill="$FILL" '
    function scaled(origin, id) {
      print
      if (id != "") print "          id: " id " // " mark
      print "          scale: parent.hankoFit // " mark
      print "          transformOrigin: Item." origin " // " mark
      done++
    }
    # CenterSections component: how far the center group reaches from the middle.
    $0 == csb {
      print
      print "    readonly property real hankoLeftReach: centerBox.width / 2 + beginList.width // " mark
      print "    readonly property real hankoRightReach: centerBox.width / 2 + endList.width // " mark
      reach++
      next
    }
    # CenterModules component: pass the reach of its CenterSections up.
    $0 == cmg {
      print
      print "    readonly property real hankoLeftReach: hankoCenterSections.hankoLeftReach // " mark
      print "    readonly property real hankoRightReach: hankoCenterSections.hankoRightReach // " mark
      reach++
      next
    }
    $0 == cms { print; print "      id: hankoCenterSections // " mark; reach++; next }
    $0 == hb { inH = 1; fit = 0 }
    $0 == vb { inH = 0 }
    # The horizontal bar Item: the scale its sections use. It is the hover scale,
    # capped so the left and right sections never reach the center group, and
    # below 1 when even the normal size would overlap (a long title, the tray
    # drawer open, a narrow screen).
    inH && !fit && $0 == fill {
      print
      print "        // " mark ": grow with the strip, but only as far as it fits"
      print "        readonly property real hankoHalf: width / 2 - Style.space(8) - Style.space(12) // " mark
      print "        readonly property real hankoFitLeft: hankoLeftList.width + hankoCenterList.hankoLeftReach > 0 ? hankoHalf / (hankoLeftList.width + hankoCenterList.hankoLeftReach) : 99 // " mark
      print "        readonly property real hankoFitRight: rightModules.width + hankoCenterList.hankoRightReach > 0 ? hankoHalf / (rightModules.width + hankoCenterList.hankoRightReach) : 99 // " mark
      print "        readonly property real hankoFit: Math.max(0.5, Math.min(barStrip.hankoScale, hankoFitLeft, hankoFitRight)) // " mark
      fit = 1
      reach++
      next
    }
    inH && $0 == sl { scaled("Left", "hankoLeftList"); next }
    inH && $0 == sc { scaled("Center", "hankoCenterList"); next }
    inH && $0 == sr { scaled("Right", ""); next }
    inH && $0 == ss { scaled("Right", ""); next }
    $0 == l1 {
      print "      // " mark " BEGIN — the strip grows while hovered; the reserved zone does not"
      print "      property real hankoGrow: hankoHover.hovered && !root.barHidden ? " grow " : 0"
      print "      // The sections of a horizontal bar grow with the strip, from their own side."
      print "      readonly property real hankoScale: root.vertical || barWindow.thickness <= 0 ? 1 : (barWindow.thickness + hankoGrow) / barWindow.thickness"
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
    END { if (done < 3 || reach < 4) exit 3 }
  ' "$FILE" > "$tmp" || { rm -f "$tmp"; die "sections de la barre horizontale introuvables (Omarchy a changé la barre) — rien modifié"; }
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
