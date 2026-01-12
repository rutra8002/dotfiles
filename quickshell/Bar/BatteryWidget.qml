import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

BaseWidget {
    id: root
    
    Layout.preferredWidth: contentRow.width + 16
    
    property var device: UPower.displayDevice

    visible: device && device.isPresent

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
}
