import QtQuick
import Quickshell.Io
import Quickshell.Networking

Item {
    property string wifiName: "Déconnecté"
    property bool wifiConnected: false
    property bool ethernetConnected: false
    property bool wifiEnabled: false
    property string wifiListRaw: ""

    // Nouvelle propriété pour stocker la liste des profils déjà enregistrés
    property string savedConnectionsRaw: ""

    // 1. Statut actuel
    Process {
        id: networkCheck
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION device"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!this.text) return
                    let wifiFound = false
                    let ethernetFound = false
                    let nameFound = "Déconnecté"
                    let lines = this.text.split("\n")

                    for (let line of lines) {
                        let parts = line.split(":")
                        if (parts.length < 3) continue
                            if (parts[0] === "wifi" && parts[1] === "connected") {
                                wifiFound = true
                                nameFound = parts[2]
                            }
                            if (parts[0] === "ethernet" && parts[1] === "connected") {
                                ethernetFound = true
                            }
                    }
                    wifiConnected = wifiFound
                    ethernetConnected = ethernetFound
                    wifiName = nameFound
            }
        }
    }

    // 2. Statut Radio
    Process {
        id: radioCheck
        command: ["sh", "-c", "nmcli radio wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text) {
                    wifiEnabled = (this.text.trim() === "enabled")
                }
            }
        }
    }

    // 3. Scan Wi-Fi
    Process {
        id: wifiScan
        command: ["sh", "-c", "nmcli -t -f SSID,SIGNAL,SECURITY device wifi list --rescan yes"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text) wifiListRaw = this.text
            }
        }
    }

    // 4. Liste des réseaux déjà enregistrés dans le système
    Process {
        id: savedConnectionsCheck
        command: ["sh", "-c", "nmcli -t -f NAME,TYPE connection show"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text) savedConnectionsRaw = this.text
            }
        }
    }

    // Actions
    function toggleWifi(enable) {
        let state = enable ? "on" : "off"
        actionProcess.exec(["nmcli", "radio", "wifi", state])
        wifiEnabled = enable
        if (!enable) {
            wifiConnected = false
            wifiListRaw = ""
        } else {
            wifiScan.running = true
        }
    }

    function toggleEthernet(enable) {
        let cmd = enable ? "nmcli networking on" : "nmcli networking off"
        actionProcess.exec(["sh", "-c", cmd])
    }

    function connectToWifi(ssid, password) {
        let cmd = password
        ? "nmcli device wifi connect \"" + ssid + "\" password \"" + password + "\""
        : "nmcli device wifi connect \"" + ssid + "\"" // Sans mot de passe si enregistré
        actionProcess.exec(["sh", "-c", cmd])
        networkCheck.running = true
    }

    // Nouvelle fonction de déconnexion
    function disconnectWifi() {
        // Trouve l'interface wifi et la déconnecte
        actionProcess.exec(["sh", "-c", "nmcli device disconnect wlan0 || nmcli device disconnect $(nmcli -t -f DEVICE,TYPE device | grep :wifi | cut -d: -f1)"])
        networkCheck.running = true
    }

    // Vérifie si un SSID fait partie des connexions enregistrées
    function isSaved(ssid) {
        if (!savedConnectionsRaw) return false
            let lines = savedConnectionsRaw.split("\n")
            for (let line of lines) {
                let parts = line.split(":")
                // parts[0] = Nom du profil (SSID), parts[1] = type (802-11-wireless)
                if (parts[0] === ssid && parts[1] === "802-11-wireless") {
                    return true
                }
            }
            return false
    }

    Process {
        id: actionProcess
        function exec(cmdArray) {
            command = cmdArray
            running = true
        }
    }

    Timer {
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            networkCheck.running = true
            radioCheck.running = true
            savedConnectionsCheck.running = true
            if (wifiEnabled) wifiScan.running = true
        }
    }
}
