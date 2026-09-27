pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
	// 1. C'est CETTE propriété que ton module va lire via DiskService.diskUsage
	property int diskUsage: 0

	// 2. Le Timer qui relance le processus régulièrement
	property Timer timer: Timer {
		interval: 10000 // Inutile de surcharger le disque, toutes les 10 secondes suffit
		repeat: true
		running: true
		triggeredOnStart: true
		onTriggered: diskProc.running = true
	}

	// 3. Le Process de lecture
	property Process diskProc: Process {
		id: diskProc
		command: ["sh", "-c", "df / | tail -1"]
		stdout: SplitParser {
			onRead: data => {
				if (!data) return
					var parts = data.trim().split(/\s+/)
					var percentStr = parts[4] || "0%"

					// On extrait les chiffres et on met à jour la propriété du Singleton
					diskUsage = parseInt(percentStr.replace('%', '')) || 0
			}
		}
	}
}
