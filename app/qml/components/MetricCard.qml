import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card
    property string caption: ""
    property string value: ""
    property string subtitle: ""
    property color accent: "#7abafb"
    property real ratio: -1

    implicitHeight: 99
    radius: 6
    color: "#20242b"
    border.color: "#343c48"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 5

        Text {
            text: card.caption
            color: "#bcc7d5"
            font.pixelSize: 12
            font.weight: Font.DemiBold
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
        Text {
            text: card.value
            color: card.accent
            font.family: "Consolas"
            font.pixelSize: 25
            font.weight: Font.DemiBold
        }
        Text {
            text: card.subtitle
            color: "#a4afbe"
            font.pixelSize: 12
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
        Item { Layout.fillHeight: true }

        Rectangle {
            visible: card.ratio >= 0
            Layout.fillWidth: true
            Layout.preferredHeight: 4
            color: "#323b48"
            radius: 2

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, card.ratio))
                height: parent.height
                radius: 2
                color: card.accent
            }
        }
    }
}
