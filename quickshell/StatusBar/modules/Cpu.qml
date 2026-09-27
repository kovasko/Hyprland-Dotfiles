import QtQuick
import QtQuick.Layouts
import "../"
import "../services"

Text {
    text: " " + CpuService.cpuUsage + "%"
    color: Theme.colGreen
    font.pixelSize: Theme.fontSize
    font.family: Theme.fontFamily
    font.bold: true
    Layout.rightMargin: 8
}
