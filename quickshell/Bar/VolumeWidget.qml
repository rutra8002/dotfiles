import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

Rectangle {
    id: root
    
    property var style
    property int volumeLevel: 0
    
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

    PwObjectTracker { objects: [ Pipewire.defaultAudioSink ] }

    Connections {
        target: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio ? Pipewire.defaultAudioSink.audio : null
        function onVolumeChanged() {
            if (target) {
                root.volumeLevel = Math.round(target.volume * 100)
            }
        }
    }

    Component.onCompleted: {
        if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
            volumeLevel = Math.round(Pipewire.defaultAudioSink.audio.volume * 100)
        }
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.volumeLevel === 0 ? "\uF026" : "\uF028"
            font.pixelSize: root.style.fontSize
            font.family: root.style.fontFamily
            color: root.style.purple
        }

        Text {
            text: root.volumeLevel + "%"
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
