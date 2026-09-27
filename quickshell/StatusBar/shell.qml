import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import "modules"
import "menu"
import "services"

ShellRoot {
    NetworkMenu { id: networkMenu }
    BluetoothMenu { id: bluetoothMenu }
    PowerMenu { id: powerMenu }
    BatteryService { id: batteryService }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
            }

            margins {
                top: 5
                left: 10
                right: 10
            }

            implicitHeight: 30

            // Layout principal invisible qui contient tous nos segments
            RowLayout {
                anchors.fill: parent
                spacing: 10 // Espace entre chaque segment

                // ================= GAUCHE =================

                // Segment 1: Workspaces & Fenêtre active
                Rectangle {
                    color: Theme.colBg
                    radius: 8
                    Layout.fillHeight: true
                    implicitWidth: leftRow.implicitWidth + 20 // 20 = marges internes (padding)

                    RowLayout {
                        id: leftRow
                        anchors.centerIn: parent
                        spacing: 10
                        Workspaces {}
                        ActiveWindow {}
                    }
                }

                // Séparateur invisible pour pousser le reste à droite
                Item {
                    Layout.fillWidth: true
                }

                // ================= DROITE =================

                // Segment 2: Metrics (Cpu, Memory, Disk, Battery)
                Rectangle {
                    color: Theme.colBg
                    radius: 8
                    Layout.fillHeight: true
                    implicitWidth: metricsRow.implicitWidth + 20

                    RowLayout {
                        id: metricsRow
                        anchors.centerIn: parent
                        spacing: 8
                        Cpu {}
                        Memory {}
                        Disk {}
                        Battery {}
                    }
                }

                // Segment 3: Volume
                Rectangle {
                    color: Theme.colBg
                    radius: 8
                    Layout.fillHeight: true
                    implicitWidth: volumeRow.implicitWidth + 20

                    RowLayout {
                        id: volumeRow
                        anchors.centerIn: parent
                        Volume {}
                    }
                }

                // Segment 4: Réseau & Bluetooth
                Rectangle {
                    color: Theme.colBg
                    radius: 8
                    Layout.fillHeight: true
                    implicitWidth: netBtRow.implicitWidth + 20

                    RowLayout {
                        id: netBtRow
                        anchors.centerIn: parent
                        spacing: 8
                        Network { popup: networkMenu }
                        Bluetooth { popup: bluetoothMenu }
                    }
                }

                // Segment 5: Horloge
                Rectangle {
                    color: Theme.colBg
                    radius: 8
                    Layout.fillHeight: true
                    implicitWidth: clockRow.implicitWidth + 20

                    RowLayout {
                        id: clockRow
                        anchors.centerIn: parent
                        Clock {}
                    }
                }

                // Segment 6: Menu Power
                Rectangle {
                    color: Theme.colBg
                    radius: 8
                    Layout.fillHeight: true
                    implicitWidth: powerRow.implicitWidth + 20

                    RowLayout {
                        id: powerRow
                        anchors.centerIn: parent
                        Power { popup: powerMenu }
                    }
                }
            }
        }
    }
}
