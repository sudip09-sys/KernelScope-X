import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

PageScroll {
    id: root
    ColumnLayout {
        width: root.availableWidth
        spacing: 18
        SectionHeader {
            Layout.fillWidth: true
            heading: "Your system at a glance"
            subheading: "Real Windows metrics · Collected locally every 1.5 seconds · CPU percentage is total-machine normalized"
        }
        GridLayout {
            Layout.fillWidth: true
            columns: width < 760 ? 2 : 4
            columnSpacing: 12
            rowSpacing: 12
            MetricCard {
                Layout.fillWidth: true
                caption: "CPU UTILIZATION"
                value: monitor.cpu.toFixed(1) + "%"
                subtitle: "Across all logical processors"
                accent: "#21d9bc"
            }
            MetricCard {
                Layout.fillWidth: true
                caption: "PHYSICAL MEMORY"
                value: monitor.memory.toFixed(1) + "%"
                subtitle: monitor.usedGiB.toFixed(1) + " / " + monitor.totalGiB.toFixed(1) + " GiB"
                accent: "#9585f0"
            }
            MetricCard {
                Layout.fillWidth: true
                caption: "PROCESSES"
                value: monitor.processes.toString()
                subtitle: "Visible in latest snapshot"
                accent: "#e0ac6c"
            }
            MetricCard {
                Layout.fillWidth: true
                caption: "THREADS"
                value: monitor.threads.toString()
                subtitle: "Summed from process snapshot"
                accent: "#68b7f6"
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 280
            radius: 16; color: "#152139"; border.color: "#2a3954"
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 20; spacing: 12
                RowLayout {
                    Text { text: "Live CPU utilization"; color: "#f1f6ff"; font.pixelSize: 17; font.bold: true }
                    Item { Layout.fillWidth: true }
                    Text { text: "Last 60 samples"; color: "#93a4c2"; font.pixelSize: 11 }
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
                        const points = monitor.cpuHistory
                        const pad = 12
                        ctx.lineWidth = 1
                        for (let n = 0; n <= 4; ++n) {
                            const yy = pad + (height - 2*pad) * n / 4
                            ctx.strokeStyle = "#293d55"
                            ctx.beginPath(); ctx.moveTo(0, yy); ctx.lineTo(width, yy); ctx.stroke()
                        }
                        if (points.length < 2) return
                        ctx.beginPath()
                        for (let i = 0; i < points.length; ++i) {
                            const x = pad + (width - 2*pad) * i / Math.max(59, points.length - 1)
                            const y = height - pad - (height - 2*pad) * Math.max(0, Math.min(100, points[i]))/100
                            if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y)
                        }
                        ctx.strokeStyle = "#28d8bd"; ctx.lineWidth = 2.5; ctx.stroke()
                    }
                    Connections { target: monitor; function onStatsChanged() { graph.requestPaint() } }
                }
                RowLayout {
                    Text { text: "0%"; color: "#667b9a"; font.pixelSize: 11 }
                    Item { Layout.fillWidth: true }
                    Text { text: "100% scale · 1.5s samples"; color: "#667b9a"; font.pixelSize: 11 }
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 250
            radius: 16; color: "#152139"; border.color: "#2a3954"
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 20; spacing: 12
                RowLayout {
                    Text { text: "Top processes by CPU"; color: "#f1f6ff"; font.pixelSize: 17; font.bold: true }
                    Item { Layout.fillWidth: true }
                    Text { text: "Live · Working set in MiB"; color: "#8798b7"; font.pixelSize: 11 }
                }
                ListView {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; model: overviewProxy
                    ScrollBar.vertical: ScrollBar {}
                    delegate: Rectangle {
                        width: ListView.view.width; height: 36
                        color: index % 2 === 0 ? "#19273d" : "transparent"
                        radius: 7
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 13; anchors.rightMargin: 13
                            Text { text: model.name; textFormat: Text.PlainText; color: "#dce6f7"; Layout.fillWidth: true; elide: Text.ElideRight; font.pixelSize: 12 }
                            Text { text: "PID " + model.pid; color: "#96a9c7"; Layout.preferredWidth: 100; font.pixelSize: 11 }
                            Text { text: Number(model.cpu).toFixed(1) + "% CPU"; color: "#2ddbbb"; Layout.preferredWidth: 90; font.pixelSize: 11 }
                            Text { text: model.memoryAvailable ? Number(model.memoryMb).toFixed(1) + " MiB" : "N/A"; color: "#a7b5cc"; Layout.preferredWidth: 95; horizontalAlignment: Text.AlignRight; font.pixelSize: 11 }
                        }
                    }
                }
            }
        }
        Text {
            visible: monitor.error.length > 0
            Layout.fillWidth: true; wrapMode: Text.Wrap
            text: monitor.error; color: "#efb36b"; font.pixelSize: 12
        }
    }
}
