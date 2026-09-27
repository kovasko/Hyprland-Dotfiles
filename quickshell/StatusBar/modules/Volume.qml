import QtQuick
import QtQuick.Layouts
import "../"
import "../services"

Text {
	text: " " + VolumeService.volumeLevel + "%"
	color: Theme.colCyan
	font.pixelSize: Theme.fontSize
	font.family: Theme.fontFamily
	font.bold: true
	Layout.rightMargin: 8

}
