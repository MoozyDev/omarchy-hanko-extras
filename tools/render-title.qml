// Renders the HANKO title wallpaper (01-hanko) to a PNG, with the same geometry
// as the live drawing in plugins/hanko.desktop (liveBg). Used for the theme
// repos' backgrounds/01-hanko.png (3840x2160) and vertical/ (2160x3840):
//   QT_QPA_PLATFORM=offscreen qml tools/render-title.qml -- <fond> <creme> <w> <h> <logo-noir.svg> <out.png>
// Fonds: vermillon #e8431c, cramoisi #c8102e, vert-billard #0d6b3e; creme #f1e7d6.
import QtQuick
import QtQuick.Window

Window {
  id: win
  readonly property var args: Qt.application.arguments.slice(Qt.application.arguments.indexOf("--") + 1)
  width: Number(args[2]); height: Number(args[3])
  visible: true
  color: args[0]

  Item {
    id: canvas
    anchors.fill: parent
    readonly property real cw: width
    readonly property real ch: height
    readonly property bool vertical: ch > cw

    Rectangle {
      id: liveBg
      anchors.fill: parent
      color: win.args[0]
      readonly property real discD: canvas.vertical ? canvas.cw * 0.70 : canvas.ch * 0.52
      Image {
        id: logo
        width: liveBg.discD
        height: width
        x: (canvas.cw - width) / 2 + width * 0.03
        y: canvas.ch * (canvas.vertical ? 0.42 : 0.50) - height / 2
        source: "file://" + win.args[4]
        sourceSize: Qt.size(Math.ceil(width), Math.ceil(height))
        fillMode: Image.PreserveAspectFit
        smooth: true
        asynchronous: false
      }
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
        visible: !canvas.vertical
        text: "HANKO"
        color: win.args[1]
        font.family: "Anton"
        font.pixelSize: liveBg.titlePx
        renderType: Text.CurveRendering
        x: (canvas.cw - contentWidth) / 2
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
            color: win.args[1]
            font.family: "Anton"
            font.pixelSize: liveBg.titlePx
            renderType: Text.CurveRendering
            lineHeight: 0.82
          }
        }
      }
    }
  }

  Timer {
    interval: 800; running: true
    onTriggered: canvas.grabToImage(function (r) { r.saveToFile(win.args[5]); Qt.quit() })
  }
}
