import QtQuick
import "../services"
import "../"

Text {
    id: networkModule

    required property var popup

    NetworkService {
        id: network
    }

    // Dès que le composant est chargé, on donne notre service au popup
    Component.onCompleted: {
        if (popup) {
            popup.networkService = network
        }
    }

    text: network.ethernetConnected
    ? "󰈀 "
    : network.wifiConnected
    ? "󰖩 "
    : "󰖪 "

    color: (network.wifiConnected || network.ethernetConnected)
    ? Theme.colBlue
    : Theme.colMuted

    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                // Appel de la méthode toggle() personnalisée pour gérer les animations
                popup.toggle()
            }
        }
    }
}
