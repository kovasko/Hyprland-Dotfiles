pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    // 1. Déclaration des propriétés globales du service
    property int cpuUsage: 0
    property var lastCpuTotal: 0
    property var lastCpuIdle: 0

    // 2. Un Timer pour actualiser le CPU toutes les 2 secondes
    property Timer cpuTimer: Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: cpuProc.running = true
    }

    // 3. Le processus de lecture de /proc/stat
    property Process cpuProc: Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                var parts = data.trim().split(/\s+/);
                var user = parseInt(parts[1]) || 0;
                var nice = parseInt(parts[2]) || 0;
                var system = parseInt(parts[3]) || 0;
                var idle = parseInt(parts[4]) || 0;
                var iowait = parseInt(parts[5]) || 0;
                var irq = parseInt(parts[6]) || 0;
                var softirq = parseInt(parts[7]) || 0;

                var total = user + nice + system + idle + iowait + irq + softirq;
                var idleTime = idle + iowait;

                if (lastCpuTotal > 0) {
                    var totalDiff = total - lastCpuTotal;
                    var idleDiff = idleTime - lastCpuIdle;
                    if (totalDiff > 0) {
                        // On met à jour la propriété globale du Singleton
                        cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff);
                    }
                }
                lastCpuTotal = total;
                lastCpuIdle = idleTime;
            }
        }
    }
}
