import QtQuick
import QtQuick.Layouts
import "../services"
import "../"

RowLayout {
    spacing: 6

    // Détermination de l'icône selon le pourcentage et l'état de charge
    Text {
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        
        color: {
            if (batteryService.isCharging) return Theme.colGreen
            if (batteryService.percentage <= 15) return Theme.colRed
            return Theme.colGreen
        }

        text: {
            if (batteryService.isCharging) {
                return "󰚥"
            }
            
            var pct = batteryService.percentage
            if (pct <= 10) return "󰂎"        // Vide (<10%)
            if (pct <= 35) return "󰁻"        // Presque vide (10% - 35%)
            if (pct <= 65) return "󰁽"        // À moitié rempli (35% - 65%)
            if (pct <= 90) return "󰁿"        // Presque rempli (65% - 90%)
            return "󰁹"                       // Totalement rempli (90%+)
        }
    }

    // Affichage du pourcentage en texte
    Text {
        text: batteryService.percentage + "%"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: Theme.colGreen
    }
}
