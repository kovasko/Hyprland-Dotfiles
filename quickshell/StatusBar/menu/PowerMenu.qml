import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io 
import "../"

PanelWindow {
    id: powerMenu

    visible: false

    function open() {
        visible = true;
        mainBg.state = "visible";
    }

    function close() {
        confirmView.visible = false;
        mainView.visible = true;
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

    Timer {
        id: closingTimer
        interval: 150 
        onTriggered: powerMenu.visible = false
    }
    
    implicitWidth: 400
    implicitHeight: 150
    color: "transparent"
    focusable: true

    property string pendingAction: ""

    // Composant de processus utilisant l'API réactive stable
    Process {
        id: sysProcess
    }

    function executeAction(action) {
        // On s'assure d'éteindre le processus s'il tournait déjà
        sysProcess.running = false;

        if (action === "shutdown") {
            sysProcess.command = ["systemctl", "poweroff"];
        } else if (action === "reboot") {
            sysProcess.command = ["systemctl", "reboot"];
        } else if (action === "logout") {
            sysProcess.command = ["hyprctl", "dispatch", "exit"];
        } else if (action === "suspend") {
            sysProcess.command = ["systemctl", "suspend"];
            powerMenu.close();
        } else if (action === "lock") {
            sysProcess.command = ["hyprlock"];
            powerMenu.close();
        }

        // Déclenchement officiel sous Quickshell v0.2+
        sysProcess.running = true;
    }

    Rectangle {
        id: mainBg
        anchors.fill: parent
        radius: 12
        color: Theme.colBg
        border.color: Theme.colMuted
        border.width: 1

        state: "hidden"
        opacity: 0

        transform: Scale { 
            id: menuScale
            origin.x: mainBg.width / 2
            origin.y: mainBg.height / 2
            xScale: 0.9
            yScale: 0.9
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
                PropertyChanges { target: menuScale; xScale: 0.9; yScale: 0.9 }
            }
        ]

        transitions: [
            Transition {
                from: "hidden"; to: "visible"
                ParallelAnimation {
                    NumberAnimation { target: mainBg; property: "opacity"; duration: 200; easing.type: Easing.OutCubic }
                    NumberAnimation { target: menuScale; properties: "xScale, yScale"; duration: 200; easing.type: Easing.OutQuad }
                }
            },
            Transition {
                from: "visible"; to: "hidden"
                ParallelAnimation {
                    NumberAnimation { target: mainBg; property: "opacity"; duration: 120; easing.type: Easing.Linear }
                    NumberAnimation { target: menuScale; properties: "xScale, yScale"; duration: 120; easing.type: Easing.Linear }
                }
            }
        ]

        // --- VUE 1 : MENU PRINCIPAL ---
        ColumnLayout {
            id: mainView
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            visible: true

            Text {
                text: "Gestion de la session"
                color: Theme.colFg
                font.pixelSize: 16
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    model: [
                        { icon: "", action: "lock", color: Theme.colBlue },
                        { icon: "󰏥", action: "suspend", color: Theme.colCyan },
                        { icon: "󰗽", action: "logout", color: Theme.colCyan },
                        { icon: "", action: "reboot", color: "#e64553" },
                        { icon: "", action: "shutdown", color: "#e64553" }
                    ]

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        radius: 8
                        color: btnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(1, 1, 1, 0.02)
                        border.color: btnMouse.containsMouse ? modelData.color : Theme.colMuted
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.family: Theme.fontFamily
                            font.pixelSize: 24
                            color: btnMouse.containsMouse ? modelData.color : Theme.colFg
                        }

                        MouseArea {
                            id: btnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (modelData.action === "lock" || modelData.action === "suspend") {
                                    powerMenu.executeAction(modelData.action);
                                } else {
                                    powerMenu.pendingAction = modelData.action;
                                    mainView.visible = false;
                                    confirmView.visible = true;
                                }
                            }
                        }
                    }
                }
            }
        }

        // --- VUE 2 : CONFIRMATION ---
        ColumnLayout {
            id: confirmView
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            visible: false

            Text {
                text: "Êtes-vous sûr de vouloir continuer ?"
                color: Theme.colFg
                font.pixelSize: 15
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    radius: 8
                    color: Qt.rgba(1, 1, 1, 0.03)
                    border.color: Theme.colMuted

                    Text {
                        anchors.centerIn: parent
                        text: " "
                        font.family: Theme.fontFamily
                        color: Theme.colFg
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: powerMenu.close()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    radius: 8
                    color: Theme.colBlue

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: Theme.fontFamily
                        color: Theme.colBg
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            powerMenu.executeAction(powerMenu.pendingAction);
                            powerMenu.close();
                        }
                    }
                }
            }
        }
    }
}
