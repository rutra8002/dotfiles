import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Effects
import "../"

PanelWindow {
    id: root
    
    property var modelData
    property var style: Style {}
    
    screen: modelData

    anchors { top: true; left: true; right: true }
    margins { top: 8; left: 8; right: 8 }
    implicitHeight: 48
    color: "transparent"

    // Blurred background layer
    Rectangle {
        id: blurLayer
        anchors.fill: parent
        color: style.bgTransparent
        radius: style.borderRadius
        
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#40000000"
            shadowBlur: 0.6
            shadowVerticalOffset: 2
            shadowHorizontalOffset: 0
        }
    }

    // Content layer (sharp text and icons)
    Rectangle {
        id: barBackground
        anchors.fill: parent
        anchors.margins: 0
        color: "transparent"
        radius: style.borderRadius

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: parent.radius
            border.color: style.mutedLight
            border.width: 1
            opacity: 0.2
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 16

            Workspaces {
                style: root.style
            }

            Item { Layout.fillWidth: true }

            SystemTray {
                style: root.style
                rootWindow: root
            }

            ScreenshotWidget {
                style: root.style
            }

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
        
        Behavior on opacity {
            NumberAnimation { duration: style.animationDuration }
        }
    }
}
