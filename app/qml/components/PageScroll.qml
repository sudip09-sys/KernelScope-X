import QtQuick
import QtQuick.Controls

ScrollView {
    id: pane
    clip: true
    contentWidth: availableWidth
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    leftPadding: width < 780 ? 16 : 26
    rightPadding: leftPadding + 8
    topPadding: 22
    bottomPadding: 24
    Accessible.name: "Page content"
}
