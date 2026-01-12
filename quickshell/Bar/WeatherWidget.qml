import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

RowLayout {
    id: root
    spacing: 8
    
    required property var style
    
    property string temperature: ""
    property string condition: ""
    property string location: "Unknown"
    
    Timer {
        interval: 1800000 // Update every 30 minutes
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: fetchWeather()
    }
    
    Process {
        id: weatherProcess
        running: false
        command: ["curl", "-s", "wttr.in/Gdansk?format=%C+%t"]
        
        stdout: SplitParser {
            onRead: data => {
                let text = data.trim()
                // Find the last occurrence of a temperature pattern like "+2°C" or "-5°C"
                let tempMatch = text.match(/[+-]?\d+°[CF]/)
                if (tempMatch) {
                    root.temperature = tempMatch[0]
                    // Everything before the temperature is the condition
                    root.condition = text.substring(0, tempMatch.index).trim()
                    root.location = "Gdansk"
                }
            }
        }
    }
    
    function fetchWeather() {
        weatherProcess.running = true
    }
    
    // Weather icon (using emoji/text representation)
    Text {
        text: getWeatherIcon(root.condition)
        font.pixelSize: 16
        font.family: root.style.fontFamily
        color: root.style.purple
        visible: root.temperature !== ""
    }
    
    // Temperature display
    Text {
        text: root.temperature
        font.pixelSize: root.style.fontSize
        font.family: root.style.fontFamily
        font.weight: Font.Medium
        color: root.style.purple
        visible: root.temperature !== ""
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            
            ToolTip {
                visible: parent.containsMouse
                text: root.condition + " in " + root.location
                delay: 500
            }
        }
    }
    
    function getWeatherIcon(condition) {
        let c = condition.toLowerCase()
        if (c.includes("clear") || c.includes("sunny")) return "☀️"
        if (c.includes("cloud")) return "☁️"
        if (c.includes("rain") || c.includes("drizzle")) return "🌧️"
        if (c.includes("snow")) return "❄️"
        if (c.includes("thunder") || c.includes("storm")) return "⛈️"
        if (c.includes("fog") || c.includes("mist")) return "🌫️"
        if (c.includes("wind")) return "💨"
        return "🌤️"
    }
}
