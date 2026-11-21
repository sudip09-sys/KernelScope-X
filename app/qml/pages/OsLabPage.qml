import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root
    property var result: ({})
    property var segmentColors: ["#29d9ba", "#7e87ed", "#e4a66c", "#4faada", "#db80bb", "#8abf7d"]
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 26; spacing: 13
        SectionHeader {
            Layout.fillWidth: true
            heading: "CPU Scheduling Laboratory"
            subheading: "SIMULATED WORKLOADS ONLY · This page never changes the real Windows scheduler."
        }
        RowLayout {
            Layout.fillWidth: true; spacing: 14
            Rectangle {
                Layout.preferredWidth: 310; Layout.preferredHeight: 247
                radius: 13; color: "#152139"; border.color: "#2a3954"
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 14; spacing: 8
                    Text { text: "PROCESS DATA (name, arrival, burst)"; color: "#97abc8"; font.pixelSize: 11; font.bold: true }
                    TextArea {
                        id: input
                        Layout.fillWidth: true; Layout.fillHeight: true
                        text: "P1,0,8\nP2,1,4\nP3,2,9\nP4,3,5"
                        font.family: "Consolas"; font.pixelSize: 12
                        color: "#ebf4ff"; selectByMouse: true
                        background: Rectangle { radius: 8; color: "#0f1a2a"; border.color: "#30465d" }
                        wrapMode: TextEdit.NoWrap
                    }
                }
            }
            ColumnLayout {
                Layout.fillWidth: true; spacing: 12
                RowLayout {
                    Text { text: "Algorithm"; color: "#9cadc9"; font.pixelSize: 12 }
                    ComboBox { id: algorithm; Layout.preferredWidth: 170; model: ["FCFS", "SJF", "RR"] }
                    Text { text: "Quantum"; color: "#9cadc9"; font.pixelSize: 12 }
                    SpinBox { id: quantum; from: 1; to: 1000; value: 3; enabled: algorithm.currentText === "RR" }
                }
                Text { text: "FCFS and SJF are non-preemptive; RR uses time slicing. All calculations include arrival times."; color: "#9fb1ca"; font.pixelSize: 12; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                Button {
                    text: "Run scheduling simulation"
                    onClicked: root.result = scheduler.simulate(input.text, algorithm.currentText, quantum.value)
                }
                Text {
                    visible: root.result.error !== undefined && root.result.error.length > 0
                    text: root.result.error || ""; color: "#ffba7f"; font.pixelSize: 12
                }
                Item { Layout.fillHeight: true }
                Text { text: "Supported: FCFS · Non-preemptive SJF · Round Robin"; color: "#6f91ad"; font.pixelSize: 11 }
            }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 150
            radius: 13; color: "#152139"; border.color: "#2a3954"
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 15; spacing: 10
                Text { text: "GANTT CHART · SIMULATED CPU TIME"; color: "#9badca"; font.pixelSize: 11; font.bold: true }
                Row {
                    id: bars
                    Layout.fillWidth: true
                    Layout.preferredHeight: 53
                    spacing: 0
                    Repeater {
                        model: root.result.segments || []
                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            width: Math.max(2, (Number(modelData.duration) / Math.max(1, root.result.totalTime || 1)) * bars.width)
                            height: 52
                            color: modelData.idle ? "#38465e" : root.segmentColors[index % root.segmentColors.length]
                            border.color: "#152139"; border.width: 1
                            radius: 3
                            Text { anchors.centerIn: parent; text: parent.width > 25 ? parent.modelData.name : ""; color: "#0b1827"; font.bold: true; font.pixelSize: 12 }
                        }
                    }
                }
                Text { text: root.result.totalTime ? "Start: 0     ·     Finish: " + root.result.totalTime + " time units     ·     Total CPU burst: " + root.result.totalBurst : "Run the simulation to generate a Gantt chart."; color: "#a7bcd7"; font.pixelSize: 12 }
            }
        }
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            MetricCard { Layout.fillWidth: true; implicitHeight: 102; caption: "AVG WAITING"; value: root.result.avgWaiting === undefined ? "—" : Number(root.result.avgWaiting).toFixed(2); subtitle: "Time units" }
            MetricCard { Layout.fillWidth: true; implicitHeight: 102; caption: "AVG TURNAROUND"; value: root.result.avgTurnaround === undefined ? "—" : Number(root.result.avgTurnaround).toFixed(2); subtitle: "Time units"; accent: "#9487ef" }
            MetricCard { Layout.fillWidth: true; implicitHeight: 102; caption: "AVG RESPONSE"; value: root.result.avgResponse === undefined ? "—" : Number(root.result.avgResponse).toFixed(2); subtitle: "Time units"; accent: "#e1a866" }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: 13; color: "#152139"; border.color: "#2a3954"
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 15; spacing: 7
                Text { text: "CALCULATED PROCESS METRICS"; color: "#9badca"; font.pixelSize: 11; font.bold: true }
                RowLayout {
                    Layout.fillWidth: true
                    Repeater {
                        model: ["PROCESS", "AT", "BT", "CT", "TAT", "WT", "RT"]
                        delegate: Text { text: modelData; Layout.fillWidth: true; color: "#7991b3"; font.pixelSize: 10; font.bold: true }
                    }
                }
                ListView {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; model: root.result.rows || []
                    delegate: Rectangle {
                        width: ListView.view.width; height: 30; radius: 5
                        color: index % 2 === 0 ? "#1b2a42" : "transparent"
                        RowLayout {
                            anchors.fill: parent
                            Repeater {
                                model: [modelData.name, modelData.arrival, modelData.burst, modelData.completion, modelData.turnaround, modelData.waiting, modelData.response]
                                delegate: Text { text: modelData; Layout.fillWidth: true; color: "#d4e2f7"; font.pixelSize: 11 }
                            }
                        }
                    }
                }
            }
        }
    }
    Component.onCompleted: root.result = scheduler.simulate("P1,0,8\nP2,1,4\nP3,2,9\nP4,3,5", "FCFS", 3)
}
