import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Repeater {
    id: root
    model: (Hyprland.workspaces && Hyprland.workspaces.values) 
        ? Array.from(Hyprland.workspaces.values).sort((a, b) => a.id - b.id)
        : []

    property var style

    Rectangle {
        Layout.preferredWidth: 20
        Layout.preferredHeight: parent.height
        color: "transparent"

        property int wsId: modelData.id
        property bool isActive: Hyprland.focusedWorkspace?.id === wsId

        Text {
            text: parent.wsId
            color: root.style.cyan
            font.pixelSize: root.style.fontSize
            font.family: root.style.fontFamily
            font.bold: true
            anchors.centerIn: parent
        }

        Rectangle {
            width: 20
            height: 3
            color: parent.isActive ? root.style.purple : root.style.bg
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
        }

        MouseArea {
            anchors.fill: parent
            onClicked: Hyprland.dispatch("workspace " + parent.wsId)
        }
    }
}
