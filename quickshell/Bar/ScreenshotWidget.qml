import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight
    
    property var style

    Process {
        id: regionShot
        command: ["bash", "-c", "nohup bash -c 'geom=$(slurp); if [ -n \"$geom\" ]; then mkdir -p ~/Pictures/Screenshots; file=~/Pictures/Screenshots/$(date +%Y-%m-%d-%H%M%S).png; grim -g \"$geom\" \"$file\" && wl-copy < \"$file\"; fi' > /dev/null 2>&1 &"]
        onRunningChanged: if (!running) console.log("Region process launched")
    }

    Process {
        id: fullShot
        command: ["bash", "-c", "nohup bash -c 'mkdir -p ~/Pictures/Screenshots; file=~/Pictures/Screenshots/$(date +%Y-%m-%d-%H%M%S).png; grim \"$file\" && wl-copy < \"$file\"' > /dev/null 2>&1 &"]
        onRunningChanged: if (!running) console.log("Full process launched")
    }




    Text {
        id: icon
        text: "\uf030" // Camera icon
        font.family: root.style.fontFamily
        font.pixelSize: root.style.fontSize
        color: root.style.cyan
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                regionShot.running = true
            } else if (mouse.button === Qt.RightButton) {
                fullShot.running = true
            }
        }
    }
}
