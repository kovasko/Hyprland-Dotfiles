import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import QtQuick.Controls
import "../"

PanelWindow {
    id: bluetoothMenu

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

    // Aligné sur layersOut (durée: 2 -> ~150ms)
    Timer {
        id: closingTimer
        interval: 150 
        onTriggered: bluetoothMenu.visible = false
    }

    implicitWidth: 360
    implicitHeight: 430
    color: "transparent"

    anchors {
        top: true
        right: true
    }

    margins {
        top: 10     // Repousse le menu sous la barre
        right: 10   // Aligne le menu sur le bord droit de la barre
    }

    Rectangle {
        id: mainBg
        anchors.fill: parent
        radius: 10
        color: Theme.colBg
        border.color: Theme.colMuted

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
                        
                        // Injection correcte du Bézier Hyprland en QML :
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
            anchors.margins: 15
            spacing: 12

            // HEADER
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "󰂯  Bluetooth"
                    color: Theme.colWhite
                    font.family: Theme.fontFamily
                    font.pixelSize: 16
                    font.bold: true
                    Layout.fillWidth: true
                }

                // SWITCH
                Rectangle {
                    width: 45
                    height: 22
                    radius: 11
                    color: Bluetooth.defaultAdapter?.enabled ? Theme.colBlue : Theme.colMuted

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
                        }
                    }

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        anchors.verticalCenter: parent.verticalCenter
                        x: Bluetooth.defaultAdapter?.enabled ? parent.width - width - 2 : 2
                        color: Theme.colWhite
                        
                        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    }
                }

                // SCAN ICON
                Text {
                    text: "󰑐"
                    color: Bluetooth.defaultAdapter?.discovering ? Theme.colCyan : Theme.colFg
                    font.pixelSize: 20

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Bluetooth.defaultAdapter.discovering = !Bluetooth.defaultAdapter.discovering
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.colMuted
            }

            Text {
                text: "Appareils"
                color: Theme.colCyan
                font.bold: true
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Column {
                    width: parent.width

                    Repeater {
                        model: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.devices : []

                        delegate: Rectangle {
                            id: deviceRow
                            width: parent.width
                            height: 55
                            radius: 6
                            color: hover.hovered ? Theme.colMuted : "transparent"
                            property var device: modelData

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10

                                ColumnLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: device.name ? device.name : device.address
                                        color: Theme.colFg
                                        font.bold: true
                                    }

                                    Text {
                                        text: device.connected ? "Connecté" : device.paired ? "Appairé" : "Non appairé"
                                        color: device.connected ? Theme.colCyan : Theme.colFg
                                    }
                                }

                                Text {
                                    text: device.connected ? "●" : ""
                                    color: Theme.colCyan
                                    font.pixelSize: 18
                                }
                            }

                            HoverHandler {
                                id: hover
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (device.connected) {
                                        device.disconnect()
                                    } else if (device.paired) {
                                        device.connect()
                                    } else {
                                        device.pair()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
