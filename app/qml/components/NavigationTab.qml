import QtQuick
import QtQuick.Controls

Button {
    id: control
    property bool active: false
    implicitHeight: 44
    leftPadding: 13
    rightPadding: 13
    hoverEnabled: true
    font.weight: active ? Font.DemiBold : Font.Normal

    contentItem: Text {
        text: control.text
        font: control.font
        color: control.active ? "#c7f46a" : "#b9c4b9"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        color: control.down ? "#303d29" : control.hovered ? "#253026" : "transparent"
        border.color: control.visualFocus ? "#c7f46a" : "transparent"
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            height: 3
            radius: 1
            color: "#c7f46a"
            visible: control.active
        }
    }
}
