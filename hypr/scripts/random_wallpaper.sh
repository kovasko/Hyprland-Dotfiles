#!/bin/bash

# Dossier contenant tes GIFs ou vidéos
WALLPAPER_DIR="$HOME/Pictures/WallpapersGIF/"

# Choisir un fichier aléatoire
FILE=$(find "$WALLPAPER_DIR" -type f \( -iname "*.gif" -o -iname "*.webm" \) | shuf -n 1)

# Appliquer le fond (vidéo ou gif)
swww img "$FILE"

