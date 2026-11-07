// Hanko desktop widgets — Omarchy shell plugin, loaded as an invisible bar widget
// (a "service" from ~/.config/omarchy/plugins does not load in Omarchy 4).
//
// One transparent window per screen on the "bottom" layer: above the wallpaper,
// below every window, and it never takes a click. Spec: specs/widgets-bureau/fiche.md
//
//   1 screen ............ clock + date + weather bottom-left, music bottom-right
//   several screens ..... widest: weather + music (clock too when no vertical screen)
//                         vertical: big clock + date
//                         others: nothing
// A widget with no data is hidden, never an empty frame.
// Settings (shell.json, on this widget's bar entry): clock, weather, music,
// weatherLocation — e.g. `omarchy bar set hanko.desktop weatherLocation Paris`.

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris

Item {
  id: root

  // Injected by the bar host.
  property var shell: null
  property var manifest: null
  property var bar: null
  property string moduleName: ""
  property var settings: ({})
  property string fixedEdge: ""

  implicitWidth: 0
  implicitHeight: 0

  // One copy of this widget per bar (per screen); only the first screen's copy works.
  readonly property string myScreen: (Window.window && Window.window.screen) ? Window.window.screen.name : ""
  readonly property bool primary: Quickshell.screens.length === 0 || myScreen === "" || myScreen === Quickshell.screens[0].name

  function setting(key, fallback) {
    var v = root.settings ? root.settings[key] : undefined
    if (v === undefined || v === null || v === "") return fallback
    if (v === "false") return false
    if (v === "true") return true
    return v
  }
  readonly property bool showClock: setting("clock", true)
  readonly property bool showWeather: setting("weather", true)
  readonly property bool showMusic: setting("music", true)
  readonly property string weatherLocation: String(setting("weatherLocation", ""))

  // ── Palette (active theme) ─────────────────────────────────────────────
  readonly property string home: Quickshell.env("HOME")
  readonly property string stateDir: home + "/.local/state/omarchy/current"
  property string themeName: ""
  property color noir: "#121010"
  property color creme: "#f1e7d6"
  property color accent: "#ff4a1c"
  // Labels: noir on Vermillon, creme on Cramoisi and Vert billard (contrast).
  readonly property color labelColor: themeName === "hanko-vermillon" ? noir : creme

  FileView {
    path: root.stateDir + "/theme/colors.toml"
    watchChanges: true
    onFileChanged: reload()
    onLoaded: {
      var toml = text()
      var pick = function(key) {
        var m = toml.match(new RegExp("^\\s*" + key + "\\s*=\\s*\"(#[0-9a-fA-F]{6,8})\"", "m"))
        return m ? m[1] : ""
      }
      if (pick("background")) root.noir = pick("background")
      if (pick("foreground")) root.creme = pick("foreground")
      if (pick("accent")) root.accent = pick("accent")
    }
  }
  FileView {
    path: root.stateDir + "/theme.name"
    watchChanges: true
    onFileChanged: reload()
    onLoaded: root.themeName = text().trim()
  }

  // ── Time ───────────────────────────────────────────────────────────────
  property date now: new Date()
  Timer {
    interval: 1000
    running: root.primary
    repeat: true
    triggeredOnStart: true
    onTriggered: root.now = new Date()
  }
  readonly property var loc: Qt.locale()

  // ── Weather (wttr.in, every 30 min; hidden while unknown) ──────────────
  property string weatherTemp: ""
  property string weatherText: ""
  property string weatherPlace: ""

  Process {
    id: weatherProc
    command: ["curl", "-fsS", "--max-time", "8",
              "https://wttr.in/" + encodeURIComponent(root.weatherLocation) + "?format=%t|%C|%l&lang=" + (Qt.locale().name.split("_")[0] || "en")]
    stdout: StdioCollector {
      onStreamFinished: {
        var parts = text.trim().split("|")
        if (parts.length >= 2 && /°/.test(parts[0])) {
          root.weatherTemp = parts[0].replace(/^\+/, "").replace(/[CF]$/, "")
          root.weatherText = parts[1].trim()
          var place = root.weatherLocation.length > 0 ? root.weatherLocation : (parts[2] || "")
          place = place.split(",")[0].trim()
          // Located by IP, wttr.in may answer with coordinates instead of a name.
          root.weatherPlace = /^-?[0-9.]+$/.test(place) ? "" : place
          weatherTimer.interval = 30 * 60 * 1000
        } else {
          weatherTimer.interval = 5 * 60 * 1000
        }
      }
    }
    onExited: function(code) { if (code !== 0) weatherTimer.interval = 5 * 60 * 1000 }
  }
  Timer {
    id: weatherTimer
    interval: 30 * 60 * 1000
    running: root.primary && root.showWeather
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!weatherProc.running) weatherProc.running = true
  }
  onWeatherLocationChanged: if (root.primary && root.showWeather && !weatherProc.running) weatherProc.running = true

  // ── Music (MPRIS) ──────────────────────────────────────────────────────
  readonly property var player: {
    var list = Mpris.players.values
    var fallback = null
    for (var i = 0; i < list.length; i++) {
      if (list[i].isPlaying) return list[i]
      if (!fallback && list[i].trackTitle) fallback = list[i]
    }
    return fallback
  }
  readonly property bool hasMusic: !!player && !!player.trackTitle
  Timer {
    interval: 1000
    running: root.primary && root.hasMusic && root.player.isPlaying
    repeat: true
    onTriggered: if (root.player) root.player.positionChanged()
  }

  // ── Roles per screen ───────────────────────────────────────────────────
  readonly property var screenList: Quickshell.screens
  readonly property bool hasVertical: {
    for (var i = 0; i < screenList.length; i++) if (screenList[i].height > screenList[i].width) return true
    return false
  }
  readonly property string widestName: {
    var best = "", w = -1
    for (var i = 0; i < screenList.length; i++) {
      var s = screenList[i]
      if (s.height > s.width) continue
      if (s.width > w) { w = s.width; best = s.name }
    }
    return best
  }
  function roleFor(screen) {
    if (screenList.length <= 1) return "single"
    if (screen.height > screen.width) return "vertical"
    if (screen.name === widestName) return hasVertical ? "main" : "single"
    return "none"
  }

  Variants {
    model: root.primary ? root.screenList : []

    PanelWindow {
      id: win
      required property var modelData
      screen: modelData
      readonly property string role: root.roleFor(modelData)
      visible: role !== "none"
      color: "transparent"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Bottom
      WlrLayershell.namespace: "hanko-desktop"
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      anchors { top: true; bottom: true; left: true; right: true }
      mask: Region {}

      Item {
        id: canvas
        anchors.fill: parent
        readonly property real cw: width
        readonly property real ch: height
        readonly property real ratio: ch > 0 ? cw / ch : 1.78
        readonly property bool vertical: ch > cw
        readonly property real side: (ratio > 2 ? 0.06 : 0.04) * cw
        readonly property real bottomGap: (ratio <= 1.7 ? 0.06 : 0.07) * ch
        readonly property real labelPx: Math.max(9, ch * 0.017)
        readonly property bool clockHere: root.showClock && (win.role === "single" || win.role === "vertical")
        readonly property bool weatherHere: root.showWeather && root.weatherTemp !== "" && (win.role === "single" || win.role === "main")
        readonly property bool musicHere: root.showMusic && root.hasMusic && (win.role === "single" || win.role === "main")

        // ── Bottom-left: clock, date, weather ──
        Column {
          visible: !canvas.vertical && (canvas.clockHere || canvas.weatherHere)
          x: canvas.side
          anchors.bottom: parent.bottom
          anchors.bottomMargin: canvas.bottomGap
          spacing: canvas.ch * 0.012

          Text {
            visible: canvas.clockHere
            text: Qt.formatTime(root.now, "HH:mm")
            color: root.creme
            font.family: "Anton"
            font.pixelSize: canvas.ch * 0.11
            renderType: Text.CurveRendering
            lineHeight: 0.9
          }
          Text {
            visible: canvas.clockHere
            text: root.loc.toString(root.now, "dddd dd MMMM").toUpperCase()
            color: root.labelColor
            font.family: "SpaceMono Nerd Font"
            font.bold: true
            font.pixelSize: canvas.labelPx
            font.letterSpacing: canvas.labelPx * 0.2
          }
          Rectangle {
            visible: canvas.clockHere && canvas.weatherHere
            width: canvas.ch * 0.045
            height: Math.max(1, canvas.ch * 0.002)
            color: root.labelColor
          }
          Row {
            visible: canvas.weatherHere
            spacing: canvas.ch * 0.012
            Text {
              id: tempText
              text: root.weatherTemp
              color: root.creme
              font.family: "Anton"
              font.pixelSize: canvas.ch * 0.034
              renderType: Text.CurveRendering
            }
            Text {
              anchors.baseline: tempText.baseline
              text: (root.weatherPlace ? root.weatherPlace + " · " : "") + root.weatherText
              color: root.labelColor
              font.family: "SpaceMono Nerd Font"
              font.bold: true
              font.pixelSize: canvas.labelPx
              font.letterSpacing: canvas.labelPx * 0.2
              font.capitalization: Font.AllUppercase
            }
          }
        }

        // ── Vertical screen: big clock on the left, pulsing dot ──
        Column {
          visible: canvas.vertical && canvas.clockHere
          x: canvas.cw * 0.07
          anchors.verticalCenter: parent.verticalCenter
          spacing: 0
          Row {
            spacing: canvas.cw * 0.03
            Text {
              text: Qt.formatTime(root.now, "HH")
              color: root.noir
              font.family: "Anton"
              font.pixelSize: canvas.cw * 0.38
              renderType: Text.CurveRendering
              lineHeight: 0.86
            }
            Rectangle {
              anchors.verticalCenter: parent.verticalCenter
              width: canvas.cw * 0.05; height: width; radius: width / 2
              color: root.accent
              SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.4; duration: 1000; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1; duration: 1000; easing.type: Easing.InOutSine }
              }
            }
          }
          Text {
            text: Qt.formatTime(root.now, "mm")
            color: root.noir
            font.family: "Anton"
            font.pixelSize: canvas.cw * 0.38
            renderType: Text.CurveRendering
            lineHeight: 0.86
          }
          Text {
            text: root.loc.toString(root.now, "dddd dd MMMM").toUpperCase()
            color: root.noir
            font.family: "SpaceMono Nerd Font"
            font.bold: true
            readonly property real px: Math.max(9, canvas.cw * 0.022)
            font.pixelSize: px
            font.letterSpacing: px * 0.2
          }
        }

        // ── Bottom-right: now playing ──
        Column {
          visible: canvas.musicHere && !canvas.vertical
          readonly property real boxW: (canvas.ratio <= 1.7 ? 0.24 : (canvas.ratio > 2 ? 0.17 : 0.22)) * canvas.cw
          width: boxW
          anchors.right: parent.right
          anchors.rightMargin: canvas.side
          anchors.bottom: parent.bottom
          anchors.bottomMargin: canvas.bottomGap
          spacing: canvas.ch * 0.008

          Text {
            anchors.right: parent.right
            text: root.player && root.player.isPlaying ? "EN LECTURE" : "EN PAUSE"
            color: root.labelColor
            font.family: "SpaceMono Nerd Font"
            font.bold: true
            font.pixelSize: canvas.labelPx * 0.85
            font.letterSpacing: canvas.labelPx * 0.25
          }
          Text {
            width: parent.width
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
            text: root.player ? String(root.player.trackTitle).toUpperCase() : ""
            color: root.creme
            font.family: "Anton"
            font.pixelSize: canvas.ch * 0.044
            renderType: Text.CurveRendering
          }
          Text {
            width: parent.width
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
            visible: text.length > 0
            text: root.player && root.player.trackArtist ? String(root.player.trackArtist).toUpperCase() : ""
            color: root.labelColor
            font.family: "SpaceMono Nerd Font"
            font.bold: true
            font.pixelSize: canvas.labelPx * 0.85
            font.letterSpacing: canvas.labelPx * 0.25
          }
          Item {
            width: parent.width
            height: Math.max(2, canvas.ch * 0.003)
            visible: root.player && root.player.positionSupported && root.player.length > 0
            Rectangle { anchors.fill: parent; color: root.labelColor; opacity: 0.3 }
            Rectangle {
              height: parent.height
              width: root.player && root.player.length > 0 ? parent.width * Math.min(1, root.player.position / root.player.length) : 0
              color: root.labelColor
            }
          }
        }
      }
    }
  }
}
