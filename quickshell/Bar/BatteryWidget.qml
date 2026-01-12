import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

Rectangle {
    id: root
    
    property var style
    property var device: UPower.displayDevice

    visible: device && device.isPresent
    
    Layout.preferredWidth: contentRow.width + 16
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

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            id: icon
            font.pixelSize: root.style.fontSize
            font.family: root.style.fontFamily
            color: root.style.purple
            
            text: {
                if (!root.device) return ""
                
                if (root.device.state === UPowerDeviceState.Charging) {
                    return "\uF0E7" // Bolt
                }
                
                var p = root.device.percentage
                
                if (p >= 0.9) return "\uF240" // Full
                if (p >= 0.75) return "\uF241" // 3/4
                if (p >= 0.5) return "\uF242" // 1/2
                if (p >= 0.25) return "\uF243" // 1/4
                return "\uF244" // Empty
            }
        }

        Text {
            text: root.device ? Math.round(root.device.percentage * 100) + "%" : ""
            font.pixelSize: root.style.fontSize
            font.family: root.style.fontFamily
            font.bold: true
            color: root.style.purple
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}
