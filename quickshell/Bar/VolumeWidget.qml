import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

BaseWidget {
    id: root
    
    Layout.preferredWidth: contentRow.width + 16
    
    property int volumeLevel: 0

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
}
