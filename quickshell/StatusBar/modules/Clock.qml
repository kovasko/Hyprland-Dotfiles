import QtQuick
import QtQuick.Layouts
import "../"

Text {
	id: clockText
	text: Qt.formatDateTime(new Date(), "dddd dd MMMM - HH:mm")
	color: Theme.colLavenda
	font.pixelSize: Theme.fontSize
	font.family: Theme.fontFamily
	font.bold: true
	Layout.rightMargin: 8
	
	Timer {
		interval: 1000
		running: true
		repeat: true
		onTriggered: clockText.text = Qt.formatDateTime(new Date(), "dddd dd MMMM - HH:mm")
	}
}
