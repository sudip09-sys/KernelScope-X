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
            subheading: "Search, sort and inspect running Windows processes."
        }

        GridLayout {
            Layout.fillWidth: true
            columns: root.compact ? 1 : 2
            columnSpacing: 14
            rowSpacing: 14

            Rectangle {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: root.compact ? 370 : Math.max(370, root.height - 110)
                color: "#1b211c"
                radius: 10
                border.color: "#313a32"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            Layout.fillWidth: true
                            text: "Running processes"
                            font.pixelSize: 19
                            font.weight: Font.DemiBold
                        }
                        Label {
                            text: list.count + " / " + monitor.processes
                            font.family: "Consolas"
                            color: "#b9c4b9"
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        TextField {
                            id: search
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            Accessible.name: "Search processes"
                            placeholderText: "Name, PID or parent PID"
                            selectByMouse: true
                            onTextChanged: processProxy.search = text
                            Keys.onEscapePressed: clear()
                        }
                        Button {
                            text: "Clear"
                            Layout.preferredHeight: 38
                            enabled: search.length > 0
                            onClicked: {
                                search.clear()
                                search.forceActiveFocus()
                            }
                        }
                        ComboBox {
                            Layout.preferredWidth: 138
                            Layout.preferredHeight: 38
                            Accessible.name: "Process sort order"
                            model: ["CPU: highest", "Memory: highest", "Name: A–Z", "PID: ascending"]
                            onActivated: processProxy.setSortMode(currentIndex)
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        color: "#28332a"
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
                                height: 41
                                Accessible.name: name + ", PID " + pid
                                onClicked: root.selectProcess(pid, identity)
                                background: Rectangle {
                                    radius: 6
                                    color: row.selectedRow ? "#354629" : row.hovered ? "#29352a" : "transparent"
                                    border.color: row.visualFocus ? "#c7f46a" : "transparent"
                                    Rectangle {
                                        width: 3
                                        radius: 1
                                        anchors.left: parent.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        anchors.topMargin: 6
                                        anchors.bottomMargin: 6
                                        color: "#c7f46a"
                                        visible: row.selectedRow
                                    }
                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        width: parent.width
                                        height: 1
                                        color: "#313a32"
                                        visible: !row.selectedRow && !row.visualFocus
                                    }
                                }
                                contentItem: RowLayout {
                                    spacing: 8
                                    Label { text: row.name; textFormat: Text.PlainText; Layout.fillWidth: true; elide: Text.ElideRight; font.weight: row.selectedRow ? Font.DemiBold : Font.Normal }
                                    Label { text: row.pid; font.family: "Consolas"; Layout.preferredWidth: 61; color: "#a3afa3" }
                                    Label { text: row.cpu.toFixed(1) + "%"; font.family: "Consolas"; Layout.preferredWidth: 59; color: "#c7f46a" }
                                    Label {
                                        Layout.preferredWidth: 92
                                        font.family: "Consolas"
                                        text: row.memoryAvailable ? Number(row.memoryMb).toFixed(1) + " MiB" : "—"
                                    }
                                    Label { text: row.threadCount; font.family: "Consolas"; Layout.preferredWidth: 54 }
                                }
                                leftPadding: 12
                                rightPadding: 12
                            }
                        }

                        Label {
                            anchors.centerIn: parent
                            visible: list.count === 0
                            text: search.length ? "No matching processes" : "No process data available"
                            color: "#b9c4b9"
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: root.compact
                Layout.preferredWidth: 307
                Layout.fillHeight: !root.compact
                Layout.alignment: Qt.AlignTop
                implicitHeight: Math.max(178, inspector.implicitHeight + 36)
                color: "#1b211c"
                radius: 10
                border.color: "#313a32"

                ColumnLayout {
                    id: inspector
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 18
                    spacing: 11

                    Label { text: "Process details"; color: "#c7f46a"; font.weight: Font.DemiBold }
                    Label {
                        Layout.fillWidth: true
                        text: root.selected.found ? root.selected.name : "Select a process"
                        textFormat: Text.PlainText
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                        wrapMode: Text.Wrap
                    }
                    Label {
                        visible: !root.selected.found
                        Layout.fillWidth: true
                        text: "Choose a row to see CPU, memory and executable details."
                        color: "#b9c4b9"
                        wrapMode: Text.WordWrap
                    }
                    Rectangle {
                        visible: root.selected.found
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: "#313a32"
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
                            Label { text: modelData[0]; color: "#b9c4b9"; Layout.fillWidth: true }
                            Label { text: modelData[1] }
                        }
                    }
                    Label {
                        visible: root.selected.found
                        text: "Executable path"
                        color: "#b9c4b9"
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
                        color: "#b9c4b9"
                        wrapMode: Text.WordWrap
                    }
                    Label {
                        Layout.fillWidth: true
                        visible: root.actionMessage.length > 0
                        text: root.actionMessage
                        wrapMode: Text.WordWrap
                        color: "#f1bf74"
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
