import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Repeater {
    id: root
    model: 9

    property var style

    Rectangle {
        Layout.preferredWidth: 20
        Layout.preferredHeight: parent.height
        color: "transparent"

        property var workspace: Hyprland.workspaces && Hyprland.workspaces.values
            ? Hyprland.workspaces.values.find(ws => ws.id === index + 1) ?? null
            : null
        property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
        property bool hasWindows: workspace !== null

        Text {
            text: index + 1
            color: parent.isActive
                    ? root.style.cyan
                    : (parent.hasWindows ? root.style.cyan : root.style.muted)
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
            onClicked: Hyprland.dispatch("workspace " + (index + 1))
        }
    }
}
