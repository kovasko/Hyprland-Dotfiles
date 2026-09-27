import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../services"
import ".."

PanelWindow {
    id: networkMenu

    // Visibilité contrôlée par notre API interne
    visible: false
    
    function open() {
        visible = true;
        mainBg.state = "visible";
    }

    function close() {
        mainBg.state = "hidden";
        closingTimer.start(); 
    }

    function toggle() {
        if (visible && mainBg.state === "visible") {
            close();
        } else {
            open();
        }
    }

    // Aligné sur layersOut (durée: 2 -> 150ms)
    Timer {
        id: closingTimer
        interval: 150 
        onTriggered: networkMenu.visible = false
    }

    implicitWidth: 360

    // Ta logique de hauteur dynamique préservée
    implicitHeight: showPasswordPrompt
    ? 220
    : (networkService && networkService.wifiEnabled ? 500 : 220)

    color: "transparent"

    anchors {
        top: true
        right: true
    }
    margins {
        top: 10     // 5px (gap) + 30px (barre) + 5px (espace sous la barre)
        right: 10   // Aligné pile sur le bord droit de la barre
    }
    focusable: true

    property var networkService: null
    property string selectedSSID: ""
    property bool showPasswordPrompt: false
    property bool showPasswordChars: false

    Rectangle {
        id: mainBg
        anchors.fill: parent
        radius: 12
        color: Theme.colBg
        border.color: Theme.colMuted
        border.width: 1

        // États initiaux pour l'animation
        state: "hidden"
        opacity: 0

        transform: Scale { 
            id: menuScale
            origin.x: mainBg.width
            origin.y: 0 
            xScale: 0.85 // popin 85%
            yScale: 0.85
        }

        states: [
            State {
                name: "visible"
                PropertyChanges { target: mainBg; opacity: 1.0 }
                PropertyChanges { target: menuScale; xScale: 1.0; yScale: 1.0 }
            },
            State {
                name: "hidden"
                PropertyChanges { target: mainBg; opacity: 0.0 }
                PropertyChanges { target: menuScale; xScale: 0.85; yScale: 0.85 }
            }
        ]

        transitions: [
            // Entrée : Courbe Hyprland macEaseOut [0.23, 1, 0.32, 1] (durée 3.5 -> ~280ms)
            Transition {
                from: "hidden"; to: "visible"
                ParallelAnimation {
                    NumberAnimation { 
                        target: mainBg
                        property: "opacity"
                        duration: 280 
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation { 
                        target: menuScale
                        properties: "xScale, yScale"
                        duration: 280 
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.23, 1.0, 0.32, 1.0, 1.0, 1.0]
                    }
                }
            },
            // Sortie : Linéaire ultra rapide (durée 2 -> 150ms)
            Transition {
                from: "visible"; to: "hidden"
                ParallelAnimation {
                    NumberAnimation { 
                        target: mainBg
                        property: "opacity"
                        duration: 150
                        easing.type: Easing.Linear
                    }
                    NumberAnimation { 
                        target: menuScale
                        properties: "xScale, yScale"
                        duration: 150
                        easing.type: Easing.Linear
                    }
                }
            }
        ]

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Titre Principal
            Text {
                text: "󰖩   Centre Réseau"
                color: Theme.colWhite
                font.pixelSize: 18
                font.bold: true
            }

            // --- 1. FORMULAIRE DE CONNEXION OPTIMISÉ ---
            ColumnLayout {
                id: passwordForm
                Layout.fillWidth: true
                spacing: 10
                visible: networkMenu.showPasswordPrompt

                Text {
                    text: "Connexion à : " + networkMenu.selectedSSID
                    color: Theme.colCyan
                    font.bold: true
                }

                Text {
                    text: "Mot de passe :"
                    color: Theme.colMuted
                    font.pixelSize: 12
                }

                // Zone de saisie avec bouton Œil
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        height: 32
                        color: Qt.rgba(1, 1, 1, 0.05)
                        border.color: Theme.colMuted
                        border.width: 1
                        radius: 4

                        TextInput {
                            id: passwordInput
                            anchors.fill: parent
                            anchors.margins: 6
                            color: Theme.colFg
                            echoMode: networkMenu.showPasswordChars ? TextInput.Normal : TextInput.Password
                            focus: networkMenu.showPasswordPrompt
                            font.family: Theme.fontFamily
                            verticalAlignment: TextInput.AlignVCenter

                            onAccepted: {
                                if (networkMenu.networkService && passwordInput.text !== "") {
                                    networkMenu.networkService.connectToWifi(networkMenu.selectedSSID, passwordInput.text)
                                    passwordInput.text = ""
                                    networkMenu.showPasswordPrompt = false
                                    networkMenu.showPasswordChars = false
                                }
                            }
                        }
                    }

                    // Bouton Œil
                    Rectangle {
                        width: 32
                        height: 32
                        color: Qt.rgba(1, 1, 1, 0.05)
                        border.color: Theme.colMuted
                        border.width: 1
                        radius: 4

                        Text {
                            anchors.centerIn: parent
                            text: networkMenu.showPasswordChars ? "󰈈" : "󰈉"
                            color: networkMenu.showPasswordChars ? Theme.colBlue : Theme.colMuted
                            font.pixelSize: 14
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: networkMenu.showPasswordChars = !networkMenu.showPasswordChars
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        height: 30
                        radius: 4
                        color: "transparent"
                        border.color: Theme.colMuted
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Annuler"
                            color: Theme.colFg
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                networkMenu.showPasswordPrompt = false
                                networkMenu.showPasswordChars = false
                                passwordInput.text = ""
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 30
                        radius: 4
                        color: Theme.colBlue

                        Text {
                            anchors.centerIn: parent
                            text: "Se connecter"
                            color: Theme.colBg
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (networkMenu.networkService && passwordInput.text !== "") {
                                    networkMenu.networkService.connectToWifi(networkMenu.selectedSSID, passwordInput.text)
                                    passwordInput.text = ""
                                    networkMenu.showPasswordPrompt = false
                                    networkMenu.showPasswordChars = false
                                }
                            }
                        }
                    }
                }
            }

            // --- 2. VUE NORMALE (LISTE DES RÉSEAUX) ---
            ColumnLayout {
                id: mainNetworkView
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12
                visible: !networkMenu.showPasswordPrompt

                // Section Wi-Fi On/Off
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Wi-Fi"
                        color: Theme.colCyan
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 50; height: 24
                        radius: 12
                        color: (networkMenu.networkService && networkMenu.networkService.wifiEnabled) ? Theme.colBlue : Theme.colMuted

                        Text {
                            anchors.centerIn: parent
                            text: (networkMenu.networkService && networkMenu.networkService.wifiEnabled) ? "ON" : "OFF"
                            color: Theme.colBg
                            font.bold: true
                            font.pixelSize: 10
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (networkMenu.networkService) {
                                    networkMenu.networkService.toggleWifi(!networkMenu.networkService.wifiEnabled)
                                }
                            }
                        }
                    }
                }

                // Statut actuel & Déconnexion
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: (networkMenu.networkService && networkMenu.networkService.wifiConnected)
                        ? "Statut : Connecté à " + networkMenu.networkService.wifiName
                        : "Statut : Déconnecté"
                        color: Theme.colWhite
                        font.pixelSize: 12
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "󱘖"
                        font.pixelSize: 16
                        font.family: Theme.fontFamily
                        visible: networkMenu.networkService && networkMenu.networkService.wifiConnected
                        color: disconnectMouseArea.containsMouse ? "#e64553" : Theme.colMuted

                        MouseArea {
                            id: disconnectMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (networkMenu.networkService) {
                                    networkMenu.networkService.disconnectWifi()
                                }
                            }
                        }
                    }
                }
                
                Text {
                    text: "Réseaux à proximité :"
                    color: Theme.colFg
                    font.pixelSize: 11
                    visible: networkMenu.networkService && networkMenu.networkService.wifiEnabled
                }

                Rectangle {
                    id: listContainer
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    clip: true
                    visible: networkMenu.networkService && networkMenu.networkService.wifiEnabled

                    ListView {
                        anchors.fill: parent
                        spacing: 6

                        model: {
                            if (!networkMenu.networkService || !networkMenu.networkService.wifiListRaw) return [];
                            let lines = networkMenu.networkService.wifiListRaw.split("\n");
                            let seenSSIDs = new Set();
                            let filteredLines = [];

                            for (let line of lines) {
                                let parts = line.split(":");
                                if (parts.length < 3 || parts[0].trim() === "") continue;

                                let ssid = parts[0];
                                if (!seenSSIDs.has(ssid)) {
                                    seenSSIDs.add(ssid);
                                    filteredLines.push(line);
                                }
                            }
                            return filteredLines;
                        }

                        delegate: Item {
                            width: listContainer.width
                            height: 30

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                radius: 4

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 6
                                    anchors.rightMargin: 6

                                    Text {
                                        text: modelData.split(":")[0] + ((networkMenu.networkService && networkMenu.networkService.isSaved(modelData.split(":")[0])) ? " 󰚝" : "")
                                        color: Theme.colFg
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: "󰤨  " + modelData.split(":")[1] + "%"
                                        color: Theme.colFg
                                        font.pixelSize: 12
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.color = Qt.rgba(1, 1, 1, 0.05)
                                    onExited: parent.color = "transparent"
                                    onClicked: {
                                        let parts = modelData.split(":")
                                        if (parts.length >= 1 && parts[0] !== "") {
                                            let ssid = parts[0]
                                            let isSaved = networkMenu.networkService.isSaved(ssid)
                                            let isOpen = parts[2] === ""

                                            if (isSaved || isOpen) {
                                                networkMenu.networkService.connectToWifi(ssid, "")
                                            } else {
                                                networkMenu.selectedSSID = ssid
                                                networkMenu.showPasswordPrompt = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.1)
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Ethernet (Filaire)"
                        color: Theme.colCyan
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 50; height: 24
                        radius: 12
                        color: (networkMenu.networkService && networkMenu.networkService.ethernetConnected) ? Theme.colBlue : Theme.colMuted

                        Text {
                            anchors.centerIn: parent
                            text: (networkMenu.networkService && networkMenu.networkService.ethernetConnected) ? "ON" : "OFF"
                            color: Theme.colBg
                            font.bold: true
                            font.pixelSize: 10
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (networkMenu.networkService) {
                                    networkMenu.networkService.toggleEthernet(!networkMenu.networkService.ethernetConnected)
                                }
                            }
                        }
                    }
                }

                Text {
                    text: (networkMenu.networkService && networkMenu.networkService.ethernetConnected) ? "Statut : Câble branché" : "Statut : Déconnecté"
                    color: Theme.colFg
                    font.pixelSize: 12
                }
            }
        }
    } 
}
