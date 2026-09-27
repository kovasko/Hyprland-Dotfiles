pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    property string activeWindow: "Desktop"

    property Timer timer: Timer {
        interval: 500 // Un intervalle court pour suivre le changement de fenêtre active
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: windowProc.running = true
    }

    property Process windowProc: Process {
        id: windowProc
        command: ["sh", "-c", "hyprctl activewindow -j | jq -r '.title // empty'"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    activeWindow = data.trim()
                } else {
                    activeWindow = "" // Évite de garder le titre si on est sur un workspace vide
                }
            }
        }
    }
}
