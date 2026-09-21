#!/usr/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Purge every stock / distro background so the only wallpapers available are
# the floatfin collection. gnome-backgrounds itself cannot be removed
# (gnome-shell depends on it), so we remove the files it ships instead and
# wipe the old registrations from the picker.

# KDE / Plasma collections (kde-wallpapers, plasma-workspace-wallpapers).
rm -rf /usr/share/wallpapers

# Everything under /usr/share/backgrounds except our floatfin set: the stock
# GNOME backgrounds, Fedora release wallpapers, and any collection that a
# previous/external build dropped in.
find /usr/share/backgrounds -mindepth 1 -maxdepth 1 ! -name floatfin -exec rm -rf {} +

# Drop the pre-existing wallpaper registrations (gnome-backgrounds-extras,
# Fedora release XMLs, GDM fallbacks, ...).
rm -f /usr/share/gnome-background-properties/*.xml

# Register the floatfin collection with GNOME's wallpaper picker
# (Settings -> Wallpaper).
"$SCRIPT_DIR/generate-gnome-wallpaper-xml.sh" /usr/share/backgrounds/floatfin floatfin "Floatfin"

echo "Purged stock wallpapers; only $(ls /usr/share/backgrounds/floatfin | wc -l) floatfin wallpapers remain."