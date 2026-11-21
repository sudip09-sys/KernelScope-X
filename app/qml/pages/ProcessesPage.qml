import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

PageScroll {
    id: root
    property double selectedPid: -1
    property string selectedIdentity: ""
    property var selected: ({ found: false })
    property string actionMessage: ""
    readonly property bool canEnd: selected.found &&
                                   monitor.canTerminate(selectedPid, selected.name, selectedIdentity)
    readonly property bool compact: availableWidth < 830

    function selectProcess(pid, identity) {
        selectedPid = pid
        selectedIdentity = identity
        selected = processModel.details(pid)
        actionMessage = ""
    }

    Connections {
        target: monitor
        function onStatsChanged() {
            if (root.selectedPid < 0)
                return
            const latest = processModel.details(root.selectedPid)
            if (!latest.found || !root.selectedIdentity || latest.identity !== root.selectedIdentity) {
                root.selectedPid = -1
                root.selectedIdentity = ""
                root.selected = ({ found: false })
                root.actionMessage = "Selection cleared after the process changed or could no longer be verified."
                endDialog.close()
                return
            }
            root.selected = latest
        }
    }

    ColumnLayout {
        width: root.availableWidth
        spacing: 16

        SectionHeader {
            Layout.fillWidth: true
            heading: "Process explorer"
            subheading: "Find a process by name, PID or parent PID and inspect its current resource usage."
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            TextField {
                id: search
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                Accessible.name: "Search processes"
                placeholderText: "Name, PID or parent PID"
                selectByMouse: true
                onTextChanged: processProxy.search = text
                Keys.onEscapePressed: clear()
            }
            Button {
                text: "Clear"
                enabled: search.length > 0
                onClicked: {
                    search.clear()
                    search.forceActiveFocus()
                }
            }
            ComboBox {
                Layout.preferredWidth: 138
                Layout.preferredHeight: 36
                Accessible.name: "Process sort order"
                model: ["CPU: highest", "Memory: highest", "Name: A–Z", "PID: ascending"]
                onActivated: processProxy.setSortMode(currentIndex)
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: root.compact ? 1 : 2
            columnSpacing: 14
            rowSpacing: 14

            Rectangle {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: root.compact ? 332 : Math.max(390, root.height - 155)
                color: "#152139"
                radius: 12
                border.color: "#2a3954"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    Label {
                        Layout.leftMargin: 10
                        text: list.count + " of " + monitor.processes + " processes"
                        color: "#a7bad5"
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        color: "#202e46"
                        radius: 6

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 18
                            spacing: 8

                            Label { text: "Process"; Layout.fillWidth: true; font.bold: true }
                            Label { text: "PID"; Layout.preferredWidth: 61; font.bold: true }
                            Label { text: "CPU"; Layout.preferredWidth: 59; font.bold: true }
                            Label { text: "Working set"; Layout.preferredWidth: 92; font.bold: true }
                            Label { text: "Threads"; Layout.preferredWidth: 54; font.bold: true }
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ListView {
                            id: list
                            anchors.fill: parent
                            model: processProxy
                            clip: true
                            reuseItems: true
                            currentIndex: -1
                            ScrollBar.vertical: ScrollBar {}

                            delegate: ItemDelegate {
                                id: row
                                required property int index
                                required property double pid
                                required property string identity
                                required property string name
                                required property real cpu
                                required property var memoryMb
                                required property bool memoryAvailable
                                required property double threadCount
                                readonly property bool selectedRow: root.selectedPid === pid &&
                                                                    root.selectedIdentity === identity
                                width: list.width - 6
                                height: 39
                                Accessible.name: name + ", PID " + pid
                                onClicked: root.selectProcess(pid, identity)
                                background: Rectangle {
                                    radius: 6
                                    color: row.selectedRow ? "#20454d" : row.hovered ? "#22334e"
                                                           : row.index % 2 ? "#18263c" : "transparent"
                                    border.color: row.visualFocus ? "#62dfce" : "transparent"
                                }
                                contentItem: RowLayout {
                                    spacing: 8
                                    Label { text: row.name; textFormat: Text.PlainText; Layout.fillWidth: true; elide: Text.ElideRight }
                                    Label { text: row.pid; Layout.preferredWidth: 61; color: "#afc0d9" }
                                    Label { text: row.cpu.toFixed(1) + "%"; Layout.preferredWidth: 59; color: "#6fe8d3" }
                                    Label {
                                        Layout.preferredWidth: 92
                                        text: row.memoryAvailable ? Number(row.memoryMb).toFixed(1) + " MiB" : "—"
                                    }
                                    Label { text: row.threadCount; Layout.preferredWidth: 54 }
                                }
                                leftPadding: 12
                                rightPadding: 12
                            }
                        }

                        Label {
                            anchors.centerIn: parent
                            visible: list.count === 0
                            text: search.length ? "No matching processes" : "No process data available"
                            color: "#a7bad5"
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: root.compact
                Layout.preferredWidth: 280
                Layout.alignment: Qt.AlignTop
                implicitHeight: inspector.implicitHeight + 32
                color: "#152139"
                radius: 12
                border.color: "#2a3954"

                ColumnLayout {
                    id: inspector
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 16
                    spacing: 10

                    Label { text: "Process details"; color: "#6fe8d3"; font.bold: true }
                    Label {
                        Layout.fillWidth: true
                        text: root.selected.found ? root.selected.name : "Select a process"
                        textFormat: Text.PlainText
                        font.pixelSize: 18
                        font.bold: true
                        wrapMode: Text.Wrap
                    }
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
                            Label { text: modelData[0]; color: "#a7bad5"; Layout.fillWidth: true }
                            Label { text: modelData[1] }
                        }
                    }
                    Label {
                        visible: root.selected.found
                        text: "Executable path"
                        color: "#a7bad5"
                    }
                    Label {
                        Layout.fillWidth: true
                        visible: root.selected.found
                        text: root.selected.found ? root.selected.path : ""
                        wrapMode: Text.WrapAnywhere
                        textFormat: Text.PlainText
                    }
                    Button {
                        Layout.fillWidth: true
                        visible: root.selected.found
                        enabled: root.canEnd
                        text: "End process…"
                        onClicked: {
                            endDialog.pid = root.selectedPid
                            endDialog.processName = root.selected.name
                            endDialog.identity = root.selectedIdentity
                            endDialog.open()
                        }
                    }
                    Label {
                        visible: root.selected.found && !root.canEnd
                        Layout.fillWidth: true
                        text: "Ending this process is unavailable."
                        color: "#a7bad5"
                        wrapMode: Text.WordWrap
                    }
                    Label {
                        Layout.fillWidth: true
                        visible: root.actionMessage.length > 0
                        text: root.actionMessage
                        wrapMode: Text.WordWrap
                        color: "#edbc89"
                    }
                }
            }
        }
    }

    Dialog {
        id: endDialog
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(430, parent.width - 32)
        title: "End process?"
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        property double pid: -1
        property string processName: ""
        property string identity: ""

        contentItem: Label {
            text: "End " + endDialog.processName + " (PID " + endDialog.pid +
                  ")?\n\nUnsaved work may be lost."
            wrapMode: Text.WordWrap
            textFormat: Text.PlainText
        }
        footer: DialogButtonBox {
            Button {
                id: cancelButton
                text: "Cancel"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
            Button {
                text: "End process"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
            }
        }
        onOpened: cancelButton.forceActiveFocus()
        onAccepted: root.actionMessage = monitor.terminateSelectedProcess(pid, processName, identity)
    }
}
