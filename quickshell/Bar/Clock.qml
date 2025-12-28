import QtQuick
import QtQuick.Layouts

Text {
    id: root
    property var style

    function updateTime() {
        text = Qt.formatDateTime(new Date(), "HH:mm")
    }

    font.pixelSize: style.fontSize
    font.family: style.fontFamily
    color: style.cyan

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.updateTime()
    }

    Component.onCompleted: root.updateTime()
}
