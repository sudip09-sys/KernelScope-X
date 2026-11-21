import QtQuick
import QtQuick.Controls

Button {
    id: control
    property bool active: false
    property string symbol: "•"
    signal activated()
    implicitWidth: 202
    implicitHeight: 47
    leftPadding: 14
    rightPadding: 10
    onClicked: activated()
    background: Rectangle {
        radius: 10
        color: control.active ? "#203e51" : (control.hovered ? "#182a40" : "transparent")
        border.width: control.active ? 1 : 0
        border.color: "#32686f"
    }
    contentItem: Item {
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 13
            Text {
                text: control.symbol; color: control.active ? "#21d9bc" : "#7f93b1"
                font.pixelSize: 21; width: 25
            }
            Text {
                text: control.text
                color: control.active ? "#f5faff" : "#a3b0c9"
                font.pixelSize: 14
                font.weight: control.active ? Font.DemiBold : Font.Normal
            }
        }
    }
}
