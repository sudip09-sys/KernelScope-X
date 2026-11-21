pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

PageScroll {
    id: root
    signal openProcesses()
    property bool memorySelected: false
    readonly property bool hasMemory: monitor.totalGiB > 0
    readonly property string cpuReading: monitor.updated ? monitor.cpu.toFixed(1) + "%" : "—"
    readonly property string memoryReading: hasMemory ? monitor.memory.toFixed(1) + "%" : "—"
    readonly property string memoryCapacity: hasMemory ?
        monitor.usedGiB.toFixed(1) + " / " + monitor.totalGiB.toFixed(1) + " GiB" : "Unavailable"
    readonly property color cpuColor: "#7abafb"
    readonly property color memoryColor: "#c5a2f5"
    readonly property real cpuScale: {
        const peak = Math.max(0, ...monitor.cpuHistory)
        return peak <= 20 ? 20 : peak <= 40 ? 40 : peak <= 60 ? 60 : 100
    }

    component ResourceButton: ItemDelegate {
        id: resource
        property string reading: ""
        property var samples: []
        property real scaleMaximum: 100
        property color traceColor: "#7abafb"

        implicitHeight: 82
        Accessible.name: text + ", " + reading
        background: Rectangle {
            radius: 6
            color: resource.highlighted ? "#293747" : resource.hovered ? "#282e38" : "#20242b"
            border.color: resource.highlighted || resource.visualFocus ? resource.traceColor : "#343c48"
        }
        contentItem: ColumnLayout {
            spacing: 6
            RowLayout {
                Layout.fillWidth: true
                Label { text: resource.text; Layout.fillWidth: true; font.weight: Font.DemiBold }
                Label { text: resource.reading; color: resource.traceColor; font.family: "Consolas" }
            }
            HistoryPlot {
                Layout.fillWidth: true
                Layout.fillHeight: true
                compact: true
                samples: resource.samples
                lineColor: resource.traceColor
                maximum: resource.scaleMaximum
            }
        }
    }

    ColumnLayout {
        width: root.availableWidth
        spacing: 11

        SectionHeader {
            Layout.fillWidth: true
            heading: "Performance"
            subheading: "Live Windows resource usage"
        }

        GridLayout {
            Layout.fillWidth: true
            columns: width < 720 ? 1 : 2
            columnSpacing: 10
            rowSpacing: 10

            GridLayout {
                Layout.fillWidth: parent.columns === 1
                Layout.preferredWidth: 208
                Layout.alignment: Qt.AlignTop
                columns: parent.columns === 1 ? 2 : 1
                columnSpacing: 8
                rowSpacing: 8

                ResourceButton {
                    Layout.fillWidth: true
                    text: "CPU"
                    reading: root.cpuReading
                    highlighted: !root.memorySelected
                    samples: monitor.cpuHistory
                    traceColor: root.cpuColor
                    scaleMaximum: root.cpuScale
                    onClicked: root.memorySelected = false
                }
                ResourceButton {
                    Layout.fillWidth: true
                    text: "Memory"
                    reading: root.memoryReading
                    highlighted: root.memorySelected
                    samples: monitor.memoryHistory
                    traceColor: root.memoryColor
                    onClicked: root.memorySelected = true
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.columnSpan: parent.columns
                    Layout.preferredHeight: 62
                    radius: 6
                    color: "#20242b"
                    border.color: "#343c48"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Label { text: "Processes"; color: "#a4afbe" }
                            Label { text: monitor.processes; font.family: "Consolas"; font.pixelSize: 18 }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Label { text: "Threads"; color: "#a4afbe" }
                            Label { text: monitor.threads; font.family: "Consolas"; font.pixelSize: 18 }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 321
                radius: 6
                color: "#20242b"
                border.color: "#343c48"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 7

                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Label {
                                text: root.memorySelected ? "Physical memory" : "CPU utilization"
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                            }
                            Label {
                                text: root.memorySelected ? "Physical RAM in use" : "All logical processors"
                                color: "#a4afbe"
                            }
                        }
                        Label {
                            text: root.memorySelected ? root.memoryReading : root.cpuReading
                            color: root.memorySelected ? root.memoryColor : root.cpuColor
                            font.family: "Consolas"
                            font.pixelSize: 27
                        }
                    }
                    HistoryPlot {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.topMargin: 6
                        samples: root.memorySelected ? monitor.memoryHistory : monitor.cpuHistory
                        lineColor: root.memorySelected ? root.memoryColor : root.cpuColor
                        maximum: root.memorySelected ? 100 : root.cpuScale
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 30
                        Label { text: "Last 60 samples"; color: "#a4afbe"; font.pixelSize: 11 }
                        Item { Layout.fillWidth: true }
                        Label { text: "Latest"; color: "#a4afbe"; font.pixelSize: 11 }
                    }
                    Label {
                        visible: root.memorySelected
                        text: root.memoryCapacity
                        color: "#cbd5e1"
                        font.family: "Consolas"
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 265
            radius: 6
            color: "#20242b"
            border.color: "#343c48"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        Layout.fillWidth: true
                        text: "Top processes by CPU"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                    }
                    Button { text: "View processes"; onClicked: root.openProcesses() }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.rightMargin: 12
                    spacing: 10
                    Label { text: "Process"; color: "#a4afbe"; Layout.fillWidth: true }
                    Label { text: "PID"; color: "#a4afbe"; Layout.preferredWidth: 62; horizontalAlignment: Text.AlignRight }
                    Label { text: "CPU"; color: "#a4afbe"; Layout.preferredWidth: 63; horizontalAlignment: Text.AlignRight }
                    Label { text: "Working set"; color: "#a4afbe"; Layout.preferredWidth: 91; horizontalAlignment: Text.AlignRight }
                }
                ListView {
                    id: ranking
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: overviewProxy
                    clip: true
                    reuseItems: true
                    ScrollBar.vertical: ScrollBar {}

                    delegate: Item {
                        id: entry
                        required property int index
                        required property string name
                        required property double pid
                        required property real cpu
                        required property var memoryMb
                        required property bool memoryAvailable
                        width: ranking.width - 12
                        height: 30

                        Rectangle {
                            anchors.fill: parent
                            color: entry.index % 2 ? "transparent" : "#272e38"
                        }
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            spacing: 10
                            Label { text: entry.name; textFormat: Text.PlainText; Layout.fillWidth: true; elide: Text.ElideRight }
                            Label { text: entry.pid; color: "#a4afbe"; font.family: "Consolas"; Layout.preferredWidth: 62; horizontalAlignment: Text.AlignRight }
                            Label { text: entry.cpu.toFixed(1) + "%"; color: root.cpuColor; font.family: "Consolas"; Layout.preferredWidth: 63; horizontalAlignment: Text.AlignRight }
                            Label {
                                text: entry.memoryAvailable ? Number(entry.memoryMb).toFixed(1) + " MiB" : "—"
                                color: "#cbd5e1"
                                font.family: "Consolas"
                                Layout.preferredWidth: 91
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }
        }

        Label {
            visible: monitor.error.length > 0
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: monitor.error
            color: "#eab476"
        }
    }
}
