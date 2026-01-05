import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

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
        command: ["bash", "-c", "nohup bash -c 'geom=$(slurp -o); if [ -n \"$geom\" ]; then mkdir -p ~/Pictures/Screenshots; file=~/Pictures/Screenshots/$(date +%Y-%m-%d-%H%M%S).png; grim -g \"$geom\" \"$file\" && wl-copy < \"$file\"; fi' > /dev/null 2>&1 &"]
        onRunningChanged: if (!running) console.log("Full process launched")
    }

    Process {
        id: windowShot
        command: ["bash", "-c", "nohup bash -c 'mkdir -p ~/Pictures/Screenshots; file=~/Pictures/Screenshots/$(date +%Y-%m-%d-%H%M%S).png; geom=$(hyprctl clients -j | python3 -c \"import sys, json; d=json.load(sys.stdin); print(\\\"\\\\n\\\".join([\\\"%s,%s %sx%s\\\"%(i[\\\"at\\\"][0],i[\\\"at\\\"][1],i[\\\"size\\\"][0],i[\\\"size\\\"][1]) for i in d]))\" | slurp); if [ -n \"$geom\" ]; then grim -g \"$geom\" \"$file\" && wl-copy < \"$file\"; fi' > /dev/null 2>&1 &"]
        onRunningChanged: if (!running) console.log("Window process launched")
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
        onClicked: {
            var pos = icon.mapToGlobal(0, icon.height)
            popupContent.x = pos.x - (popupContent.width / 2) + (icon.width / 2)
            popupContent.y = pos.y - (popupContent.height/3/2)
            popupWindow.visible = !popupWindow.visible
        }
    }

    PanelWindow {
        id: popupWindow
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"
        visible: false
        
        WlrLayershell.layer: WlrLayer.Overlay

        MouseArea {
            anchors.fill: parent
            onClicked: popupWindow.visible = false
        }

        Rectangle {
            id: popupContent
            width: 160
            height: column.implicitHeight + 20
            
            color: root.style.bg
            border.color: root.style.muted
            border.width: 1
            radius: 5
            
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }

            ColumnLayout {
                id: column
                anchors.centerIn: parent
                spacing: 2
                
                component ScreenshotButton: Rectangle {
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 30
                    color: area.containsMouse ? root.style.muted : "transparent"
                    radius: 4
                    property string text
                    property string icon
                    signal clicked

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10
                        Text {
                            text: parent.parent.icon
                            font.family: root.style.fontFamily
                            font.pixelSize: root.style.fontSize
                            color: root.style.cyan
                        }
                        Text {
                            text: parent.parent.text
                            font.family: root.style.fontFamily
                            font.pixelSize: root.style.fontSize
                            color: "white"
                            Layout.fillWidth: true
                        }
                    }
                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            parent.clicked()
                            popupWindow.visible = false
                        }
                    }
                }

                ScreenshotButton {
                    text: "Region"
                    icon: "\uf125" // crop
                    onClicked: regionShot.running = true
                }

                ScreenshotButton {
                    text: "Window"
                    icon: "\uf2d0" // window
                    onClicked: windowShot.running = true
                }

                ScreenshotButton {
                    text: "Screen"
                    icon: "\uf108" // desktop
                    onClicked: fullShot.running = true
                }
            }
        }
    }
}
