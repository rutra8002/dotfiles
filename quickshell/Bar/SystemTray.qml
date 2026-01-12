import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

RowLayout {
    id: root
    spacing: 6
    property var style
    property var rootWindow

    Repeater {
        model: SystemTray.items

        delegate: Rectangle {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            Layout.alignment: Qt.AlignVCenter
            color: mouseArea.containsMouse ? style.mutedLight : "transparent"
            radius: style.smallRadius
            
            scale: mouseArea.containsMouse ? 1.08 : 1.0
            
            Behavior on color {
                ColorAnimation { duration: style.hoverAnimationDuration }
            }
            
            Behavior on scale {
                NumberAnimation { duration: style.hoverAnimationDuration; easing.type: Easing.OutCubic }
            }
            
            IconImage {
                anchors.centerIn: parent
                width: 18
                height: 18
                source: {
                    if (!modelData.icon) return ""
                    const iconStr = modelData.icon.toString()
                    if (iconStr.indexOf(":") !== -1) return iconStr
                    if (iconStr.indexOf("/") === 0) return "file://" + iconStr
                    return "image://icon/" + iconStr
                }
            }

            Menu {
                id: defaultMenu
                MenuItem {
                    text: "Open"
                    onClicked: modelData.activate()
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent 
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        if (modelData.menu) {
                            const window = root.rootWindow || parent.Window.window
                            const pos = parent.mapToItem(window.contentItem, mouse.x, mouse.y)
                            modelData.display(window, pos.x, pos.y)
                        } else {
                            defaultMenu.popup()
                        }
                    } else {
                        if (typeof modelData.activate === 'function') {
                            modelData.activate()
                        }
                    }
                }
            }
        }
    }
}
