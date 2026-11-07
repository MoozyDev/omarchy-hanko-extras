// Hanko — lock screen skin (loaded by the Hanko hook in Omarchy's LockView.qml).
//
// Installed at ~/.config/omarchy/lock-skin/Skin.qml. Delete that folder (or run
// `hanko lock off`) and the next lock looks exactly like Omarchy's default.
//
// What this file may do: move and resize the password field, hide the blur,
// draw widgets. What it never sees: the password check itself, which stays in
// Omarchy's Service.qml.
//
// Settings you can change — they apply at the next lock.

import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: skin

  // ── Settings ───────────────────────────────────────────────────────────
  // Where the password field sits:
  // "center", "top", "bottom", "bottom-left", "bottom-right", "top-left", "top-right"
  property string fieldPosition: "bottom"
  property int fieldWidth: 320
  property int fieldHeight: 44
  property real darken: 0.35          // wallpaper darkening, 0 = none
  property bool blur: false           // Omarchy blurs by default; Hanko does not
  property bool showClock: true
  property bool showDate: true
  property string localeName: ""      // "" = system locale, e.g. "fr_FR"
  property bool playSound: true
  // ───────────────────────────────────────────────────────────────────────

  // Injected by the hook.
  property Item lockView: null
  property Item inputField: null
  property Item wallpaper: null
  property Item wallpaperEffect: null

  readonly property string home: Quickshell.env("HOME")
  readonly property string stateTheme: home + "/.local/state/omarchy/current/theme"
  readonly property string soundPath: home + "/.local/share/hanko/extras/sounds/verrouillage.wav"

  readonly property bool vertical: height > width
  readonly property bool singleScreen: Quickshell.screens.length <= 1
  readonly property real unit: vertical ? width : height
  readonly property var loc: localeName.length > 0 ? Qt.locale(localeName) : Qt.locale()

  // Palette read from the active theme's colors.toml (Hanko names: noir = background, creme = foreground).
  property color noir: "#121010"
  property color creme: "#f1e7d6"
  property color accent: "#ff4a1c"

  FileView {
    path: skin.stateTheme + "/colors.toml"
    onLoaded: skin.readColors(text())
  }

  function readColors(toml) {
    var pick = function(key) {
      var m = toml.match(new RegExp("^\\s*" + key + "\\s*=\\s*\"(#[0-9a-fA-F]{6,8})\"", "m"))
      return m ? m[1] : ""
    }
    if (pick("background")) noir = pick("background")
    if (pick("foreground")) creme = pick("foreground")
    if (pick("accent")) accent = pick("accent")
  }

  property date now: new Date()
  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: skin.now = new Date()
  }

  // ── Wallpaper: no blur, darkened ───────────────────────────────────────
  onWallpaperEffectChanged: if (wallpaperEffect) wallpaperEffect.blurEnabled = Qt.binding(function() {
    return skin.blur && skin.wallpaper && skin.wallpaper.ready
  })

  // ── Live HANKO title, same as the desktop ──────────────────────────────
  // With the 01 / 02 HANKO wallpapers the desktop draws the title live (sized
  // for the screen, Moozy logo behind it). Draw the same here so the lock
  // matches, instead of the fixed 16:9 picture.
  property bool liveWallpaper: true
  property string themeName: ""
  FileView {
    path: skin.home + "/.local/state/omarchy/current/theme.name"
    onLoaded: skin.themeName = text().trim()
  }
  readonly property var fondByTheme: ({
    "hanko-vermillon": "#e8431c",
    "hanko-cramoisi": "#c8102e",
    "hanko-vert-billard": "#0d6b3e"
  })
  readonly property color fond: fondByTheme[themeName] || accent
  readonly property string backgroundName: lockView ? String(lockView.backgroundPath).split("/").pop() : ""
  readonly property bool liveTitle: liveWallpaper && /^0[12]-hanko/.test(backgroundName) && themeName.indexOf("hanko-") === 0

  Rectangle {
    id: liveBg
    anchors.fill: parent
    visible: skin.liveTitle
    color: skin.fond

    readonly property real logoD: skin.vertical ? skin.width * 0.70 : skin.height * 0.52
    Image {
      width: liveBg.logoD
      height: width
      x: (skin.width - width) / 2 + width * 0.03
      y: skin.height * (skin.vertical ? 0.42 : 0.50) - height / 2
      source: Qt.resolvedUrl("logo-noir.svg")
      sourceSize: Qt.size(Math.ceil(width), Math.ceil(height))
      fillMode: Image.PreserveAspectFit
      smooth: true
    }

    TextMetrics {
      id: refLine
      font.family: "Anton"
      font.pixelSize: 100
      text: skin.vertical ? "HAN" : "HANKO"
    }
    readonly property real capRef: Math.max(1, -refLine.tightBoundingRect.y)
    readonly property real widthRef: Math.max(1, refLine.tightBoundingRect.width)
    readonly property real titlePx: skin.vertical
      ? 100 * Math.min(skin.width * 0.80 / widthRef, skin.height * 0.20 / capRef)
      : 100 * Math.min(skin.width * 0.78 / widthRef, skin.height * 0.46 / capRef)
    readonly property real capPx: capRef * titlePx / 100

    Text {
      visible: !skin.vertical
      text: "HANKO"
      color: skin.creme
      font.family: "Anton"
      font.pixelSize: liveBg.titlePx
      renderType: Text.CurveRendering
      x: (skin.width - contentWidth) / 2
      y: skin.height * 0.41 + liveBg.capPx / 2 - baselineOffset
    }
    Column {
      visible: skin.vertical
      anchors.horizontalCenter: parent.horizontalCenter
      y: skin.height * 0.42 - height / 2
      spacing: liveBg.capPx * 0.12
      Repeater {
        model: ["HAN", "KO"]
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: modelData
          color: skin.creme
          font.family: "Anton"
          font.pixelSize: liveBg.titlePx
          renderType: Text.CurveRendering
          lineHeight: 0.82
        }
      }
    }
  }

  Rectangle {
    anchors.fill: parent
    color: "black"
    opacity: skin.darken
  }

  // ── Password field placement ───────────────────────────────────────────
  readonly property real margin: Math.round(unit * 0.07)

  onInputFieldChanged: placeField()
  onWidthChanged: placeField()
  onHeightChanged: placeField()
  onFieldPositionChanged: placeField()

  function placeField() {
    if (!inputField || width <= 0 || height <= 0) return
    inputField.anchors.centerIn = undefined
    inputField.width = fieldWidth
    inputField.height = fieldHeight
    inputField.color = Qt.binding(function() { return skin.noir })
    var p = fieldPosition
    var cx = (width - fieldWidth) / 2
    var left = margin
    var right = width - fieldWidth - margin
    var top = margin
    var bottom = height - fieldHeight - margin
    var x = cx, y = (height - fieldHeight) / 2
    if (p === "top") { y = top }
    else if (p === "bottom") { y = bottom }
    else if (p === "bottom-left") { x = left; y = bottom }
    else if (p === "bottom-right") { x = right; y = bottom }
    else if (p === "top-left") { x = left; y = top }
    else if (p === "top-right") { x = right; y = top }
    // A vertical screen keeps the field centred under the stacked clock.
    if (vertical && p !== "center") { x = cx; y = Math.round(height * 0.74) }
    inputField.x = Math.round(x)
    inputField.y = Math.round(y)
    inputField.transform = [shake]
  }

  // Wrong password: 3 shakes of 6 px in 240 ms.
  Translate { id: shake }
  SequentialAnimation {
    id: shakeAnim
    loops: 3
    NumberAnimation { target: shake; property: "x"; to: 6; duration: 40 }
    NumberAnimation { target: shake; property: "x"; to: -6; duration: 40 }
    NumberAnimation { target: shake; property: "x"; to: 0; duration: 0 }
  }
  Connections {
    target: skin.lockView
    ignoreUnknownSignals: true
    function onFailedAttemptsChanged() { if (skin.lockView.failedAttempts > 0) shakeAnim.restart() }
  }

  // ── Clock and date ─────────────────────────────────────────────────────
  readonly property string hh: Qt.formatTime(now, "HH")
  readonly property string mm: Qt.formatTime(now, "mm")
  readonly property string dateText: loc.toString(now, "dddd dd MMM").toUpperCase()

  // Vertical screen: big stacked clock "HH / mm", centred, 38 % of the width.
  Column {
    visible: skin.showClock && skin.vertical
    anchors.horizontalCenter: parent.horizontalCenter
    y: Math.round(skin.height * 0.22)
    spacing: 0
    Repeater {
      model: [skin.hh, skin.mm]
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: modelData
        color: skin.creme
        font.family: "Anton"
        font.pixelSize: Math.round(skin.width * 0.38)
        lineHeight: 0.86
      }
    }
  }

  // Horizontal screen: clock bottom-left (4 % / 7 %), 18 % of the height.
  Text {
    id: hClock
    visible: skin.showClock && !skin.vertical
    x: Math.round(skin.width * 0.04)
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Math.round(skin.height * 0.07)
    text: skin.hh + ":" + skin.mm
    color: skin.creme
    font.family: "Anton"
    font.pixelSize: Math.round(skin.height * 0.18)
    lineHeight: 0.9
  }

  Text {
    visible: skin.showDate
    text: skin.dateText
    color: skin.creme
    font.family: "SpaceMono Nerd Font"
    font.pixelSize: 14
    font.letterSpacing: 2
    x: skin.vertical ? Math.round((skin.width - width) / 2) : hClock.x + 4
    y: skin.vertical ? Math.round(skin.height * 0.22 + skin.width * 0.38 * 1.72 + 24)
                     : hClock.y - height - 8
  }

  // ── Lock sound, once (first screen only) ───────────────────────────────
  Process {
    id: soundProc
    command: ["pw-play", skin.soundPath]
  }
  Component.onCompleted: {
    var first = Quickshell.screens.length > 0 ? Quickshell.screens[0].name : ""
    var mine = (Window.window && Window.window.screen) ? Window.window.screen.name : first
    if (playSound && mine === first) soundProc.running = true
  }
}
