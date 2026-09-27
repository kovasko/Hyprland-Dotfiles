import QtQuick
import "../"

Text {
    // Reçoit le PowerMenu depuis shell.qml pour pouvoir l'ouvrir
    required property var popup

    text: ""
    color: Theme.colPurple

    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize

    MouseArea {
        id: powerMouse
        anchors.fill: parent
        hoverEnabled: true

        // Devient rouge au survol, sinon reprend la couleur de base du texte
        onEntered: parent.color = Theme.colRed
        onExited: parent.color = Theme.colPurple

        onClicked: {
            popup.toggle()
        }
    }
}
