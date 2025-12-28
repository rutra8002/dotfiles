import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
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

        // Hide initially if you want, or manage visibility via a property
        visible: false
        
        onVisibleChanged: {
            if (visible) {
                searchInput.forceActiveFocus()
            } else {
                searchInput.text = ""
            }
        } 

        Rectangle {
            width: 600
            height: 400
            anchors.centerIn: parent
            color: root.style.bg
            border.color: root.style.purple
            border.width: 2
            radius: 10

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10

                Process {
                    id: proc
                }

                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    placeholderText: "Search applications..."
                    font.pixelSize: root.style.fontSize + 4
                    font.family: root.style.fontFamily
                    color: root.style.purple
                    
                    background: Rectangle {
                        color: root.style.muted
                        radius: 5
                    }

                    onTextChanged: root.updateApps()

                    onAccepted: {
                        // If there is a match in the list, launch the first one
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
                            // Fallback to running as command
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
                    
                    delegate: ItemDelegate {
                        width: ListView.view.width
                        height: 40
                        
                        contentItem: RowLayout {
                            spacing: 10
                            
                            IconImage {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                source: {
                                    if (!model.icon) return ""
                                    if (model.icon.indexOf("/") === 0) return "file://" + model.icon
                                    return "image://icon/" + model.icon
                                }
                                visible: model.icon !== undefined && model.icon !== null
                            }

                            Text {
                                text: model.name
                                color: root.style.cyan
                                font.pixelSize: root.style.fontSize
                                font.family: root.style.fontFamily
                                verticalAlignment: Text.AlignVCenter
                                Layout.fillWidth: true
                            }
                        }
                        
                        background: Rectangle {
                            color: parent.highlighted ? root.style.muted : "transparent"
                            radius: 5
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
