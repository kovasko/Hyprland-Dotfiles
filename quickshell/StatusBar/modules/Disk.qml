import QtQuick
import "../"
import "../services"

	Text {
		text: " " + DiskService.diskUsage + "% "
		color: Theme.colGreen
		font.pixelSize: Theme.fontSize
		font.family: Theme.fontFamily
		font.bold: true
	}
