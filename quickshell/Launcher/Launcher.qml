import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick.Effects
import "../"

Scope {
    id: root

    property var style: Style {}

    property var allApps: []

    ListModel {
        id: appModel
    }

    function updateApps() {
        appModel.clear()
        var filter = searchInput.text.toLowerCase()
        for (var i = 0; i < allApps.length; i++) {
            if (allApps[i].name.toLowerCase().indexOf(filter) !== -1) {
                appModel.append(allApps[i])
            }
        }
    }

    Process {
        id: appLoader
        command: ["python3", Quickshell.shellDir + "/Launcher/apps.py"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    root.allApps = JSON.parse(data)
                    root.updateApps()
                } catch(e) {
                    console.log("Error parsing apps JSON: " + e)
                }
            }
        }
    }

    Component.onCompleted: {
        appLoader.running = true
    }

    IpcHandler {
        target: "launcher"
        function toggle() {
            window.visible = !window.visible
        }
    }

    PanelWindow {
        id: window
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        visible: false
        
        onVisibleChanged: {
            if (visible) {
                searchInput.forceActiveFocus()
                appLoader.running = true
                launcherContent.opacity = 0
                launcherContent.scale = 0.95
                fadeIn.start()
            } else {
                searchInput.text = ""
            }
        } 
        
        MouseArea {
            anchors.fill: parent
            onClicked: window.visible = false
        }

        Rectangle {
            id: launcherContent
            width: 650
            height: 480
            anchors.centerIn: parent
            color: root.style.bgTransparent
            radius: root.style.borderRadius
            
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#80000000"
                shadowBlur: 1.0
                shadowVerticalOffset: 8
                shadowHorizontalOffset: 0
            }
            
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                radius: parent.radius
                border.color: root.style.mutedLight
                border.width: 1
                opacity: 0.3
            }
            
            ParallelAnimation {
                id: fadeIn
                NumberAnimation {
                    target: launcherContent
                    property: "opacity"
                    to: 1
                    duration: 250
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: launcherContent
                    property: "scale"
                    to: 1
                    duration: 250
                    easing.type: Easing.OutBack
                }
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {} // Prevent clicks from closing
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                Process {
                    id: proc
                }

                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    placeholderText: "Search applications..."
                    font.pixelSize: root.style.fontSize + 4
                    font.family: root.style.fontFamily
                    color: "white"
                    
                    background: Rectangle {
                        color: root.style.mutedLight
                        radius: root.style.smallRadius
                        
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            radius: parent.radius
                            border.color: searchInput.activeFocus ? root.style.accent : "transparent"
                            border.width: 2
                            
                            Behavior on border.color {
                                ColorAnimation { duration: root.style.animationDuration }
                            }
                        }
                    }

                    onTextChanged: root.updateApps()

                    onAccepted: {
                        if (appModel.count > 0) {
                            var app = appModel.get(0)
                            var cmd = app.exec
                            if (app.terminal) {
                                cmd = "kitty -- " + cmd
                            }
                            console.log("Launching: " + cmd)
                            proc.command = ["bash", "-c", "nohup uwsm app -- " + cmd + " > /dev/null 2>&1 &"]
                            proc.running = true
                            window.visible = false
                        } else if (text.trim() !== "") {
                            console.log("Running command: " + text)
                            proc.command = ["bash", "-c", "nohup uwsm app -- " + text + " > /dev/null 2>&1 &"]
                            proc.running = true
                            window.visible = false
                        }
                    }
                }

                ListView {
                    id: appList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: appModel
                    spacing: 4
                    
                    delegate: ItemDelegate {
                        width: ListView.view.width
                        height: 48
                        
                        scale: hovered ? 1.02 : 1.0
                        
                        Behavior on scale {
                            NumberAnimation { duration: root.style.hoverAnimationDuration; easing.type: Easing.OutCubic }
                        }
                        
                        contentItem: RowLayout {
                            spacing: 14
                            
                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                color: root.style.muted
                                radius: root.style.smallRadius
                                
                                IconImage {
                                    anchors.centerIn: parent
                                    width: 28
                                    height: 28
                                    source: {
                                        if (!model.icon) return ""
                                        if (model.icon.indexOf("/") === 0) return "file://" + model.icon
                                        return "image://icon/" + model.icon
                                    }
                                    visible: model.icon !== undefined && model.icon !== null
                                }
                            }

                            Text {
                                text: model.name
                                color: root.style.accent
                                font.pixelSize: root.style.fontSize + 1
                                font.family: root.style.fontFamily
                                verticalAlignment: Text.AlignVCenter
                                Layout.fillWidth: true
                            }
                        }
                        
                        background: Rectangle {
                            color: parent.highlighted ? root.style.mutedLight : "transparent"
                            radius: root.style.smallRadius
                            
                            Behavior on color {
                                ColorAnimation { duration: root.style.hoverAnimationDuration }
                            }
                        }

                        onClicked: {
                            var cmd = model.exec
                            if (model.terminal) {
                                cmd = "kitty -- " + cmd
                            }
                            console.log("Launching: " + cmd)
                            proc.command = ["bash", "-c", "nohup uwsm app -- " + cmd + " > /dev/null 2>&1 &"]
                            proc.running = true
                            window.visible = false
                        }
                    }
                }
            }
        }
    }
}
