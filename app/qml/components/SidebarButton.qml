import QtQuick
import QtQuick.Controls

ItemDelegate {
    id: control
    property string symbol: ""
    property bool active: false
    signal activated()
    implicitHeight: 43
    leftPadding: 12
    rightPadding: 10
    highlighted: active
    onClicked: activated()
    contentItem: Text {
        text: control.symbol + "   " + control.text
        color: control.active ? "#a4f5e8" : "#c1cfe4"
        font: control.font
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    background: Rectangle {
        radius: 8
        color: control.active ? "#193d46" : control.down || control.hovered ? "#20304a" : "transparent"
        border.color: control.visualFocus ? "#59dbca" : control.active ? "#2a6266" : "transparent"
    }
}
