import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

PageScroll {
    id: root
    property string exportResult: ""
    ColumnLayout {
        width: root.availableWidth; spacing: 16
        SectionHeader {
            Layout.fillWidth: true
            heading: "Diagnostics & event timeline"
            subheading: "Rule-based alerts require three consecutive high-usage samples. Process events are inferred from periodic snapshots; short-lived events can be missed."
        }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 165
            radius: 15; color: "#1b211c"; border.color: "#313a32"
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 18; spacing: 12
                Text { text: "ACTIVE OBSERVATIONS"; color: "#b9c4b9"; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1 }
                Repeater {
                    model: monitor.alerts
                    delegate: RowLayout {
                        Layout.fillWidth: true
                        Rectangle { Layout.preferredWidth: 8; Layout.preferredHeight: 8; radius: 4; color: index === 0 && monitor.alerts[0].startsWith("No sustained") ? "#c7f46a" : "#f1bf74" }
                        Text { text: modelData; Layout.fillWidth: true; color: "#eff3eb"; wrapMode: Text.WordWrap; font.pixelSize: 13 }
                    }
                }
                Item { Layout.fillHeight: true }
                Text { text: "Thresholds: CPU ≥ 85% · Physical memory ≥ 90%"; color: "#a3afa3"; font.pixelSize: 11 }
            }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 290
            radius: 15; color: "#1b211c"; border.color: "#313a32"
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 18; spacing: 12
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "SESSION EVENT HISTORY"; font.pixelSize: 13; font.bold: true; color: "#eff3eb"; Layout.fillWidth: true }
                    Text { text: "In memory · last 60 events"; font.pixelSize: 11; color: "#a3afa3" }
                }
                ListView {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    model: monitor.events; clip: true
                    ScrollBar.vertical: ScrollBar {}
                    delegate: Rectangle {
                        width: ListView.view.width; height: 37; radius: 7
                        color: index % 2 === 0 ? "#222a23" : "transparent"
                        Text { anchors.fill: parent; anchors.leftMargin: 12; verticalAlignment: Text.AlignVCenter; text: modelData; textFormat: Text.PlainText; color: "#d2ddd1"; font.pixelSize: 11; elide: Text.ElideRight }
                    }
                }
                Text { visible: monitor.events.length === 0; text: "Events appear as processes start or exit while monitoring is active."; font.pixelSize: 12; color: "#b9c4b9"; Layout.fillWidth: true; wrapMode: Text.WordWrap }
            }
        }
        RowLayout {
            Layout.fillWidth: true; spacing: 16
            Button {
                text: "Export current snapshot (JSON)"
                onClicked: root.exportResult = monitor.exportSnapshot()
            }
            Text { text: root.exportResult; color: "#d2ddd1"; font.pixelSize: 12; elide: Text.ElideMiddle; Layout.fillWidth: true }
        }
        Text { text: "Privacy: No data is uploaded. Exported files may contain local executable paths and process names."; color: "#a3afa3"; font.pixelSize: 11; wrapMode: Text.WordWrap; Layout.fillWidth: true }
    }
}
