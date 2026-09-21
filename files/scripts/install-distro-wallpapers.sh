#!/usr/bin/bash

set -eou pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Register wallpaper collections with GNOME's wallpaper picker.
"$SCRIPT_DIR/generate-gnome-wallpaper-xml.sh" /usr/share/backgrounds/foxstruck foxstruck "Foxstruck"
"$SCRIPT_DIR/generate-gnome-wallpaper-xml.sh" /usr/share/backgrounds/tree-of-life tree-of-life "Tree of Life"
"$SCRIPT_DIR/generate-gnome-wallpaper-xml.sh" /usr/share/backgrounds/floating-continent floating-continent "Floating Continent"
