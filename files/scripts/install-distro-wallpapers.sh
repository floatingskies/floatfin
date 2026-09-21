#!/usr/bin/bash

set -eou pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Register wallpaper collections with GNOME's wallpaper picker.
"$SCRIPT_DIR/generate-gnome-wallpaper-xml.sh" /usr/share/backgrounds/crystalline_gravity crystalline_gravity "Crystalline Gravity"
"$SCRIPT_DIR/generate-gnome-wallpaper-xml.sh" /usr/share/backgrounds/foxstruck foxstruck "Foxstruck"
"$SCRIPT_DIR/generate-gnome-wallpaper-xml.sh" /usr/share/backgrounds/starstruck starstruck "Starstruck"
