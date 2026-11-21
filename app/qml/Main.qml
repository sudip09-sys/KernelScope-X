import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "pages"

ApplicationWindow {
    id: window
    width: 1370
    height: 860
    minimumWidth: 800
    minimumHeight: 540
    visible: true
    title: "KernelScope X — Native System Intelligence"
    color: "#0c1424"
    readonly property bool compact: width < 1050
    property int pageIndex: 0
    font.family: "Segoe UI"
    font.pixelSize: 13
    palette.window: "#121d2d"
    palette.windowText: "#eaf1fc"
    palette.base: "#101a2a"
    palette.alternateBase: "#19273d"
    palette.text: "#eaf1fc"
    palette.button: "#23324a"
    palette.buttonText: "#eaf1fc"
    palette.placeholderText: "#94a8c5"
    palette.highlight: "#287d78"
    palette.highlightedText: "#ffffff"
    palette.mid: "#344760"
    palette.dark: "#101a2a"
    palette.light: "#3e5472"
    palette.disabled.text: "#8492a8"
    palette.disabled.buttonText: "#8492a8"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: window.compact ? 176 : 222
            Layout.fillHeight: true
            color: "#101a2b"
            border.color: "#23324b"
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 17
                spacing: 10
                RowLayout {
                    Layout.topMargin: 14
                    Layout.bottomMargin: 26
                    spacing: 11
                    Rectangle {
                        Layout.preferredWidth: 38; Layout.preferredHeight: 38; radius: 12
                        color: "#173c41"
                        Text {
                            anchors.centerIn: parent
                            text: "◈"
                            color: "#35e3c1"
                            font.pixelSize: 27
                        }
                    }
                    Column {
                        spacing: 1
                        Text { text: "KERNELSCOPE"; font.bold: true; font.pixelSize: 16; color: "#f4f8ff" }
                        Text { text: "X  /  v0.2.0"; font.pixelSize: 11; color: "#9aacca" }
                    }
                }
                Repeater {
                    model: [
                        { title: "Overview", glyph: "◉" },
                        { title: "Processes", glyph: "▤" },
                        { title: "Diagnostics", glyph: "⌁" },
                        { title: "OS Laboratory", glyph: "⌘" }
                    ]
                    SidebarButton {
                        Layout.fillWidth: true
                        text: modelData.title
                        symbol: modelData.glyph
                        active: window.pageIndex === index
                        onActivated: window.pageIndex = index
                    }
                }
                Item { Layout.fillHeight: true }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#2a3850" }
                RowLayout {
                    spacing: 7
                    Rectangle { Layout.preferredWidth: 7; Layout.preferredHeight: 7; radius: 4; color: monitor.paused ? "#e0ae66" : "#21d9bc" }
                    Text { text: monitor.paused ? "Collection paused" : "Live telemetry"; color: "#a3b2ce"; font.pixelSize: 10 }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 68
                color: "#111d30"
                border.color: "#27364d"
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 28
                    anchors.rightMargin: 26
                    spacing: 12
                    Text {
                        text: ["System overview", "Process explorer", "Diagnostics & events", "Operating Systems laboratory"][window.pageIndex]
                        color: "#dce8f6"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    Text { text: monitor.updated ? "Updated " + monitor.updated : "Starting collector…"; color: "#899db9"; font.pixelSize: 12 }
                    Button {
                        text: monitor.paused ? "Resume" : "Pause"
                        onClicked: monitor.paused = !monitor.paused
                    }
                    Button {
                        text: "Refresh"
                        highlighted: true
                        onClicked: monitor.refreshOnce()
                    }
                }
            }
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: window.pageIndex
                OverviewPage {}
                ProcessesPage {}
                DiagnosticsPage {}
                OsLabPage {}
            }
        }
    }
}
