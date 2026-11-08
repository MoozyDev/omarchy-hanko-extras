// Hanko screensaver — Omarchy shell plugin, loaded as an invisible bar widget.
//
// Why a bar widget: Omarchy 4 loads bar widgets at startup, while a "service"
// from ~/.config/omarchy/plugins fails to load ("File name case mismatch").
// The widget is 0 px wide; only the copy on the first screen does anything.
//
// It watches idle time itself (same delay as Omarchy: `idle.screensaver` in
// ~/.config/omarchy/shell.json), so Omarchy's own ASCII screensaver is turned
// off by `hanko screensaver on`. The lock still comes from Omarchy.
// Open it by hand: omarchy-shell hanko-screensaver open [animation]
// One window per display; any key, click, scroll or mouse movement closes it.
// Timelines follow specs/ecran-de-veille/animations.md.

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris
import QtQuick.Shapes

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

  // One bar per screen means one copy of this widget per screen: only the
  // copy on the first screen watches idle time and owns the windows.
  readonly property string myScreen: (Window.window && Window.window.screen) ? Window.window.screen.name : ""
  readonly property bool primary: Quickshell.screens.length === 0 || myScreen === "" || myScreen === Quickshell.screens[0].name

  property bool opened: false
  property string current: ""
  property string previous: ""

  // ── Palette ────────────────────────────────────────────────────────────
  readonly property string home: Quickshell.env("HOME")
  readonly property string stateDir: home + "/.local/state/omarchy/current"
  property string themeName: ""
  property color noir: "#121010"
  property color creme: "#f1e7d6"
  property color accent: "#ff4a1c"
  // "fond" is the colour of the variant's images, not a colors.toml key.
  readonly property var fondByTheme: ({
    "hanko-vermillon": "#e8431c",
    "hanko-cramoisi": "#c8102e",
    "hanko-vert-billard": "#0d6b3e"
  })
  readonly property color fond: fondByTheme[themeName] || accent
  readonly property string word: "HANKO"
  readonly property string display: "Anton"
  readonly property string mono: "SpaceMono Nerd Font"

  FileView {
    id: colorsFile
    path: root.stateDir + "/theme/colors.toml"
    watchChanges: true
    onFileChanged: reload()
    onLoaded: root.readColors(text())
  }
  FileView {
    path: root.stateDir + "/theme.name"
    watchChanges: true
    onFileChanged: reload()
    onLoaded: root.themeName = text().trim()
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

  // ── Animations ─────────────────────────────────────────────────────────
  readonly property var animations: ({
    "eclipse": eclipse,
    "orbite": orbite,
    "onde": onde,
    "balayage": balayage,
    "defilement": defilement,
    "phases": phases,
    "phases3": phases3,
    "maree": maree,
    "frequence": frequence,
    "trame": trame,
    "vinyle": vinyle
  })

  // The two "phases" variants never follow each other; "vinyle" needs a track.
  function pickAnimation() {
    var lastWasPhases = root.previous === "phases" || root.previous === "phases3"
    var ids = Object.keys(animations).filter(function(k) {
      if (k === root.previous) return false
      if (lastWasPhases && (k === "phases" || k === "phases3")) return false
      if (k === "vinyle" && !root.player) return false
      return true
    })
    return ids[Math.floor(Math.random() * ids.length)]
  }

  // Media player for "vinyle": the playing one, else one with a track.
  readonly property var player: {
    var list = Mpris.players.values
    var fallback = null
    for (var i = 0; i < list.length; i++) {
      if (list[i].isPlaying) return list[i]
      if (!fallback && list[i].trackTitle) fallback = list[i]
    }
    return fallback
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────
  function show(animation) {
    if (root.opened) return
    colorsFile.reload()
    root.current = (animation && animations[animation]) ? animation : pickAnimation()
    root.opened = true
  }

  function dismiss() {
    if (!root.opened) return
    if (root.current) root.previous = root.current
    root.opened = false
  }

  // Idle delay, in seconds: this widget's own `delay` setting in shell.json
  // (`omarchy bar set hanko.screensaver delay 300`). `hanko screensaver on`
  // moves Omarchy's idle.screensaver value here and sets that one to 0, which
  // is how Omarchy's ASCII screensaver is switched off. 0 = never.
  readonly property int idleSeconds: {
    var d = root.settings ? Number(root.settings.delay) : NaN
    return isNaN(d) ? 150 : Math.max(0, Math.round(d))
  }

  // Respects "stay awake" and apps that inhibit idle (video players).
  IdleMonitor {
    enabled: root.primary && root.idleSeconds > 0
    timeout: Math.max(1, root.idleSeconds)
    respectInhibitors: true
    onIsIdleChanged: if (isIdle) lockCheckThenShow.running = true
  }
  Process {
    id: lockCheckThenShow
    command: ["omarchy-shell", "lock", "isLocked"]
    stdout: StdioCollector {
      onStreamFinished: if (text.trim() !== "true") root.show("")
    }
  }

  IpcHandler {
    target: "hanko-screensaver"
    enabled: root.primary
    function open(animation: string): string { root.show(animation); return "ok" }
    function close(): string { root.dismiss(); return "ok" }
    function list(): string { return Object.keys(root.animations).join(" ") }
  }

  // The lock screen takes over at its own deadline; close underneath it so the
  // desktop is clean after unlocking.
  Process {
    id: lockCheck
    command: ["omarchy-shell", "lock", "isLocked"]
    stdout: StdioCollector {
      onStreamFinished: if (text.trim() === "true") root.dismiss()
    }
  }
  Timer {
    interval: 2000
    repeat: true
    running: root.opened
    onTriggered: if (!lockCheck.running) lockCheck.running = true
  }

  // ── One window per screen ──────────────────────────────────────────────
  Variants {
    model: root.primary ? Quickshell.screens : []

    PanelWindow {
      id: win
      required property var modelData
      screen: modelData
      visible: root.opened
      color: root.noir
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "hanko-screensaver"
      WlrLayershell.keyboardFocus: root.opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
      anchors { top: true; bottom: true; left: true; right: true }

      Item {
        id: stage
        anchors.fill: parent
        focus: true
        opacity: 0

        // No flash: fade in over 1.2 s.
        states: State { when: root.opened; PropertyChanges { target: stage; opacity: 1 } }
        transitions: Transition { NumberAnimation { property: "opacity"; duration: 1200; easing.type: Easing.InOutQuad } }

        Keys.onPressed: function(event) {
          // Media keys drive the player without waking the screen.
          var media = [Qt.Key_MediaPlay, Qt.Key_MediaPause, Qt.Key_MediaTogglePlayPause,
                       Qt.Key_MediaNext, Qt.Key_MediaPrevious, Qt.Key_MediaStop]
          if (media.indexOf(event.key) >= 0) return
          event.accepted = true
          root.dismiss()
        }

        Loader {
          id: anim
          anchors.fill: parent
          active: root.opened
          sourceComponent: root.animations[root.current] || null
        }
      }

      MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.BlankCursor
        property point origin: Qt.point(-1, -1)
        onPositionChanged: function(mouse) {
          if (origin.x < 0) { origin = Qt.point(mouse.x, mouse.y); return }
          if (Math.abs(mouse.x - origin.x) + Math.abs(mouse.y - origin.y) > 6) root.dismiss()
        }
        onPressed: root.dismiss()
        onWheel: root.dismiss()
      }
      Connections {
        target: root
        function onOpenedChanged() {
          if (!root.opened) return
          pointer.origin = Qt.point(-1, -1)
          stage.forceActiveFocus()
        }
      }
    }
  }

  // Anti burn-in: every animation's content drifts ±1.2 % over 180 s.
  component Drift: Item {
    id: drift
    default property alias content: inner.data
    Item {
      id: inner
      width: drift.width
      height: drift.height
      SequentialAnimation on x {
        loops: Animation.Infinite
        NumberAnimation { to: drift.width * 0.012; duration: 45000 }
        NumberAnimation { to: -drift.width * 0.006; duration: 45000 }
        NumberAnimation { to: -drift.width * 0.012; duration: 45000 }
        NumberAnimation { to: 0; duration: 45000 }
      }
      SequentialAnimation on y {
        loops: Animation.Infinite
        NumberAnimation { to: -drift.height * 0.008; duration: 45000 }
        NumberAnimation { to: drift.height * 0.010; duration: 45000 }
        NumberAnimation { to: -drift.height * 0.004; duration: 45000 }
        NumberAnimation { to: 0; duration: 45000 }
      }
    }
  }

  component Disc: Rectangle {
    property real diameter: 100
    width: diameter
    height: diameter
    radius: diameter / 2
  }

  // ÉCLIPSE — black disc crosses the screen; the word turns accent inside it.
  Component {
    id: eclipse
    Rectangle {
      id: s
      color: root.fond
      readonly property bool vertical: height > width
      readonly property real unit: vertical ? width : height
      readonly property real d: vertical ? width * 0.70 : height * 0.55
      property real t: 0
      property real cy: 0.5
      Drift {
        anchors.fill: parent
        Item {
          width: s.width; height: s.height
          Disc {
            id: disc
            diameter: s.d
            color: root.noir
            x: s.vertical ? (s.width - s.d) / 2 : s.width * (0.2 + 0.6 * s.t) - s.d / 2
            y: s.vertical ? s.height * (0.25 + 0.5 * s.t) - s.d / 2 : s.height * s.cy - s.d / 2
          }
          Text {
            id: wordA
            anchors.centerIn: parent
            text: s.vertical ? "HAN\nKO" : root.word
            horizontalAlignment: Text.AlignHCenter
            lineHeight: 0.9
            color: root.creme
            font.family: root.display
            font.pixelSize: s.vertical ? s.width * 0.37 : s.height * 0.46
          }
          Item {
            id: wordBLayer
            anchors.fill: parent
            visible: false
            layer.enabled: true
            Text {
              anchors.centerIn: parent
              text: wordA.text
              horizontalAlignment: Text.AlignHCenter
              lineHeight: 0.9
              color: root.accent
              font: wordA.font
            }
          }
          Item {
            id: maskLayer
            anchors.fill: parent
            visible: false
            layer.enabled: true
            Disc { diameter: s.d; color: "white"; x: disc.x; y: disc.y }
          }
          MultiEffect {
            anchors.fill: parent
            source: wordBLayer
            maskEnabled: true
            maskSource: maskLayer
          }
        }
      }
      SequentialAnimation on t {
        loops: Animation.Infinite
        NumberAnimation { to: 1; duration: 24000; easing.type: Easing.InOutSine }
        ScriptAction { script: s.cy = 0.42 + Math.random() * 0.16 }
        NumberAnimation { to: 0; duration: 24000; easing.type: Easing.InOutSine }
        ScriptAction { script: s.cy = 0.42 + Math.random() * 0.16 }
      }
    }
  }

  // ORBITE — the clock in a black disc, a dot orbiting once a minute.
  Component {
    id: orbite
    Rectangle {
      id: s
      color: root.fond
      readonly property bool vertical: height > width
      readonly property real dDisc: vertical ? width * 0.79 : height * 0.60
      readonly property real dOrbit: vertical ? width * 0.91 : height * 0.70
      readonly property real cx: width / 2
      readonly property real cy: height * 0.46
      property date now: new Date()
      Timer { interval: 100; running: true; repeat: true; triggeredOnStart: true; onTriggered: s.now = new Date() }
      readonly property real seconds: now.getSeconds() + now.getMilliseconds() / 1000
      Drift {
        anchors.fill: parent
        Item {
          width: s.width; height: s.height
          Rectangle {
            width: s.dOrbit; height: s.dOrbit; radius: s.dOrbit / 2
            x: s.cx - s.dOrbit / 2; y: s.cy - s.dOrbit / 2
            color: "transparent"
            border.color: root.noir
            border.width: 1
            opacity: 0.35
          }
          Disc { diameter: s.dDisc; color: root.noir; x: s.cx - s.dDisc / 2; y: s.cy - s.dDisc / 2 }
          Text {
            id: clock
            x: s.cx - width / 2; y: s.cy - height / 2
            text: s.vertical ? Qt.formatTime(s.now, "HH\nmm") : Qt.formatTime(s.now, "HH:mm")
            horizontalAlignment: Text.AlignHCenter
            lineHeight: 0.9
            color: root.creme
            font.family: root.display
            font.pixelSize: s.vertical ? s.width * 0.28 : s.height * 0.23
            Behavior on text { SequentialAnimation {
              NumberAnimation { target: clock; property: "opacity"; to: 0; duration: 600 }
              PropertyAction {}
              NumberAnimation { target: clock; property: "opacity"; to: 1; duration: 600 }
            } }
          }
          Disc {
            readonly property real d: s.vertical ? s.width * 0.03 : s.height * 0.03
            readonly property real a: (s.seconds * 6 - 90) * Math.PI / 180
            diameter: d
            color: root.noir
            x: s.cx + Math.cos(a) * s.dOrbit / 2 - d / 2
            y: s.cy + Math.sin(a) * s.dOrbit / 2 - d / 2
          }
          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: s.height * (s.vertical ? 0.82 : 0.86)
            text: Qt.locale().toString(s.now, "dddd dd MMM").toUpperCase()
            color: root.creme
            font.family: root.mono
            font.bold: true
            readonly property real px: (s.vertical ? s.width : s.height) * 0.024
            font.pixelSize: px
            font.letterSpacing: px * 0.3
          }
        }
      }
    }
  }

  // ONDE — a breathing disc sending out rings.
  Component {
    id: onde
    Rectangle {
      id: s
      color: root.fond
      readonly property bool vertical: height > width
      readonly property real d: vertical ? width * 0.56 : height * 0.40
      readonly property real stroke: Math.max(1, (vertical ? width : height) * 0.0015)
      property real ox: 0
      property real oy: 0
      Behavior on ox { NumberAnimation { duration: 6000; easing.type: Easing.InOutSine } }
      Behavior on oy { NumberAnimation { duration: 6000; easing.type: Easing.InOutSine } }
      Timer {
        interval: 24000; running: true; repeat: true
        onTriggered: { s.ox = (Math.random() * 2 - 1) * s.width * 0.08; s.oy = (Math.random() * 2 - 1) * s.height * 0.08 }
      }
      Drift {
        anchors.fill: parent
        Item {
          id: centre
          width: s.width; height: s.height
          x: s.ox; y: s.oy
          Repeater {
            model: 3
            Rectangle {
              id: ring
              required property int index
              property real k: 1
              width: s.d * k; height: width; radius: width / 2
              x: (s.width - width) / 2; y: (s.height - height) / 2
              color: "transparent"
              border.color: root.creme
              border.width: s.stroke
              opacity: 0
              SequentialAnimation {
                running: true
                PauseAnimation { duration: ring.index * 4000 }
                SequentialAnimation {
                  loops: Animation.Infinite
                  ParallelAnimation {
                    NumberAnimation { target: ring; property: "k"; from: 1; to: 3.4; duration: 12000; easing.type: Easing.OutCubic }
                    NumberAnimation { target: ring; property: "opacity"; from: 0.8; to: 0; duration: 12000; easing.type: Easing.OutCubic }
                  }
                }
              }
            }
          }
          Disc {
            id: core
            diameter: s.d
            color: root.noir
            x: (s.width - s.d) / 2; y: (s.height - s.d) / 2
            SequentialAnimation on scale {
              loops: Animation.Infinite
              NumberAnimation { to: 1.03; duration: 4000; easing.type: Easing.InOutSine }
              NumberAnimation { to: 1; duration: 4000; easing.type: Easing.InOutSine }
            }
          }
          Text {
            anchors.centerIn: core
            text: s.vertical ? "HAN\nKO" : root.word
            horizontalAlignment: Text.AlignHCenter
            lineHeight: 0.9
            color: root.creme
            font.family: root.display
            font.pixelSize: s.vertical ? s.width * 0.15 : s.height * 0.11
            scale: core.scale
          }
        }
      }
    }
  }

  // BALAYAGE — an accent line reveals the word, which then fades away.
  Component {
    id: balayage
    Rectangle {
      id: s
      color: root.noir
      readonly property bool vertical: height > width
      property real t: 0          // line progress 0 → 1
      property real wordOpacity: 1
      property real spacing: 0
      property real wy: 0.5
      property bool reverse: false
      readonly property real p: reverse ? 1 - t : t
      Drift {
        anchors.fill: parent
        Item {
          width: s.width; height: s.height
          Item {
            id: clipBox
            clip: true
            x: s.vertical ? 0 : (s.reverse ? s.width * (0.1 + 0.8 * s.p) : s.width * 0.1)
            y: s.vertical ? s.height * 0.15 : 0
            width: s.vertical ? s.width : s.width * 0.8 * (s.reverse ? 1 - s.p : s.p)
            height: s.vertical ? s.height * 0.7 * s.p : s.height
            Text {
              x: (s.vertical ? (s.width - width) / 2 : (s.width - width) / 2) - clipBox.x
              y: (s.vertical ? (s.height - height) / 2 : s.height * s.wy - height / 2) - clipBox.y
              text: s.vertical ? "HAN\nKO" : root.word
              horizontalAlignment: Text.AlignHCenter
              lineHeight: 0.9
              color: root.creme
              opacity: s.wordOpacity
              font.family: root.display
              readonly property real px: s.vertical ? s.width * 0.36 : s.height * 0.39
              font.pixelSize: px
              font.letterSpacing: px * s.spacing
            }
          }
          Rectangle {
            id: line
            color: root.accent
            width: s.vertical ? s.width : 2
            height: s.vertical ? 2 : s.height
            x: s.vertical ? 0 : s.width * (0.1 + 0.8 * s.p)
            y: s.vertical ? s.height * (0.15 + 0.7 * s.p) : 0
          }
        }
      }
      SequentialAnimation {
        running: true
        loops: Animation.Infinite
        ScriptAction { script: { s.wy = 0.3 + Math.random() * 0.4; s.reverse = Math.random() < 0.5; s.t = 0; s.spacing = 0; s.wordOpacity = 1; line.opacity = 1 } }
        NumberAnimation { target: s; property: "t"; to: 1; duration: 8000; easing.type: Easing.InOutSine }
        ParallelAnimation {
          NumberAnimation { target: line; property: "opacity"; to: 0; duration: 1000 }
          NumberAnimation { target: s; property: "spacing"; to: 0.06; duration: 20000 }
          SequentialAnimation {
            PauseAnimation { duration: 14000 }
            NumberAnimation { target: s; property: "wordOpacity"; to: 0; duration: 6000 }
          }
        }
        PauseAnimation { duration: 2000 }
      }
    }
  }

  // DÉFILEMENT — rows of "HANKO ●" scrolling in alternate directions.
  Component {
    id: defilement
    Rectangle {
      id: s
      color: root.noir
      readonly property bool vertical: height > width
      readonly property int rows: vertical ? 5 : 3
      readonly property real size: vertical ? width * 0.32 : height * 0.28
      readonly property var periods: vertical ? [50, 65, 80, 55, 70] : [60, 80, 70]
      Drift {
        anchors.fill: parent
        Column {
          width: s.width
          y: (s.height - height) / 2
          Repeater {
            model: s.rows
            Item {
              id: band
              required property int index
              width: s.width
              height: Math.round(s.size * 1.25)
              readonly property bool accentRow: s.vertical ? index === 2 : index === 1
              readonly property bool leftward: index % 2 === 0
              Row {
                id: strip
                y: 0
                Repeater {
                  model: 2
                  Row {
                    id: motif
                    Repeater {
                      model: Math.ceil(s.width / (s.size * 3)) + 1
                      Row {
                        spacing: s.size * 0.3
                        leftPadding: s.size * 0.3
                        Text {
                          text: root.word
                          color: band.accentRow ? root.accent : root.creme
                          font.family: root.display
                          font.pixelSize: s.size
                          renderType: Text.CurveRendering
                        }
                        Disc {
                          diameter: s.size * 0.22
                          anchors.verticalCenter: parent.verticalCenter
                          color: band.accentRow ? root.accent : root.creme
                        }
                      }
                    }
                  }
                }
                readonly property real motifWidth: width / 2
                NumberAnimation on x {
                  loops: Animation.Infinite
                  from: band.leftward ? 0 : -strip.motifWidth
                  to: band.leftward ? -strip.motifWidth : 0
                  duration: s.periods[band.index] * 1000 * (0.85 + Math.random() * 0.3)
                }
              }
            }
          }
        }
      }
    }
  }

  // PHASES (6d-1) — a disc of the background colour sweeps over the black moon.
  Component {
    id: phases
    Rectangle {
      id: s
      color: root.fond
      readonly property bool vertical: height > width
      readonly property real d: vertical ? width * 0.70 : height * 0.52
      readonly property real mx: width / 2
      readonly property real my: height * (vertical ? 0.42 : 0.44)
      property real t: 0
      property bool reverse: false
      property real tilt: 0
      Drift {
        anchors.fill: parent
        Item {
          width: s.width; height: s.height
          Disc { diameter: s.d; color: root.noir; x: s.mx - s.d / 2; y: s.my - s.d / 2 }
          Disc {
            id: shadow
            diameter: s.d
            color: root.fond
            readonly property real off: (s.reverse ? -1 : 1) * (-1.6 + 3.2 * s.t) * s.d
            x: s.mx - s.d / 2 + off
            y: s.my - s.d / 2 + off * Math.tan(s.tilt * Math.PI / 180)
          }
          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: s.height * (s.vertical ? 0.70 : 0.76) - height / 2
            text: root.word
            color: root.creme
            font.family: root.display
            font.pixelSize: s.vertical ? s.width * 0.15 : s.height * 0.10
          }
        }
      }
      SequentialAnimation {
        running: true
        loops: Animation.Infinite
        ScriptAction { script: { s.reverse = Math.random() < 0.5; s.tilt = (Math.random() * 2 - 1) * 10; s.t = 0 } }
        NumberAnimation { target: s; property: "t"; to: 1; duration: 48000; easing.type: Easing.InOutSine }
      }
    }
  }

  // PHASES (6d-3) — a darker disc moves behind a hole cut in a plate of the
  // background colour: it is only seen through the hole.
  Component {
    id: phases3
    Rectangle {
      id: s
      color: root.noir
      readonly property bool vertical: height > width
      readonly property real d: vertical ? width * 0.70 : height * 0.52
      readonly property real mx: width / 2
      readonly property real my: height * (vertical ? 0.42 : 0.44)
      readonly property color fondDark: Qt.darker(root.fond, 1.18)
      property real t: 0
      property bool reverse: false
      property real tilt: 0
      Drift {
        anchors.fill: parent
        Item {
          width: s.width; height: s.height
          Disc {
            diameter: s.d
            color: s.fondDark
            readonly property real off: (s.reverse ? -1 : 1) * (-1.6 + 3.2 * s.t) * s.d
            x: s.mx - s.d / 2 + off
            y: s.my - s.d / 2 + off * Math.tan(s.tilt * Math.PI / 180)
          }
          // Plate with a round hole (odd-even fill: rectangle minus circle).
          Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
              fillColor: root.fond
              strokeColor: "transparent"
              fillRule: ShapePath.OddEvenFill
              PathRectangle { x: -s.width; y: -s.height; width: s.width * 3; height: s.height * 3 }
              PathAngleArc { centerX: s.mx; centerY: s.my; radiusX: s.d / 2; radiusY: s.d / 2; startAngle: 0; sweepAngle: 360; moveToStart: true }
            }
          }
          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: s.height * (s.vertical ? 0.70 : 0.76) - height / 2
            text: root.word
            color: root.creme
            font.family: root.display
            font.pixelSize: s.vertical ? s.width * 0.15 : s.height * 0.10
            renderType: Text.CurveRendering
          }
        }
      }
      SequentialAnimation {
        running: true
        loops: Animation.Infinite
        ScriptAction { script: { s.reverse = Math.random() < 0.5; s.tilt = (Math.random() * 2 - 1) * 10; s.t = 0 } }
        NumberAnimation { target: s; property: "t"; to: 1; duration: 48000; easing.type: Easing.InOutSine }
      }
    }
  }

  // MARÉE — a black tide with an irregular wave rises and falls; the word is
  // black above the water and cream below it; an accent line marks the surface.
  Component {
    id: maree
    Rectangle {
      id: s
      color: root.fond
      readonly property bool vertical: height > width
      readonly property real unit: vertical ? width : height
      readonly property real amp: height * 0.019
      readonly property real loopW: 1200 * height / 1080
      property real phase: 0
      property real level: 0.72
      property var ph: [Math.random() * 6.28, Math.random() * 6.28, Math.random() * 6.28]
      function waveY(x) {
        var k = 2 * Math.PI / s.loopW, u = x + s.phase * s.loopW
        return s.height * s.level + s.amp * (0.55 * Math.sin(k * u + s.ph[0]) + 0.30 * Math.sin(2 * k * u + s.ph[1]) + 0.15 * Math.sin(3 * k * u + s.ph[2]))
      }
      readonly property var wavePoints: {
        var pts = [], step = Math.max(8, s.width / 120)
        for (var x = -s.width * 0.04; x <= s.width * 1.04 + step; x += step) pts.push(Qt.point(x, waveY(x)))
        return pts
      }
      readonly property var tidePoints: {
        var pts = s.wavePoints.slice()
        pts.push(Qt.point(s.width * 1.04 + 20, s.height + 20), Qt.point(-s.width * 0.04, s.height + 20))
        return pts
      }
      readonly property string label: vertical ? "HAN\nKO" : root.word
      readonly property real wordPx: vertical ? width * 0.37 : height * 0.46

      Drift {
        anchors.fill: parent
        Item {
          width: s.width; height: s.height
          Text {
            id: wordA
            anchors.centerIn: parent
            text: s.label
            horizontalAlignment: Text.AlignHCenter
            lineHeight: 0.9
            color: root.noir
            font.family: root.display
            font.pixelSize: s.wordPx
            renderType: Text.CurveRendering
          }
          Shape {
            anchors.fill: parent
            ShapePath { fillColor: root.noir; strokeColor: "transparent"; PathPolyline { path: s.tidePoints } }
          }
          Item {
            id: wordBLayer
            anchors.fill: parent
            visible: false
            layer.enabled: true
            Text {
              anchors.centerIn: parent
              text: s.label
              horizontalAlignment: Text.AlignHCenter
              lineHeight: 0.9
              color: root.creme
              font: wordA.font
              renderType: Text.CurveRendering
            }
          }
          Item {
            id: tideMask
            anchors.fill: parent
            visible: false
            layer.enabled: true
            Shape {
              anchors.fill: parent
              ShapePath { fillColor: "white"; strokeColor: "transparent"; PathPolyline { path: s.tidePoints } }
            }
          }
          MultiEffect { anchors.fill: parent; source: wordBLayer; maskEnabled: true; maskSource: tideMask }
          Shape {
            anchors.fill: parent
            ShapePath { fillColor: "transparent"; strokeColor: root.accent; strokeWidth: Math.max(2, s.unit * 0.0023); PathPolyline { path: s.wavePoints } }
          }
        }
      }
      NumberAnimation on phase { from: 0; to: 1; duration: 40000; loops: Animation.Infinite }
      SequentialAnimation {
        running: true
        loops: Animation.Infinite
        // New wave shape each cycle (levels stay 28 % / 72 %: an animation cannot be
        // retargeted while its group runs).
        ScriptAction { script: s.ph = [Math.random() * 6.28, Math.random() * 6.28, Math.random() * 6.28] }
        NumberAnimation { target: s; property: "level"; to: 0.28; duration: 20000; easing.type: Easing.InOutSine }
        NumberAnimation { target: s; property: "level"; to: 0.72; duration: 20000; easing.type: Easing.InOutSine }
      }
    }
  }

  // FRÉQUENCE — the letters drift up and down like a signal, then line up again.
  Component {
    id: frequence
    Rectangle {
      id: s
      color: root.noir
      readonly property bool vertical: height > width
      readonly property var letters: root.word.split("")
      readonly property real px: vertical ? width * 0.25 : height * 0.43
      property var offA: []
      property var offB: []
      property real k: 0          // 0 aligned, 1 at offsets A, 2 at offsets B
      property real back: 1       // 1 then 0 while returning to the line
      function draw() {
        var a = [], b = [], sign = Math.random() < 0.5 ? 1 : -1
        for (var i = 0; i < letters.length; i++) {
          a.push(sign * (0.2 + Math.random() * 0.5))
          b.push(-sign * (0.2 + Math.random() * 0.5))
          sign = -sign
        }
        offA = a; offB = b
      }
      Component.onCompleted: draw()
      function offset(i) {
        if (offA.length <= i) return 0
        if (k <= 1) return offA[i] * k
        return offA[i] + (offB[i] - offA[i]) * Math.min(1, k - 1)
      }
      Drift {
        anchors.fill: parent
        Item {
          width: s.width; height: s.height
          Row {
            visible: !s.vertical
            anchors.centerIn: parent
            spacing: s.px * 0.04
            Repeater {
              model: s.letters
              Text {
                required property int index
                required property string modelData
                text: modelData
                color: root.creme
                font.family: root.display
                font.pixelSize: s.px
                renderType: Text.CurveRendering
                transform: Translate { y: s.offset(index) * s.back * s.px }
              }
            }
          }
          Column {
            visible: s.vertical
            anchors.centerIn: parent
            Repeater {
              model: s.letters
              Text {
                required property int index
                required property string modelData
                text: modelData
                color: root.creme
                font.family: root.display
                font.pixelSize: s.px
                renderType: Text.CurveRendering
                transform: Translate { x: s.offset(index) * s.back * s.px * 0.6 }
              }
            }
          }
          Rectangle {
            id: line
            color: root.accent
            width: s.vertical ? 2 : s.width * 0.70
            height: s.vertical ? s.height * 0.82 : 2
            x: s.vertical ? s.width * 0.18 : (s.width - width) / 2
            y: s.vertical ? (s.height - height) / 2 : s.height / 2 + s.px * 0.62
          }
        }
      }
      SequentialAnimation {
        running: true
        loops: Animation.Infinite
        ScriptAction { script: { s.draw(); s.k = 0; s.back = 1 } }
        PauseAnimation { duration: 6000 }
        ParallelAnimation {
          NumberAnimation { target: s; property: "k"; to: 1; duration: 8000; easing.type: Easing.InOutCubic }
          NumberAnimation { target: line; property: "opacity"; to: 0; duration: 2400 }
        }
        NumberAnimation { target: s; property: "k"; to: 2; duration: 10000; easing.type: Easing.InOutCubic }
        ParallelAnimation {
          NumberAnimation { target: s; property: "back"; to: 0; duration: 8000; easing.type: Easing.InOutCubic }
          SequentialAnimation {
            PauseAnimation { duration: 6800 }
            NumberAnimation { target: line; property: "opacity"; to: 1; duration: 2400 }
          }
        }
        PauseAnimation { duration: 8000 }
      }
    }
  }

  // TRAME — a grid of dots; a wave breathes diagonally across it; the dots in
  // a disc around the centre are accent, the others cream.
  Component {
    id: trame
    Rectangle {
      id: s
      color: root.noir
      readonly property bool vertical: height > width
      readonly property int cols: vertical ? 12 : 32
      readonly property int rows: vertical ? 21 : 18
      readonly property real cellW: width / cols
      readonly property real cellH: height / rows
      readonly property real dotD: (vertical ? width : height) * 0.017
      readonly property real discR: vertical ? 4.8 : 5.6
      property real cx: (cols - 1) / 2
      property real cy: (rows - 1) / 2
      property int dir: 0
      property real t: 0          // seconds
      NumberAnimation on t { from: 0; to: 600; duration: 600000; loops: Animation.Infinite }
      Timer {
        interval: 60000; running: true; repeat: true
        onTriggered: {
          s.dir = Math.floor(Math.random() * 4)
          s.cx = (s.cols - 1) / 2 + (Math.random() * 6 - 3)
          s.cy = (s.rows - 1) / 2 + (Math.random() * 6 - 3)
        }
      }
      Drift {
        anchors.fill: parent
        Item {
          width: s.width; height: s.height
          Repeater {
            model: s.cols * s.rows
            Rectangle {
              required property int index
              readonly property int c: index % s.cols
              readonly property int r: Math.floor(index / s.cols)
              readonly property int cc: (s.dir & 1) ? s.cols - 1 - c : c
              readonly property int rr: (s.dir & 2) ? s.rows - 1 - r : r
              readonly property real v: 0.5 - 0.5 * Math.cos(2 * Math.PI * ((s.t - (cc + rr) * 0.22) / 10))
              width: s.dotD; height: s.dotD; radius: s.dotD / 2
              x: (c + 0.5) * s.cellW - width / 2
              y: (r + 0.5) * s.cellH - height / 2
              color: Math.hypot(c - s.cx, r - s.cy) <= s.discR ? root.accent : root.creme
              scale: 0.3 + 0.7 * v
              opacity: 0.35 + 0.65 * v
            }
          }
        }
      }
    }
  }

  // VINYLE — the playing track as a spinning record (MPRIS). The controls show
  // the player state; media keys drive it without closing the screensaver.
  Component {
    id: vinyle
    Rectangle {
      id: s
      color: root.fond
      readonly property bool vertical: height > width
      readonly property var p: root.player
      readonly property real d: vertical ? width * 0.84 : height * 0.67
      readonly property real cy: height * (vertical ? 0.38 : 0.42)
      readonly property real coverD: vertical ? width * 0.34 : height * 0.28
      readonly property real u: vertical ? width : height
      readonly property string ringText: "HANKO · HANKO · HANKO · "
      property real angle: Math.random() * 360
      property real speed: (p && p.isPlaying) ? 1 : 0
      Behavior on speed { NumberAnimation { duration: 1200; easing.type: Easing.OutCubic } }
      Timer {
        interval: 16; running: true; repeat: true
        onTriggered: s.angle = (s.angle + s.speed * 360 * interval / 20000) % 360
      }
      Drift {
        anchors.fill: parent
        Item {
          width: s.width; height: s.height
          Item {
            width: s.d; height: s.d
            x: (s.width - s.d) / 2
            y: s.cy - s.d / 2
            rotation: s.angle
            Disc { diameter: s.d; color: root.noir }
            Repeater {
              model: 7
              Rectangle {
                required property int index
                readonly property real dd: s.d * (0.46 + index * 0.075)
                width: dd; height: dd; radius: dd / 2
                x: (s.d - dd) / 2; y: (s.d - dd) / 2
                color: "transparent"; border.color: root.creme; border.width: 1; opacity: 0.14
              }
            }
            Repeater {
              model: s.ringText.length
              Text {
                required property int index
                readonly property real a: index / s.ringText.length * 2 * Math.PI
                readonly property real rr: s.d * 0.433
                text: s.ringText[index]
                color: root.creme
                font.family: root.mono
                font.bold: true
                font.pixelSize: s.u * 0.028
                x: s.d / 2 + Math.sin(a) * rr - width / 2
                y: s.d / 2 - Math.cos(a) * rr - height / 2
                rotation: a * 180 / Math.PI
              }
            }
            Disc {
              diameter: s.coverD
              x: (s.d - s.coverD) / 2; y: (s.d - s.coverD) / 2
              color: root.accent
            }
            Image {
              id: cover
              width: s.coverD; height: s.coverD
              x: (s.d - s.coverD) / 2; y: (s.d - s.coverD) / 2
              source: s.p && s.p.trackArtUrl ? s.p.trackArtUrl : ""
              fillMode: Image.PreserveAspectCrop
              visible: false
              layer.enabled: true
            }
            Item {
              id: coverMask
              width: s.coverD; height: s.coverD
              x: cover.x; y: cover.y
              visible: false
              layer.enabled: true
              Disc { diameter: s.coverD; color: "white" }
            }
            MultiEffect {
              x: cover.x; y: cover.y; width: s.coverD; height: s.coverD
              visible: cover.status === Image.Ready
              source: cover; maskEnabled: true; maskSource: coverMask
            }
          }
          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: s.height * (s.vertical ? 0.68 : 0.81)
            width: s.width * 0.8
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: s.p ? (String(s.p.trackTitle) + (s.p.trackArtist ? " — " + s.p.trackArtist : "")).toUpperCase() : ""
            color: root.creme
            font.family: root.mono
            font.bold: true
            font.pixelSize: s.u * 0.022
            font.letterSpacing: s.u * 0.022 * 0.2
          }
          Row {
            anchors.horizontalCenter: parent.horizontalCenter
            y: s.height * (s.vertical ? 0.76 : 0.87)
            spacing: s.u * 0.04
            Text { anchors.verticalCenter: parent.verticalCenter; text: "⏮"; color: root.noir; font.pixelSize: s.u * 0.035 }
            Rectangle {
              width: s.u * 0.096; height: width; radius: width / 2
              color: root.creme
              Text { anchors.centerIn: parent; text: s.p && s.p.isPlaying ? "⏸" : "▶"; color: root.noir; font.pixelSize: s.u * 0.04 }
            }
            Text { anchors.verticalCenter: parent.verticalCenter; text: "⏭"; color: root.noir; font.pixelSize: s.u * 0.035 }
          }
        }
      }
    }
  }
}
