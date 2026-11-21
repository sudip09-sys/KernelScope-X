import QtQuick
import QtQuick.Layouts

ColumnLayout {
    property string heading: "Section"
    property string subheading: ""
    spacing: 3
    Text {
        text: heading; color: "#f4f8ff"
        font.pixelSize: 26; font.weight: Font.Bold
    }
    Text {
        text: subheading; color: "#93a4c3"
        font.pixelSize: 13; wrapMode: Text.WordWrap; Layout.fillWidth: true
    }
}
