import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card
    property string caption: ""
    property string value: ""
    property string subtitle: ""
    property color accent: "#c7f46a"
    property real ratio: -1

    implicitHeight: 126
    radius: 10
    color: "#1b211c"
    border.color: "#313a32"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 5

        Text {
            text: card.caption
            color: "#b9c4b9"
            font.pixelSize: 12
            font.weight: Font.DemiBold
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
        Text {
            text: card.value
            color: card.accent
            font.family: "Consolas"
            font.pixelSize: 30
            font.weight: Font.DemiBold
        }
        Text {
            text: card.subtitle
            color: "#a3afa3"
            font.pixelSize: 12
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
        Item { Layout.fillHeight: true }

        Rectangle {
            visible: card.ratio >= 0
            Layout.fillWidth: true
            Layout.preferredHeight: 4
            color: "#303b30"
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
