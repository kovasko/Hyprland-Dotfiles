import QtQuick
import QtQuick.Layouts
import "../"
import "../services"


Text {
	text: WindowService.activeWindow
	color: Theme.colPurple
	font.pixelSize: Theme.fontSize
	font.family: Theme.fontFamily
	font.bold: true
	Layout.fillWidth: true
	Layout.leftMargin: 8
	elide: Text.ElideRight
	maximumLineCount: 1
}
