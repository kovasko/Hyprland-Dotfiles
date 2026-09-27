pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    property int volumeLevel: 0

    property Timer timer: Timer {
        interval: 1000 // On check le volume toutes les secondes (ou à chaque fois que tu l'affiches)
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: volProc.running = true
    }

    property Process volProc: Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                    var match = data.match(/Volume:\s*([\d.]+)/)
                    if (match) {
                        volumeLevel = Math.round(parseFloat(match[1]) * 100)
                    }
            }
        }
    }
}
