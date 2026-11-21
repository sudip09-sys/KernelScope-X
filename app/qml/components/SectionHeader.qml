import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: header
    property string heading: ""
    property string subheading: ""
    spacing: 4

    Text {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        text: header.heading
        color: "#eff3eb"
        font.family: "Segoe UI"
        font.pixelSize: 34
        font.weight: Font.DemiBold
    }
    Text {
        visible: text.length > 0
        text: header.subheading
        color: "#b9c4b9"
        font.pixelSize: 13
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }
}
