import Quickshell
import QtQuick
import "Bar"
import "Launcher"

ShellRoot {
    id: root

    Launcher {}

    Variants {
        model: Quickshell.screens

        TopBar { }
    }
}
