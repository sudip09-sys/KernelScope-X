import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string caption: "METRIC"
    property string value: "—"
    property string subtitle: ""
    property color accent: "#21d9bc"
    color: "#152139"
    radius: 16
    border.width: 1
    border.color: "#2a3954"
    implicitHeight: 134
    implicitWidth: 200
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 8
        RowLayout {
            Layout.fillWidth: true
            Rectangle { Layout.preferredWidth: 8; Layout.preferredHeight: 8; radius: 4; color: root.accent }
            Text {
                text: root.caption
                color: "#9baac5"; font.pixelSize: 11; font.weight: Font.DemiBold
                font.letterSpacing: 1.1
                Layout.fillWidth: true
            }
        }
        Text {
            text: root.value
            color: "#f4f8ff"; font.pixelSize: 31; font.weight: Font.Bold
            elide: Text.ElideRight; Layout.fillWidth: true
        }
        Text {
            text: root.subtitle
            color: "#8595b4"; font.pixelSize: 12
            elide: Text.ElideRight; Layout.fillWidth: true
        }
    }
}
