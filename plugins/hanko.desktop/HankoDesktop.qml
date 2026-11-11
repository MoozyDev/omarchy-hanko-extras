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

  // ── Notification sound (specs/notifications) ───────────────────────────
  // Omarchy has no notification sound. Watch the session bus for new
  // notifications and play sounds/notification.wav, at most once per 0.8 s,
  // and never while Omarchy's "do not disturb" is on.
  readonly property bool notificationSound: setting("notificationSound", true)
  readonly property string notifySound: home + "/.local/share/hanko/extras/sounds/notification.wav"
  property bool doNotDisturb: false
  property real lastSoundAt: 0
  FileView {
    path: root.home + "/.local/state/omarchy/notifications/quiet.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: { try { root.doNotDisturb = !!JSON.parse(text()).dnd } catch (e) { root.doNotDisturb = false } }
  }
  Process {
    running: root.primary && root.notificationSound
    command: ["dbus-monitor", "--session", "type='method_call',interface='org.freedesktop.Notifications',member='Notify'"]
    stdout: SplitParser {
      onRead: function(line) { if (line.indexOf("member=Notify") >= 0) root.playNotifySound() }
    }
  }
  Process { id: notifySoundProc; command: ["pw-play", root.notifySound] }
  function playNotifySound() {
    var t = Date.now()
    if (root.doNotDisturb || t - root.lastSoundAt < 800) return
    root.lastSoundAt = t
    notifySoundProc.running = false
    notifySoundProc.running = true
  }

  // ── Live title wallpaper ───────────────────────────────────────────────
  // The HANKO title wallpaper (01-hanko) is a fixed 16:9 picture rendered
  // from this very drawing: cropped on other screen shapes. When it is
  // selected, this plugin draws it live instead, sized for the actual screen
  // and keeping the bottom strip free for the widgets. Any other wallpaper
  // shows as is. (02-hanko-plein, from older theme versions, also matches.)
  readonly property bool liveWallpaper: setting("liveWallpaper", true)
  property string backgroundName: ""
  function liveTitleFor(name) {
    return liveWallpaper && /^0[12]-hanko/.test(name) && themeName.indexOf("hanko-") === 0
  }

  // One background per screen (hanko.background): a screen listed in
  // backgrounds.json shows its own wallpaper, so the live title follows it.
  property var screenBackgrounds: ({})
  function screenBackgroundName(screenName) {
    var path = screenBackgrounds[screenName]
    return typeof path === "string" && path !== "" ? path.split("/").pop() : backgroundName
  }
  FileView {
    path: root.home + "/.local/state/hanko/backgrounds.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      var parsed = ({})
      try { parsed = JSON.parse(text() || "{}") } catch (e) { parsed = ({}) }
      root.screenBackgrounds = parsed && typeof parsed === "object" && !Array.isArray(parsed) ? parsed : ({})
    }
    onLoadFailed: root.screenBackgrounds = ({})
  }
  readonly property var fondByTheme: ({
    "hanko-vermillon": "#e8431c",
    "hanko-cramoisi": "#c8102e",
    "hanko-vert-billard": "#0d6b3e"
  })
  readonly property color fond: fondByTheme[themeName] || accent

  Process {
    id: bgProc
    command: ["readlink", "-f", root.stateDir + "/background"]
    stdout: StdioCollector {
      onStreamFinished: root.backgroundName = text.trim().split("/").pop()
    }
  }
  Timer {
    interval: 2000
    running: root.primary
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!bgProc.running) bgProc.running = true
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
      readonly property bool liveTitleHere: root.liveTitleFor(root.screenBackgroundName(modelData.name))
      visible: role !== "none" || liveTitleHere
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

        // ── Live title wallpaper (under the widgets) ──
        Rectangle {
          id: liveBg
          anchors.fill: parent
          visible: win.liveTitleHere
          color: root.fond

          // Moozy logo (V1, black symbol) where the disc used to be: centred,
          // 52 % of the height (70 % of the width on a vertical screen).
          // logo/GUIDE.md: V1 is nudged 3 % of its diameter to the right.
          readonly property real discD: canvas.vertical ? canvas.cw * 0.70 : canvas.ch * 0.52
          Image {
            width: liveBg.discD
            height: width
            x: (canvas.cw - width) / 2 + width * 0.03
            y: canvas.ch * (canvas.vertical ? 0.42 : 0.50) - height / 2
            source: Qt.resolvedUrl("logo-noir.svg")
            sourceSize: Qt.size(Math.ceil(width), Math.ceil(height))
            fillMode: Image.PreserveAspectFit
            smooth: true
            asynchronous: false
          }

          // Title: as large as fits in the title zone, never into the widget strip.
          //   horizontal: one line, ≤ 78 % of the width, caps between 18 % and 64 % of the height
          //   vertical:   "HAN / KO", ≤ 80 % of the width, centred at 42 % of the height
          TextMetrics {
            id: refLine
            font.family: "Anton"
            font.pixelSize: 100
            text: canvas.vertical ? "HAN" : "HANKO"
          }
          readonly property real capRef: Math.max(1, -refLine.tightBoundingRect.y)
          readonly property real widthRef: Math.max(1, refLine.tightBoundingRect.width)
          readonly property real titlePx: canvas.vertical
            ? 100 * Math.min(canvas.cw * 0.80 / widthRef, canvas.ch * 0.20 / capRef)
            : 100 * Math.min(canvas.cw * 0.78 / widthRef, canvas.ch * 0.46 / capRef)
          readonly property real capPx: capRef * titlePx / 100

          Text {
            id: titleText
            visible: !canvas.vertical
            text: "HANKO"
            color: root.creme
            font.family: "Anton"
            font.pixelSize: liveBg.titlePx
            renderType: Text.CurveRendering
            x: (canvas.cw - contentWidth) / 2
            // Caps centred in the 18 %–64 % zone.
            y: canvas.ch * 0.41 + liveBg.capPx / 2 - baselineOffset
          }
          Column {
            visible: canvas.vertical
            anchors.horizontalCenter: parent.horizontalCenter
            y: canvas.ch * 0.42 - height / 2
            spacing: liveBg.capPx * 0.12
            Repeater {
              model: ["HAN", "KO"]
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: modelData
                color: root.creme
                font.family: "Anton"
                font.pixelSize: liveBg.titlePx
                renderType: Text.CurveRendering
                lineHeight: 0.82
              }
            }
          }
        }

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

        // ── Vertical screen: big clock on the left, stacked HH / pulsing dot / mm ──
        Column {
          id: verticalClock
          visible: canvas.vertical && canvas.clockHere
          // 20 px further right than the old 7 % margin (Moozy, 2026-11-11).
          x: canvas.cw * 0.07 + 20
          anchors.verticalCenter: parent.verticalCenter
          spacing: 0
          readonly property real digitsWidth: Math.max(hoursText.width, minutesText.width)
          Text {
            id: hoursText
            text: Qt.formatTime(root.now, "HH")
            color: root.noir
            font.family: "Anton"
            font.pixelSize: canvas.cw * 0.38
            renderType: Text.CurveRendering
            lineHeight: 0.86
          }
          // The separator on its own line, centred under the hours, so the
          // clock reads HH / · / mm on a portrait screen.
          Item {
            width: verticalClock.digitsWidth
            height: dot.height * 1.8
            Rectangle {
              id: dot
              anchors.centerIn: parent
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
            id: minutesText
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
