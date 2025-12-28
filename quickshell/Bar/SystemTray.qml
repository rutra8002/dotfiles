import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

RowLayout {
    id: root
    spacing: 4
    property var style
    property var rootWindow

    Repeater {
        model: SystemTray.items

        delegate: Item {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignVCenter
            
            IconImage {
                anchors.centerIn: parent
                width: 20
                height: 20
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
                anchors.fill: parent 
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
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
