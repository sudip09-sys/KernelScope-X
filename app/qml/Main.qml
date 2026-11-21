import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "pages"

ApplicationWindow {
    id: window
    width: 1370
    height: 860
    minimumWidth: 960
    minimumHeight: 620
    visible: true
    title: "KernelScope X — Native System Intelligence"
    color: "#0c1424"
    property int pageIndex: 0

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 235
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
                        width: 38; height: 38; radius: 12
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
                        Text { text: "X  /  SYSTEM INTELLIGENCE"; font.pixelSize: 9; color: "#7f93ae"; font.letterSpacing: 0.7 }
                    }
                }
                Text { text: "WORKSPACE"; color: "#7386a4"; font.pixelSize: 10; font.weight: Font.Bold; Layout.leftMargin: 12 }
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
                Rectangle { Layout.fillWidth: true; height: 1; color: "#2a3850" }
                RowLayout {
                    spacing: 7
                    Rectangle { width: 7; height: 7; radius: 4; color: monitor.paused ? "#e0ae66" : "#21d9bc" }
                    Text { text: monitor.paused ? "COLLECTION PAUSED" : "LIVE WINDOWS TELEMETRY"; color: "#a3b2ce"; font.pixelSize: 10 }
                }
                Text { text: "Local only • Read-only by default"; color: "#6e819f"; font.pixelSize: 10; Layout.bottomMargin: 10 }
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
                    }
                    Text { text: monitor.updated ? "Updated " + monitor.updated : "Starting collector…"; color: "#899db9"; font.pixelSize: 12 }
                    Button {
                        text: monitor.paused ? "Resume" : "Pause"
                        onClicked: monitor.paused = !monitor.paused
                        background: Rectangle { color: "#243149"; border.color: "#364862"; radius: 9 }
                        contentItem: Text { text: parent.text; color: "#e6efff"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                    Button {
                        text: "Refresh"
                        onClicked: { monitor.paused = false; monitor.refresh() }
                        background: Rectangle { color: "#126f69"; radius: 9 }
                        contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
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
