import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import QtQuick.Effects

Repeater {
    id: root
    model: (Hyprland.workspaces && Hyprland.workspaces.values) 
        ? Array.from(Hyprland.workspaces.values).sort((a, b) => a.id - b.id)
        : []

    property var style

    Rectangle {
        Layout.preferredWidth: 36
        Layout.preferredHeight: 32
        Layout.alignment: Qt.AlignVCenter
        color: parent.isActive ? style.purple : (mouseArea.containsMouse ? style.mutedLight : "transparent")
        radius: style.smallRadius
        
        property int wsId: modelData.id
        property bool isActive: Hyprland.focusedWorkspace?.id === wsId
        property real hoverScale: mouseArea.containsMouse ? 1.05 : 1.0

        scale: hoverScale
        
        Behavior on color {
            ColorAnimation { duration: style.animationDuration }
        }
        
        Behavior on scale {
            NumberAnimation { duration: style.hoverAnimationDuration; easing.type: Easing.OutCubic }
        }

        Text {
            text: parent.wsId
            color: parent.isActive ? "white" : "#a9b1d6"
            font.pixelSize: root.style.fontSize
            font.family: root.style.fontFamily
            font.bold: parent.isActive
            anchors.centerIn: parent
            
            Behavior on color {
                ColorAnimation { duration: style.animationDuration }
            }
        }

        Rectangle {
            width: parent.isActive ? parent.width * 0.6 : 0
            height: 2
            color: style.accent
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            radius: 1
            opacity: parent.isActive ? 1 : 0
            
            Behavior on width {
                NumberAnimation { duration: style.animationDuration; easing.type: Easing.OutCubic }
            }
            
            Behavior on opacity {
                NumberAnimation { duration: style.animationDuration }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: Hyprland.dispatch("workspace " + parent.wsId)
            cursorShape: Qt.PointingHandCursor
        }
    }
}
