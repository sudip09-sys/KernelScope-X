import QtQuick
import QtQuick.Controls

ScrollView {
    id: pane
    clip: true
    contentWidth: availableWidth
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    leftPadding: width < 780 ? 12 : 17
    rightPadding: leftPadding + 8
    topPadding: 15
    bottomPadding: 18
    Accessible.name: "Page content"
}
