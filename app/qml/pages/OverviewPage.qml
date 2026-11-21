pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

PageScroll {
    id: root
    signal openProcesses()

    ColumnLayout {
        width: root.availableWidth
        spacing: 16

        SectionHeader {
            Layout.fillWidth: true
            heading: "System overview"
            subheading: "Windows performance and active processes"
        }

        GridLayout {
            Layout.fillWidth: true
            columns: width < 690 ? 2 : 4
            columnSpacing: 12
            rowSpacing: 12

            MetricCard {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                caption: "CPU utilization"
                value: monitor.cpu.toFixed(1) + "%"
                subtitle: "All logical processors"
                ratio: monitor.cpu / 100
            }
            MetricCard {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                caption: "Physical memory"
                value: monitor.memory.toFixed(1) + "%"
                subtitle: monitor.usedGiB.toFixed(1) + " / " + monitor.totalGiB.toFixed(1) + " GiB"
                accent: "#91d7ff"
                ratio: monitor.memory / 100
            }
            MetricCard {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                caption: "Processes"
                value: monitor.processes.toString()
                subtitle: "Current snapshot"
                accent: "#eff3eb"
            }
            MetricCard {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                caption: "Threads"
                value: monitor.threads.toString()
                subtitle: "Across all processes"
                accent: "#eff3eb"
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: width < 960 ? 1 : 2
            columnSpacing: 14
            rowSpacing: 14

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: 590
                Layout.preferredHeight: 360
                radius: 10
                color: "#1b211c"
                border.color: "#313a32"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 10

                    Label {
                        text: "CPU history"
                        font.pixelSize: 19
                        font.weight: Font.DemiBold
                    }
                    Label {
                        text: "Last 60 samples · utilization (%)"
                        color: "#a3afa3"
                    }

                    Canvas {
                        id: graph
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                        onPaint: {
                            const ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            const left = 34
                            const right = width - 8
                            const top = 10
                            const bottom = height - 14
                            if (right <= left || bottom <= top)
                                return

                            const points = monitor.cpuHistory
                            const peak = points.length ? Math.max(...points) : 0
                            const ceiling = peak <= 20 ? 20 : peak <= 50 ? 50 : 100
                            const plotHeight = bottom - top
                            const step = (right - left) / 59
                            ctx.lineWidth = 1
                            ctx.font = "11px Consolas"
                            ctx.textAlign = "right"
                            ctx.textBaseline = "middle"
                            for (let n = 0; n <= 4; ++n) {
                                const y = top + plotHeight * n / 4
                                ctx.strokeStyle = "#364137"
                                ctx.beginPath()
                                ctx.moveTo(left, y)
                                ctx.lineTo(right, y)
                                ctx.stroke()
                                ctx.fillStyle = "#a3afa3"
                                ctx.fillText(String(ceiling * (4 - n) / 4), left - 8, y)
                            }

                            if (points.length === 0)
                                return

                            const xAt = i => right - step * (points.length - 1 - i)
                            const yAt = i => bottom - plotHeight * Math.min(ceiling, Math.max(0, points[i])) / ceiling
                            ctx.beginPath()
                            ctx.moveTo(xAt(0), yAt(0))
                            for (let i = 1; i < points.length; ++i)
                                ctx.lineTo(xAt(i), yAt(i))

                            ctx.lineTo(right, bottom)
                            ctx.lineTo(xAt(0), bottom)
                            ctx.closePath()
                            const fill = ctx.createLinearGradient(0, top, 0, bottom)
                            fill.addColorStop(0, "rgba(199, 244, 106, 0.47)")
                            fill.addColorStop(1, "rgba(199, 244, 106, 0.08)")
                            ctx.fillStyle = fill
                            ctx.fill()

                            ctx.beginPath()
                            ctx.moveTo(xAt(0), yAt(0))
                            for (let i = 1; i < points.length; ++i)
                                ctx.lineTo(xAt(i), yAt(i))
                            ctx.strokeStyle = "#c7f46a"
                            ctx.lineWidth = 2
                            ctx.stroke()
                            ctx.beginPath()
                            ctx.arc(right, yAt(points.length - 1), 3, 0, 2 * Math.PI)
                            ctx.fillStyle = "#c7f46a"
                            ctx.fill()
                        }
                        Connections {
                            target: monitor
                            function onStatsChanged() { graph.requestPaint() }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 34
                        Layout.rightMargin: 8
                        Label { text: "Older"; color: "#a3afa3"; font.pixelSize: 11 }
                        Item { Layout.fillWidth: true }
                        Label { text: "Latest"; color: "#a3afa3"; font.pixelSize: 11 }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: 390
                Layout.preferredHeight: 360
                radius: 10
                color: "#1b211c"
                border.color: "#313a32"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            Layout.fillWidth: true
                            text: "Top processes"
                            font.pixelSize: 19
                            font.weight: Font.DemiBold
                        }
                        Button { text: "View all"; onClicked: root.openProcesses() }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.rightMargin: 12
                        spacing: 10
                        Label { text: "Process"; color: "#a3afa3"; Layout.fillWidth: true }
                        Label { text: "PID"; color: "#a3afa3"; Layout.preferredWidth: 54; horizontalAlignment: Text.AlignRight }
                        Label { text: "CPU"; color: "#a3afa3"; Layout.preferredWidth: 53; horizontalAlignment: Text.AlignRight }
                        Label { text: "Memory"; color: "#a3afa3"; Layout.preferredWidth: 82; horizontalAlignment: Text.AlignRight }
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
                            required property string name
                            required property double pid
                            required property real cpu
                            required property var memoryMb
                            required property bool memoryAvailable
                            width: ranking.width - 12
                            height: 38

                            Rectangle {
                                anchors.top: parent.top
                                width: parent.width
                                height: 1
                                color: "#313a32"
                            }
                            RowLayout {
                                anchors.fill: parent
                                spacing: 10
                                Label { text: entry.name; textFormat: Text.PlainText; Layout.fillWidth: true; elide: Text.ElideRight }
                                Label { text: entry.pid; color: "#a3afa3"; font.family: "Consolas"; Layout.preferredWidth: 54; horizontalAlignment: Text.AlignRight }
                                Label { text: entry.cpu.toFixed(1) + "%"; color: "#c7f46a"; font.family: "Consolas"; Layout.preferredWidth: 53; horizontalAlignment: Text.AlignRight }
                                Label {
                                    text: entry.memoryAvailable ? Number(entry.memoryMb).toFixed(1) + " MiB" : "—"
                                    color: "#d2ddd1"
                                    font.family: "Consolas"
                                    Layout.preferredWidth: 82
                                    horizontalAlignment: Text.AlignRight
                                }
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
            color: "#f1bf74"
        }
    }
}
