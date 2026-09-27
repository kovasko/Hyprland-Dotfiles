pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
	property int memUsage: 0

	property Timer timer: Timer {
		interval: 2000
		repeat: true
		running: true
		triggeredOnStart: true
		onTriggered: memProc.running = true
	}

	property Process memProc: Process {
		id: memProc
		command: ["sh", "-c", "free | grep Mem"]
		stdout: SplitParser {
			onRead: data => {
				if (!data) return
					var parts = data.trim().split(/\s+/)
					var total = parseInt(parts[1]) || 1
					var used = parseInt(parts[2]) || 0
					memUsage = Math.round(100 * used / total)
			}
		}
	}
}
