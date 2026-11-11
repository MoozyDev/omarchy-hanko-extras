// Hanko Background — Omarchy's omarchy.background with one wallpaper per screen.
//
// Stock Omarchy draws the same wallpaper on every screen. Here:
//   - choosing a background (double-click on the desktop, background switcher,
//     `omarchy theme bg next`, `omarchy theme bg set`) only changes ONE screen:
//     the one double-clicked, otherwise the focused one;
//   - a theme switch (themeTransition / setInstant) resets every screen to the
//     theme's background, as stock Omarchy does;
//   - the choice per screen survives restarts, in ~/.local/state/hanko/backgrounds.json
//     ({ "<output name>": "<image path>" }), also read by hanko.desktop.
// Videos stay global (OWE draws them on every screen).
// Everything else is the stock plugin, unchanged; Hanko changes are marked "Hanko".

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Item {
  id: root

  property var shell: null
  property bool suspended: false
  readonly property string home: Quickshell.env("HOME")
  readonly property string stateHome: home + "/.local/state"
  readonly property string currentBackgroundLink: stateHome + "/omarchy/current/background"
  readonly property string currentThemeBackgrounds: stateHome + "/omarchy/current/theme/backgrounds"

  // ── Hanko: one background per screen ──────────────────────────────────
  readonly property string screensDir: stateHome + "/hanko"
  readonly property string screensFile: screensDir + "/backgrounds.json"
  // Output name ("DP-2") -> image path. A screen missing here shows the
  // shared background (the theme's, or the last one chosen before Hanko).
  property var screenBackgrounds: ({})
  property bool screensLoaded: false
  // Set by a double-click so the background chosen next lands on the screen
  // that was clicked, wherever the keyboard focus is.
  property string pendingScreen: ""

  // A portrait screen shows "<dir>/vertical/<name>-vertical.<ext>" when the
  // theme ships one (specs/fond-par-ecran), else the landscape image cropped.
  function verticalVariant(path) {
    path = String(path || "")
    if (!path || isVideo(path) || path.indexOf("/vertical/") !== -1) return ""
    var slash = path.lastIndexOf("/")
    var file = path.substring(slash + 1)
    var dot = file.lastIndexOf(".")
    if (dot <= 0) return ""
    return path.substring(0, slash) + "/vertical/" + file.substring(0, dot) + "-vertical" + file.substring(dot)
  }

  function screenBackground(name) {
    var path = screenBackgrounds[name]
    return typeof path === "string" ? path : ""
  }

  function targetScreenName() {
    var name = pendingScreen
    pendingScreen = ""
    pendingScreenTimer.stop()
    if (!name && Hyprland.focusedMonitor) name = String(Hyprland.focusedMonitor.name || "")
    return name
  }

  // A background chosen by the user: only one screen changes.
  function setBackgroundForChosenScreen(path) {
    path = String(path || "").trim()
    if (!path) return
    var name = targetScreenName()
    if (!name || isVideo(path)) {
      resetScreens()
      setBackground(path, false)
      return
    }
    var next = {}
    // Pin every screen to what it shows now, so that only `name` changes
    // even if the shared background moves later.
    for (var i = 0; i < Quickshell.screens.length; i++) {
      var other = Quickshell.screens[i].name
      next[other] = screenBackground(other) || displayedBackground
    }
    for (var known in screenBackgrounds) if (next[known] === undefined) next[known] = screenBackgrounds[known]
    next[name] = path
    screenBackgrounds = next
    requestNativeSize(path)
    saveScreens()
  }

  function setScreen(name, path) {
    pendingScreen = String(name || "")
    setBackgroundForChosenScreen(path)
  }

  function resetScreens() {
    if (Object.keys(screenBackgrounds).length === 0) return
    screenBackgrounds = ({})
    saveScreens()
  }

  function saveScreens() {
    if (!screensLoaded) return
    screensView.setText(JSON.stringify(screenBackgrounds, null, 2) + "\n")
  }

  function loadScreens(raw) {
    var parsed = ({})
    try { parsed = JSON.parse(String(raw || "{}")) } catch (e) { parsed = ({}) }
    var clean = {}
    if (parsed && typeof parsed === "object" && !Array.isArray(parsed)) {
      for (var name in parsed) {
        if (typeof parsed[name] === "string" && parsed[name] !== "" && !isVideo(parsed[name])) clean[name] = parsed[name]
      }
    }
    screenBackgrounds = clean
    screensLoaded = true
    for (var n in clean) requestNativeSize(clean[n])
  }

  Timer {
    id: pendingScreenTimer
    interval: 120000
    repeat: false
    onTriggered: root.pendingScreen = ""
  }

  Process {
    id: screensDirProc
    command: ["mkdir", "-p", root.screensDir]
    onExited: screensView.reload()
  }

  FileView {
    id: screensView
    path: root.screensFile
    blockLoading: false
    printErrors: false
    onLoaded: root.loadScreens(text())
    onLoadFailed: root.loadScreens("{}")
  }

  property string currentBackground: ""
  property string displayedBackground: ""
  property string incomingBackground: ""
  property string oldBackground: ""
  // A theme switch names its next background before it has staged the rest of
  // the theme, so the incoming frame can decode while that work runs. A large
  // WebP takes ~130ms to decode at any sourceSize, which the reveal would
  // otherwise wait out after the transition arrives.
  property string preparedBackground: ""
  // The prepare and transition calls travel as separate IPC clients, so a
  // prepare can land after its transition. The path it names then must not be
  // decoded again.
  property string lastTransitionPath: ""
  // Native pixel size per wallpaper path, read from the file header before
  // the image loads. Decoding at screen size only saves memory for wallpapers
  // at least as large as the screen: with PreserveAspectCrop Qt scales the
  // decode up to cover sourceSize, so a smaller wallpaper would cost the
  // screen's worth of pixels instead of its own.
  property var nativeSizes: ({})
  property var sizeQueue: []
  property bool finishingTransition: false
  property int backgroundVersion: 0
  property int reloadVersion: 0
  property int revealStartedVersion: -1
  property int pendingThemeVersion: -1
  property string pendingColorsRaw: ""
  property string pendingShellRaw: ""
  property real revealProgress: 1
  readonly property bool ready: {
    if (isVideo(displayedBackground)) return true
    if (backgrounds.instances.length === 0) return false
    for (var panel of backgrounds.instances) {
      if (!panel.backgroundReady) return false
    }
    return true
  }

  function isVideo(path) {
    return Util.isVideoPath(path)
  }

  function imageUrl(path) {
    return Util.fileUrl(path)
  }

  function refreshBackground() {
    if (!readlinkProc.running) readlinkProc.running = true
  }

  // The desktop must never be left without a wallpaper. A path that stops
  // loading, say one that ran through a theme since replaced, is resolved
  // again from the background link, which a theme switch always repoints.
  // Only a different path is taken, so a file that is there but unreadable
  // cannot loop. Resolving runs out of process, so a background chosen in the
  // meantime wins over what it finds; if that one fails too, it is resolved
  // in turn once the running lookup is done.
  property string failedBackground: ""
  property int recoverVersion: -1

  function recoverBackground(failedPath) {
    if (!failedPath || failedPath !== displayedBackground) return
    failedBackground = failedPath
    if (recoverProc.running) return
    recoverVersion = backgroundVersion
    recoverProc.running = true
  }

  function finishRecovery(path) {
    path = String(path || "").trim()
    var failedPath = failedBackground
    failedBackground = ""
    if (recoverVersion !== backgroundVersion) {
      recoverBackground(failedPath)
      return
    }
    if (!path || path === failedPath) return
    setBackground(path, true)
  }

  function setBackground(path, instant) {
    if (instant) reloadVersion += 1
    transitionBackground("", path, path, instant, instant)
  }

  function transitionBackground(fromPath, path, finalPath, instant, force) {
    path = String(path || "").trim()
    finalPath = String(finalPath || path).trim()
    fromPath = String(fromPath || "").trim()
    if (!path || (!force && finalPath === currentBackground)) return
    if (path !== preparedBackground) preparedBackground = ""
    preparedBackgroundTimer.stop()
    lastTransitionPath = path
    // The incoming frame gates the reveal, so its size is read first.
    requestNativeSize(path)
    requestNativeSize(fromPath || displayedBackground)
    requestNativeSize(finalPath)
    currentBackground = finalPath
    backgroundVersion += 1
    failedBackground = ""
    revealStartedVersion = -1

    // OWE draws a video background and fades the last still into it. That
    // still stays on screen until OWE has the first frame and suspends this
    // layer, so the desktop does not show an empty background meanwhile. A
    // running reveal finishes on its incoming still, which OWE fades from.
    if (!instant && !root.suspended && displayedBackground && isVideo(path) && !isVideo(displayedBackground)) return

    revealAnimation.stop()
    finishingTransition = false

    // Video frames are not fed through the image-only reveal stack. Switching
    // instantly also avoids decoding two full videos during a transition.
    if (instant || !displayedBackground || isVideo(path) || isVideo(displayedBackground)) {
      oldBackground = ""
      incomingBackground = ""
      preparedBackground = ""
      displayedBackground = finalPath
      revealProgress = 1
      return
    }

    oldBackground = fromPath || displayedBackground
    incomingBackground = path
    revealProgress = 0
  }

  function setPendingTheme(colorsB64, shellB64) {
    pendingColorsRaw = Util.decodeBase64(colorsB64)
    pendingShellRaw = Util.decodeBase64(shellB64)
    pendingThemeVersion = backgroundVersion
    pendingThemeFallbackTimer.restart()
  }

  function applyPendingTheme() {
    // Background polling can advance backgroundVersion while a theme switch is
    // pending; the latest theme payload should still apply.
    if (pendingThemeVersion < 0) return
    pendingThemeFallbackTimer.stop()
    Commons.Color.loadColors(pendingColorsRaw)
    // Commons.Color.loadShell also refreshes Style so the type scale flips with the
    // background reveal instead of waiting for a separate reload path.
    Commons.Color.loadShell(pendingShellRaw)
    Style.scheduleRefresh()
    pendingThemeVersion = -1
    pendingColorsRaw = ""
    pendingShellRaw = ""
  }

  function transitionBackgroundWithTheme(fromPath, path, finalPath, colorsB64, shellB64) {
    transitionBackground(fromPath, path, finalPath, false, true)
    setPendingTheme(colorsB64, shellB64)
    if (!incomingBackground || revealProgress >= 1) applyPendingTheme()
  }

  function startReveal(panel) {
    if (!incomingBackground) return
    panel.maskReady = true
    if (revealStartedVersion === backgroundVersion) return
    revealStartedVersion = backgroundVersion
    applyPendingTheme()
    revealAnimation.restart()
  }

  function prepareBackground(path) {
    path = String(path || "").trim()
    // Only a still that is not already on screen is worth decoding ahead.
    if (!path || isVideo(path) || path === lastTransitionPath || path === displayedBackground) return
    requestNativeSize(path)
    preparedBackground = path
    preparedBackgroundTimer.restart()
  }

  function requestNativeSize(path) {
    if (!path || isVideo(path) || nativeSizes[path] !== undefined || sizeQueue.indexOf(path) !== -1) return
    sizeQueue = sizeQueue.concat([path])
    probeNextSize()
  }

  function probeNextSize() {
    if (sizeProbe.running || sizeQueue.length === 0) return
    sizeProbe.path = sizeQueue[0]
    sizeProbe.command = ["magick", "identify", "-ping", "-format", "%w %h", sizeProbe.path]
    sizeProbe.running = true
  }

  // Each theme switch names fresh snapshot paths, so keep only the sizes of
  // the wallpapers still in play.
  function pruneNativeSizes() {
    var kept = {}
    var paths = [displayedBackground, incomingBackground, oldBackground, preparedBackground]
    for (var i = 0; i < paths.length; i++) {
      if (paths[i] && nativeSizes[paths[i]] !== undefined) kept[paths[i]] = nativeSizes[paths[i]]
    }
    nativeSizes = kept
  }

  function openSelector() {
    if (!bgSwitchProc.running) bgSwitchProc.running = true
  }

  function openThemeSwitcher() {
    var payload = JSON.stringify({ source: "themes" })

    // A cloned background may not summon the picker in-process, so it takes
    // the IPC route instead.
    if (!root.shell || !root.shell.summon("omarchy.image-picker", payload))
      Util.execArgv(["omarchy-shell", "shell", "summon", "omarchy.image-picker", payload])
  }

  Process {
    id: bgSwitchProc
    command: ["bash", "-c", "background=$(omarchy-theme-bg-switcher); [[ -n $background ]] && omarchy-theme-bg-set \"$background\""]
    onExited: {
      // Hanko: a cancelled picker must not leave its screen for a later choice.
      root.pendingScreen = ""
      root.refreshBackground()
    }
  }

  Process {
    id: sizeProbe
    property string path: ""
    stdout: StdioCollector { id: sizeProbeOut }
    onExited: function(exitCode) {
      var parts = String(sizeProbeOut.text || "").trim().split(/\s+/)
      var width = exitCode === 0 ? parseInt(parts[0], 10) : 0
      var height = exitCode === 0 ? parseInt(parts[1], 10) : 0
      var known = Object.assign({}, root.nativeSizes)
      // An unreadable header records 0x0, which decodes at screen size.
      known[path] = { width: width > 0 ? width : 0, height: height > 0 ? height : 0 }
      root.nativeSizes = known
      root.sizeQueue = root.sizeQueue.filter(function(queued) { return queued !== sizeProbe.path })
      root.probeNextSize()
    }
  }

  Process {
    id: readlinkProc
    command: ["readlink", "-f", root.currentBackgroundLink]
    stdout: StdioCollector {
      onStreamFinished: root.setBackground(String(text || "").trim(), false)
    }
  }

  // The link's target when it exists, or else the theme's first background,
  // so a link left dangling still finds a wallpaper.
  Process {
    id: recoverProc
    command: [
      "bash", "-c",
      'target=$(readlink -f "$1"); if [[ -e $target ]]; then echo "$target"; else ' +
      'find "$2" -maxdepth 1 -type f \\( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \\) | sort | head -n 1; fi',
      "resolve", root.currentBackgroundLink, root.currentThemeBackgrounds
    ]
    stdout: StdioCollector {
      onStreamFinished: root.finishRecovery(text)
    }
  }

  ShellIpc {
    target: "background"

    function refresh(): void {
      root.refreshBackground()
    }

    // Hanko: a chosen background (omarchy-theme-bg-set) changes one screen.
    function set(path: string): void {
      root.setBackgroundForChosenScreen(path)
    }

    // Hanko: setInstant comes from a theme switch, so every screen follows.
    function setInstant(path: string): void {
      root.resetScreens()
      root.setBackground(path, true)
    }

    // Hanko: `omarchy-shell background setScreen DP-1 /path/image.png`
    function setScreen(screen: string, path: string): void {
      root.setScreen(screen, path)
    }

    // Hanko: every screen back to the shared background.
    function resetScreens(): void {
      root.resetScreens()
    }

    // Hanko: the per-screen choices, as JSON.
    function screens(): string {
      return JSON.stringify(root.screenBackgrounds)
    }

    function setSuspended(value: string): void {
      root.suspended = value === "true"
    }

    function transition(fromPath: string, path: string): void {
      root.resetScreens()
      root.transitionBackground(fromPath, path, path, false, false)
    }

    function themeTransition(fromPath: string, path: string, finalPath: string, colorsB64: string, shellB64: string): void {
      root.resetScreens()
      root.transitionBackgroundWithTheme(fromPath, path, finalPath, colorsB64, shellB64)
    }

    function prepare(path: string): void {
      root.prepareBackground(path)
    }
  }

  // A prepared frame that no transition claims, say from a theme switch that
  // failed after naming it, must not hold its decoded texture indefinitely.
  Timer {
    id: preparedBackgroundTimer
    interval: 5000
    repeat: false
    onTriggered: root.preparedBackground = ""
  }

  Timer {
    id: pendingThemeFallbackTimer
    interval: 300
    repeat: false
    onTriggered: root.applyPendingTheme()
  }

  NumberAnimation {
    id: revealAnimation
    target: root
    property: "revealProgress"
    from: 0
    to: 1
    duration: Style.duration(840)
    easing.type: Easing.OutCubic
    onFinished: {
      if (root.incomingBackground) {
        // After a video was chosen during the reveal, the incoming still
        // stays until OWE takes the background.
        root.displayedBackground = root.currentBackground && !root.isVideo(root.currentBackground)
          ? root.currentBackground : root.incomingBackground
        root.finishingTransition = true
      }
      root.revealProgress = 1
    }
  }

  Component.onCompleted: {
    screensDirProc.running = true
    refreshBackground()
  }

  Variants {
    id: backgrounds
    model: Quickshell.screens

    PanelWindow {
      id: panel
      required property var modelData

      screen: modelData
      visible: !remapGuard.remapping && !root.suspended
      anchors { top: true; bottom: true; left: true; right: true }

      ScreenMoveRemap {
        id: remapGuard
        window: panel
      }
      color: "transparent"
      // Keep render updates enabled. The background layer has been observed to
      // lose its committed buffer while parked with updatesEnabled=false,
      // leaving a black desktop until omarchy-shell is restarted. A still
      // wallpaper costs nothing to keep enabled. OWE manages video layers.
      updatesEnabled: true

      property bool maskReady: false
      property int readyFrames: 0
      readonly property bool backgroundReady: base.ready && readyFrames >= 2

      FrameAnimation {
        running: base.ready && panel.readyFrames < 2
        onTriggered: panel.readyFrames += 1
      }

      // Decode the wallpaper at the size this screen can show, not the size
      // it was shipped at. With PreserveAspectCrop Qt takes sourceSize as the
      // area to cover, so this is the smallest decode that still fills the
      // screen. Stock wallpapers go up to 10456x3455 (144 MB as RGBA); a
      // 1080p laptop paid all of that for the 8 MB it can display, and paid
      // it up to three times over during a transition. The images wait for
      // the window's size and the wallpaper's native size so nothing is ever
      // decoded at native size first, and a wallpaper smaller than the screen
      // is decoded at its own size rather than scaled up to cover the screen.
      readonly property bool sized: width > 0 && height > 0
      readonly property int decodeWidth: sized ? Math.ceil(width * screen.devicePixelRatio) : 0
      readonly property int decodeHeight: sized ? Math.ceil(height * screen.devicePixelRatio) : 0

      function decodeSize(path) {
        if (!sized || !path) return Qt.size(0, 0)
        var native = root.nativeSizes[path]
        if (native === undefined) return Qt.size(0, 0)
        if (native.width > 0 && (native.width < decodeWidth || native.height < decodeHeight)) return Qt.size(native.width, native.height)
        return Qt.size(decodeWidth, decodeHeight)
      }

      function maybeStartReveal() {
        if (!root.incomingBackground || root.revealProgress !== 0 || maskReady) return
        if (incomingFrame.status !== Image.Ready) return
        Qt.callLater(function() {
          if (!root.incomingBackground || root.revealProgress !== 0 || maskReady) return
          if (incomingFrame.status !== Image.Ready) return
          root.startReveal(panel)
        })
      }

      WlrLayershell.namespace: "omarchy-background"
      WlrLayershell.layer: WlrLayer.Background
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      exclusionMode: ExclusionMode.Ignore

      // OWE owns video backgrounds. This layer draws stills, and stays empty
      // behind a video so OWE's own layer shows through.
      BackgroundMedia {
        id: base
        anchors.fill: parent
        path: root.displayedBackground
        version: root.reloadVersion
        cached: true
        constrainDecode: true
        decodeSize: panel.decodeSize(root.displayedBackground)
        onFailedChanged: if (failed) root.recoverBackground(path)
        onReadyChanged: {
          panel.readyFrames = 0
          if (ready && root.finishingTransition) {
            root.incomingBackground = ""
            root.oldBackground = ""
            root.preparedBackground = ""
            root.finishingTransition = false
            root.pruneNativeSizes()
          }
        }
      }

      Image {
        id: oldFrame
        anchors.fill: parent
        readonly property size decode: panel.decodeSize(root.oldBackground)
        source: decode.width > 0 ? root.imageUrl(root.oldBackground) : ""
        sourceSize.width: decode.width
        sourceSize.height: decode.height
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        smooth: true
        mipmap: true
        visible: root.oldBackground !== "" && root.revealProgress < 1
        onStatusChanged: panel.maybeStartReveal()
      }

      Item {
        id: incomingLayer
        anchors.fill: parent
        visible: root.incomingBackground !== "" && incomingFrame.status === Image.Ready && (root.revealProgress >= 1 || panel.maskReady)
        layer.enabled: root.incomingBackground !== "" && root.revealProgress < 1
        layer.smooth: true
        layer.effect: MultiEffect {
          maskEnabled: true
          maskSource: revealMask
          maskThresholdMin: 0.5
          maskSpreadAtMin: 0.02
        }

        Image {
          id: incomingFrame
          anchors.fill: parent
          // The same URL and size as a prepared frame keeps its decoded
          // image, so a transition to it can reveal at once.
          readonly property string framePath: root.incomingBackground || root.preparedBackground
          readonly property size decode: panel.decodeSize(framePath)
          source: decode.width > 0 ? root.imageUrl(framePath) : ""
          sourceSize.width: decode.width
          sourceSize.height: decode.height
          fillMode: Image.PreserveAspectCrop
          asynchronous: true
          cache: false
          smooth: true
          mipmap: true
          onStatusChanged: panel.maybeStartReveal()
        }
      }

      Item {
        id: revealMask
        anchors.fill: parent
        visible: false
        layer.enabled: true

        readonly property real slant: -0.18
        readonly property real centerTop: width / 2 - slant * height / 2
        readonly property real centerBottom: width / 2 + slant * height / 2
        readonly property real reach: width / 2 + Math.abs(slant) * height / 2 + 4
        readonly property real spread: reach * root.revealProgress

        Shape {
          anchors.fill: parent
          antialiasing: true
          preferredRendererType: Shape.CurveRenderer
          ShapePath {
            fillColor: "white"
            strokeColor: "transparent"
            startX: revealMask.centerTop - revealMask.spread; startY: 0
            PathLine { x: revealMask.centerTop + revealMask.spread; y: 0 }
            PathLine { x: revealMask.centerBottom + revealMask.spread; y: revealMask.height }
            PathLine { x: revealMask.centerBottom - revealMask.spread; y: revealMask.height }
            PathLine { x: revealMask.centerTop - revealMask.spread; y: 0 }
          }
        }
      }

      // Hanko: this screen's own background, drawn over the shared one. A
      // file that no longer loads (say, from a removed theme) drops out of
      // the list and the shared background shows again.
      readonly property string ownBackground: root.screenBackground(modelData.name)

      BackgroundMedia {
        id: own
        anchors.fill: parent
        visible: panel.ownBackground !== "" && ready
        path: panel.ownBackground
        cached: true
        constrainDecode: true
        decodeSize: panel.decodeSize(panel.ownBackground)
        onFailedChanged: {
          if (!failed || !panel.ownBackground) return
          var next = {}
          for (var name in root.screenBackgrounds)
            if (name !== panel.modelData.name) next[name] = root.screenBackgrounds[name]
          root.screenBackgrounds = next
          root.saveScreens()
        }
      }

      // Hanko: vertical version on a portrait screen, over everything else.
      // A theme without one fails to load here and the landscape image stays.
      readonly property bool portrait: panel.height > panel.width
      readonly property string shownBackground: panel.ownBackground || root.currentBackground
      readonly property string verticalCandidate: portrait ? root.verticalVariant(shownBackground) : ""
      property string verticalMissing: ""
      readonly property string verticalBackground: verticalCandidate !== verticalMissing ? verticalCandidate : ""

      BackgroundMedia {
        id: vertical
        anchors.fill: parent
        visible: panel.verticalBackground !== "" && ready
        path: panel.verticalBackground
        cached: true
        constrainDecode: true
        decodeSize: Qt.size(panel.decodeWidth, panel.decodeHeight)
        onFailedChanged: if (failed && panel.verticalBackground) panel.verticalMissing = panel.verticalBackground
      }

      Connections {
        target: root
        function onIncomingBackgroundChanged() {
          panel.maskReady = false
          panel.maybeStartReveal()
        }
      }

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onDoubleClicked: function(mouse) {
          if (mouse.button === Qt.RightButton) root.openThemeSwitcher()
          else {
            // Hanko: the background picked next is for this screen.
            root.pendingScreen = panel.modelData.name
            pendingScreenTimer.restart()
            root.openSelector()
          }
          mouse.accepted = true
        }
      }
    }
  }
}
