import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

BaseWidget {
    id: root
    
    Layout.preferredWidth: contentRow.width + 16
    
    property string currentLayout: "PL"
    
    Timer {
        id: updateTimer
        interval: 500
        running: true
        repeat: true
        onTriggered: updateLayout()
    }
    
    Process {
        id: fcitxProcess
        command: ["fcitx5-remote", "-n"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                const imName = data.trim();
                // Check if using Japanese input method (Mozc)
                if (imName.includes("mozc")) {
                    root.currentLayout = "JP";
                } else {
                    // Default to Polish for direct input
                    root.currentLayout = "PL";
                }
            }
        }
    }
    
    function updateLayout() {
        fcitxProcess.running = true;
    }
    
    Component.onCompleted: {
        updateLayout();
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: "\uF11C" // Keyboard icon (FontAwesome)
            font.pixelSize: root.style.fontSize
            font.family: root.style.fontFamily
            color: root.currentLayout === "JP" ? root.style.purple : root.style.cyan
        }

        Text {
            text: root.currentLayout
            font.pixelSize: root.style.fontSize
            font.family: root.style.fontFamily
            font.bold: true
            color: root.currentLayout === "JP" ? root.style.purple : root.style.cyan
        }
    }
}
