import QtQuick
import QtQuick.Layouts
import Quickshell
import "../"

PanelWindow {
    id: root
    
    property var modelData
    property var style: Style {}
    
    screen: modelData

    anchors { top: true; left: true; right: true }
    implicitHeight: 30
    color: style.bg

    Rectangle {
        anchors.fill: parent
        color: style.bg
        anchors.margins: 4

        RowLayout {
            anchors.fill: parent
            spacing: 4

            Workspaces {
                style: root.style
            }

            Item { Layout.fillWidth: true }

            VolumeWidget {
                style: root.style
            }

            BatteryWidget {
                style: root.style
            }
        }

        Clock {
            anchors.centerIn: parent
            style: root.style
        }
    }
}
