import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root
    property string exportResult: ""
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 28; spacing: 16
        SectionHeader {
            Layout.fillWidth: true
            heading: "Diagnostics & event timeline"
            subheading: "Rule-based alerts require three consecutive high-usage samples. Process events are inferred from periodic snapshots; short-lived events can be missed."
        }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 165
            radius: 15; color: "#152139"; border.color: "#2a3954"
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 18; spacing: 12
                Text { text: "ACTIVE OBSERVATIONS"; color: "#94a9c5"; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1 }
                Repeater {
                    model: monitor.alerts
                    delegate: RowLayout {
                        Layout.fillWidth: true
                        Rectangle { width: 8; height: 8; radius: 4; color: index === 0 && monitor.alerts[0].startsWith("No sustained") ? "#29d9b7" : "#e7af68" }
                        Text { text: modelData; Layout.fillWidth: true; color: "#ebf3ff"; wrapMode: Text.WordWrap; font.pixelSize: 13 }
                    }
                }
                Item { Layout.fillHeight: true }
                Text { text: "Thresholds: CPU ≥ 85% · Physical memory ≥ 90%"; color: "#7f93b1"; font.pixelSize: 11 }
            }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: 15; color: "#152139"; border.color: "#2a3954"
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 18; spacing: 12
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "SESSION EVENT HISTORY"; font.pixelSize: 13; font.bold: true; color: "#eff5ff"; Layout.fillWidth: true }
                    Text { text: "In memory · last 60 events"; font.pixelSize: 11; color: "#8092b1" }
                }
                ListView {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    model: monitor.events; clip: true
                    ScrollBar.vertical: ScrollBar {}
                    delegate: Rectangle {
                        width: ListView.view.width; height: 37; radius: 7
                        color: index % 2 === 0 ? "#1a2940" : "transparent"
                        Text { anchors.fill: parent; anchors.leftMargin: 12; verticalAlignment: Text.AlignVCenter; text: modelData; color: "#bdcce5"; font.pixelSize: 11; elide: Text.ElideRight }
                    }
                }
                Text { visible: monitor.events.length === 0; text: "Events appear as processes start or exit while monitoring is active."; font.pixelSize: 12; color: "#8fa1bc" }
            }
        }
        RowLayout {
            Layout.fillWidth: true; spacing: 16
            Button {
                text: "Export current snapshot (JSON)"
                onClicked: root.exportResult = monitor.exportSnapshot()
            }
            Text { text: root.exportResult; color: "#9eb4d3"; font.pixelSize: 12; elide: Text.ElideMiddle; Layout.fillWidth: true }
        }
        Text { text: "Privacy: No data is uploaded. Exported files may contain local executable paths and process names."; color: "#7f93b1"; font.pixelSize: 11; wrapMode: Text.WordWrap; Layout.fillWidth: true }
    }
}
