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
    color: "#15181d"
    font.family: "Segoe UI"
    font.pixelSize: 13

    property int pageIndex: 0
    readonly property bool narrow: width < 900
    palette.window: "#20242b"
    palette.windowText: "#eef1f5"
    palette.base: "#171a20"
    palette.alternateBase: "#232831"
    palette.text: "#eef1f5"
    palette.button: "#282e38"
    palette.buttonText: "#eef1f5"
    palette.placeholderText: "#a4afbe"
    palette.highlight: "#234d75"
    palette.highlightedText: "#ffffff"
    palette.mid: "#363e4b"
    palette.dark: "#171a20"
    palette.light: "#4e596b"
    palette.disabled.text: "#929daa"
    palette.disabled.buttonText: "#929daa"

    header: Rectangle {
        implicitHeight: 52
        color: "#20242b"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 11

            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 6
                color: "#265078"
                Label {
                    anchors.centerIn: parent
                    text: "KX"
                    color: "#d6eaff"
                    font.weight: Font.Bold
                    font.pixelSize: 12
                }
            }
            Label {
                text: "KernelScope X"
                font.pixelSize: 16
                font.weight: Font.DemiBold
            }
            Label {
                text: "v" + Qt.application.version
                color: "#a4afbe"
                font.family: "Consolas"
                font.pixelSize: 11
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                Layout.preferredWidth: 7
                Layout.preferredHeight: 7
                radius: 4
                color: monitor.paused ? "#eab476" : "#79d5b1"
            }
            Label { text: monitor.paused ? "Paused" : monitor.updated ? "Live" : "Starting" }
            Label {
                visible: monitor.updated.length > 0
                text: "Updated " + monitor.updated
                color: "#a4afbe"
                font.family: "Consolas"
                font.pixelSize: 12
            }
            Button {
                text: monitor.paused ? "Resume" : "Pause"
                Layout.preferredHeight: 30
                onClicked: monitor.paused = !monitor.paused
            }
            Button {
                text: "Refresh"
                Layout.preferredHeight: 30
                highlighted: true
                onClicked: monitor.refreshOnce()
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: "#333a46"
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: window.narrow ? 130 : 158
            Layout.fillHeight: true
            color: "#1b1f26"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                Repeater {
                    model: ["Performance", "Processes", "Diagnostics", "OS Laboratory"]
                    NavigationTab {
                        required property int index
                        required property string modelData
                        Layout.fillWidth: true
                        text: modelData
                        active: window.pageIndex === index
                        onClicked: window.pageIndex = index
                    }
                }
                Item { Layout.fillHeight: true }
            }

            Rectangle {
                anchors.right: parent.right
                height: parent.height
                width: 1
                color: "#333a46"
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: window.pageIndex
            OverviewPage { onOpenProcesses: window.pageIndex = 1 }
            ProcessesPage {}
            DiagnosticsPage {}
            OsLabPage {}
        }
    }
}
