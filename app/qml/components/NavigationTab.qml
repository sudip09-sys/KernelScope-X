import QtQuick
import QtQuick.Controls

Button {
    id: control
    property bool active: false
    implicitHeight: 36
    leftPadding: 13
    rightPadding: 13
    hoverEnabled: true
    font.weight: active ? Font.DemiBold : Font.Normal

    contentItem: Text {
        text: control.text
        font: control.font
        color: control.active ? "#d6eaff" : "#c7d0db"
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: 5
        color: control.active ? "#26384e" : control.down || control.hovered ? "#282e38" : "transparent"
        border.color: control.visualFocus ? "#79b9fa" : "transparent"
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.bottomMargin: 8
            width: 3
            radius: 1
            color: "#79b9fa"
            visible: control.active
        }
    }
}
