#!/bin/bash

# Liste des écrans à tester, dans l'ordre de priorité
PREFERRED_MONITORS=("DP-2" "DP-3" "HDMI-A-1")

# Chemin vers Hyprpanel (modifie si besoin)
HYPRPANEL_CMD="hyprpanel"

# Parcours des écrans préférés
for MON in "${PREFERRED_MONITORS[@]}"; do
    MON_ID=$(hyprctl monitors -j | jq ".[] | select(.name==\"$MON\") | .id")
    if [[ -n "$MON_ID" ]]; then
        echo "📺 Lancement de Hyprpanel sur $MON (ID: $MON_ID)"
        exec $HYPRPANEL_CMD --monitor-id "$MON_ID"
        exit 0
    fi
done

# Si aucun écran n'est trouvé
echo "❌ Aucun des écrans préférés n'est disponible. Hyprpanel non lancé."
exit 1

