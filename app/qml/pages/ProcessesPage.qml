import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root
    property int selectedPid: -1
    property string selectedName: ""
    property var selected: processModel.details(selectedPid)
    property string actionMessage: ""

    Connections {
        target: processModel
        function onModelReset() { root.selected = processModel.details(root.selectedPid) }
    }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 26; spacing: 16
        SectionHeader {
            Layout.fillWidth: true
            heading: "Process Explorer"
            subheading: "Inspect running Windows processes. Restricted fields are shown as unavailable rather than estimated."
        }
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            TextField {
                id: search
                Layout.fillWidth: true
                placeholderText: "Search process name, PID or parent PID…"
                color: "#f3f7ff"
                placeholderTextColor: "#7188a8"
                onTextChanged: processProxy.search = text
                background: Rectangle { color: "#152139"; radius: 10; border.color: search.activeFocus ? "#25cdb1" : "#2c3b55" }
            }
            ComboBox {
                id: sorter
                Layout.preferredWidth: 190
                model: ["CPU: highest", "Memory: highest", "Name: A–Z", "PID: ascending"]
                onActivated: processProxy.setSortMode(currentIndex)
            }
            Text { text: monitor.processes + " visible"; color: "#8297b6"; font.pixelSize: 12 }
        }
        RowLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 14
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: "#152139"; radius: 14; border.color: "#2a3954"
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 10; spacing: 7
                    Rectangle {
                        Layout.fillWidth: true; height: 35
                        color: "#1d2b43"; radius: 7
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 10
                            Text { text: "NAME"; Layout.fillWidth: true; color: "#92a6c5"; font.pixelSize: 10; font.bold: true }
                            Text { text: "PID"; Layout.preferredWidth: 62; color: "#92a6c5"; font.pixelSize: 10; font.bold: true }
                            Text { text: "CPU"; Layout.preferredWidth: 65; color: "#92a6c5"; font.pixelSize: 10; font.bold: true }
                            Text { text: "RAM"; Layout.preferredWidth: 85; color: "#92a6c5"; font.pixelSize: 10; font.bold: true }
                            Text { text: "THREADS"; Layout.preferredWidth: 63; color: "#92a6c5"; font.pixelSize: 10; font.bold: true }
                        }
                    }
                    ListView {
                        id: list
                        Layout.fillWidth: true; Layout.fillHeight: true
                        model: processProxy; clip: true
                        ScrollBar.vertical: ScrollBar {}
                        delegate: Rectangle {
                            width: list.width; height: 39; radius: 7
                            color: root.selectedPid === model.pid ? "#234456" : (mouse.containsMouse ? "#1d3049" : (index % 2 ? "transparent" : "#19263a"))
                            MouseArea {
                                id: mouse
                                anchors.fill: parent; hoverEnabled: true
                                onClicked: {
                                    root.selectedPid = model.pid
                                    root.selectedName = model.name
                                    root.selected = processModel.details(model.pid)
                                    root.actionMessage = ""
                                }
                            }
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 10
                                spacing: 8
                                Text { text: model.name; Layout.fillWidth: true; elide: Text.ElideRight; color: "#eaf1ff"; font.pixelSize: 12 }
                                Text { text: model.pid; Layout.preferredWidth: 62; color: "#a1b1cc"; font.pixelSize: 11 }
                                Text { text: Number(model.cpu).toFixed(1) + "%"; Layout.preferredWidth: 65; color: "#31ddbf"; font.pixelSize: 11 }
                                Text { text: model.memoryAvailable ? Number(model.memoryMb).toFixed(1) + " MiB" : "N/A"; Layout.preferredWidth: 85; color: "#a8b9d4"; font.pixelSize: 11 }
                                Text { text: model.threadCount; Layout.preferredWidth: 63; color: "#a8b9d4"; font.pixelSize: 11 }
                            }
                        }
                    }
                }
            }
            Rectangle {
                Layout.preferredWidth: 270
                Layout.fillHeight: true
                radius: 14; color: "#152139"; border.color: "#2a3954"
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 11
                    Text { text: "PROCESS DNA"; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1.1; color: "#25d8b8" }
                    Text {
                        text: root.selected.found ? root.selected.name : "Choose a process"
                        color: "#f4f8ff"; font.pixelSize: 17; font.bold: true
                        Layout.fillWidth: true; elide: Text.ElideRight
                    }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#31425c" }
                    Repeater {
                        model: root.selected.found ? [
                            ["PID", root.selected.pid],
                            ["Parent PID", root.selected.parentPid],
                            ["CPU", Number(root.selected.cpu).toFixed(1) + "%"],
                            ["Working set", root.selected.memoryAvailable ? Number(root.selected.memoryMb).toFixed(1) + " MiB" : "Unavailable"],
                            ["Threads", root.selected.threads]
                        ] : []
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            Text { text: modelData[0]; color: "#889dbb"; font.pixelSize: 12; Layout.fillWidth: true }
                            Text { text: modelData[1]; color: "#d9e7fc"; font.pixelSize: 12 }
                        }
                    }
                    Text { text: "EXECUTABLE PATH"; visible: root.selected.found; color: "#889dbb"; font.pixelSize: 10; font.bold: true; Layout.topMargin: 12 }
                    Text { text: root.selected.found ? root.selected.path : ""; visible: root.selected.found; color: "#c4d3e8"; font.pixelSize: 11; wrapMode: Text.WrapAnywhere; Layout.fillWidth: true }
                    Item { Layout.fillHeight: true }
                    Text { text: "Ending a process may cause data loss. Confirm before proceeding."; color: "#d2a477"; font.pixelSize: 11; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                    Button {
                        Layout.fillWidth: true
                        enabled: root.selected.found
                        text: "End selected process…"
                        onClicked: endDialog.open()
                    }
                    Text { text: root.actionMessage; visible: root.actionMessage.length > 0; color: "#c2d3ec"; font.pixelSize: 11; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                }
            }
        }
    }
    Dialog {
        id: endDialog
        anchors.centerIn: parent
        title: "End process?"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: 430
        onAccepted: {
            root.actionMessage = monitor.terminateSelectedProcess(root.selectedPid, root.selectedName)
        }
        contentItem: Text {
            text: "Terminate " + root.selectedName + " (PID " + root.selectedPid + ")?\n\nUnsaved work may be lost and the system may become unstable. Protected processes cannot be ended."
            color: "#27364c"; wrapMode: Text.WordWrap; font.pixelSize: 13
        }
    }
}
