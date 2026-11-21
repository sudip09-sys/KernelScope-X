pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "pages"

ApplicationWindow {
    id: window
    width: 1320
    height: 820
    minimumWidth: 800
    minimumHeight: 540
    visible: true
    title: "KernelScope X " + Qt.application.version
    color: "#121613"
    font.family: "Segoe UI"
    font.pixelSize: 13

    property int pageIndex: 0
    palette.window: "#1b211c"
    palette.windowText: "#eff3eb"
    palette.base: "#141815"
    palette.alternateBase: "#222a23"
    palette.text: "#eff3eb"
    palette.button: "#252d26"
    palette.buttonText: "#eff3eb"
    palette.placeholderText: "#a3afa3"
    palette.highlight: "#3b5426"
    palette.highlightedText: "#ffffff"
    palette.mid: "#39443a"
    palette.dark: "#141815"
    palette.light: "#566356"
    palette.disabled.text: "#8a988a"
    palette.disabled.buttonText: "#8a988a"

    header: Rectangle {
        implicitHeight: 110
        color: "#1b211c"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 63
                Layout.leftMargin: 28
                Layout.rightMargin: 28
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    radius: 8
                    color: "#c7f46a"
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            const ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            ctx.strokeStyle = "#202b16"
                            ctx.lineWidth = 2
                            ctx.lineCap = "round"
                            ctx.lineJoin = "round"
                            ctx.beginPath()
                            ctx.moveTo(6, 19)
                            ctx.lineTo(12, 19)
                            ctx.lineTo(15, 10)
                            ctx.lineTo(20, 24)
                            ctx.lineTo(23, 16)
                            ctx.lineTo(28, 16)
                            ctx.stroke()
                        }
                    }
                }
                Text {
                    text: "KernelScope X"
                    color: "#eff3eb"
                    font.pixelSize: 21
                    font.weight: Font.DemiBold
                }
                Text {
                    text: "v" + Qt.application.version
                    color: "#a3afa3"
                    font.family: "Consolas"
                    font.pixelSize: 12
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    Layout.preferredWidth: 7
                    Layout.preferredHeight: 7
                    radius: 4
                    color: monitor.paused ? "#f1bf74" : "#c7f46a"
                }
                Text {
                    text: monitor.paused ? "Paused" : monitor.updated ? "Live" : "Starting"
                    color: "#eff3eb"
                    font.weight: Font.DemiBold
                }
                Text {
                    visible: monitor.updated.length > 0
                    text: "Updated " + monitor.updated
                    color: "#a3afa3"
                    font.family: "Consolas"
                    font.pixelSize: 12
                }
                Button {
                    text: monitor.paused ? "Resume" : "Pause"
                    implicitHeight: 33
                    onClicked: monitor.paused = !monitor.paused
                }
                Button {
                    text: "Refresh"
                    implicitHeight: 33
                    highlighted: true
                    onClicked: monitor.refreshOnce()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#313a32"
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 22
                Layout.rightMargin: 22
                spacing: 9

                Repeater {
                    model: ["Overview", "Processes", "Diagnostics", "OS Laboratory"]
                    NavigationTab {
                        required property int index
                        required property string modelData
                        Layout.fillHeight: true
                        text: modelData
                        active: window.pageIndex === index
                        onClicked: window.pageIndex = index
                    }
                }
                Item { Layout.fillWidth: true }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#313a32"
            }
        }
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: window.pageIndex
        OverviewPage { onOpenProcesses: window.pageIndex = 1 }
        ProcessesPage {}
        DiagnosticsPage {}
        OsLabPage {}
    }
}
