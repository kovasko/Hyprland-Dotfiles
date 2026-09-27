import QtQuick
import Quickshell.Bluetooth
import "../"

Text {
    required property var popup

    text:
        Bluetooth.defaultAdapter?.enabled
        ? "󰂯"
        : "󰂲"

    color:
        Bluetooth.defaultAdapter?.enabled
        ? Theme.colBlue
        : Theme.colMuted

    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize

    MouseArea {
        anchors.fill: parent

        acceptedButtons:
            Qt.LeftButton
            | Qt.RightButton
	    
	    onClicked: mouse => {
		    if (mouse.button === Qt.RightButton) {
			    Bluetooth.defaultAdapter.enabled =
			    !Bluetooth.defaultAdapter.enabled
		    }
		    
		    if (mouse.button === Qt.LeftButton) {
			    popup.toggle()
		    }
	    }
    }
}
