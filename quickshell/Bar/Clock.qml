import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property QtObject style
    
    width: timeText.width + 24
    height: 32
    color: "transparent"
    radius: style.smallRadius

    function updateTime() {
        timeText.text = Qt.formatDateTime(new Date(), "HH:mm")
    }

    Text {
        id: timeText
        font {
            pixelSize: root.style.fontSize
            family: root.style.fontFamily
            bold: true
        }
        color: "white"
        anchors.centerIn: parent
        
        Behavior on color {
            ColorAnimation { duration: 300 }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.updateTime()
    }

    Component.onCompleted: root.updateTime()
}
