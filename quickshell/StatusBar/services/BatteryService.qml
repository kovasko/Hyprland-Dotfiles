import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: batteryService

    property int percentage: 0
    property bool isCharging: false

    // Processus pour lire le pourcentage actuel
    property var readPercentage: Process {
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                batteryService.percentage = parseInt(line.trim()) || 0
            }
        }
    }

    // Processus pour lire l'état (Charging / Discharging)
    property var readStatus: Process {
        command: ["cat", "/sys/class/power_supply/BAT0/status"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                batteryService.isCharging = (line.trim() === "Charging")
            }
        }
    }

    // Boucle de rafraîchissement (toutes les 10 secondes)
    property var timer: Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            readPercentage.running = false
            readPercentage.running = true
            readStatus.running = false
            readStatus.running = true
        }
    }
}
