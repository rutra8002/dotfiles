import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    
    required property var style
    default property alias content: contentItem.data
    
    Layout.preferredHeight: 32
    Layout.alignment: Qt.AlignVCenter
    color: mouseArea.containsMouse ? style.mutedLight : "transparent"
    radius: style.smallRadius
    
    scale: mouseArea.containsMouse ? 1.05 : 1.0
    
    Behavior on color {
        ColorAnimation { duration: style.hoverAnimationDuration }
    }
    
    Behavior on scale {
        NumberAnimation { duration: style.hoverAnimationDuration; easing.type: Easing.OutCubic }
    }

    Item {
        id: contentItem
        anchors.fill: parent
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}
