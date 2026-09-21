#!/usr/bin/bash
set -euo pipefail

# Sets the default GNOME background (the one seen at first boot / on the live
# ISO) to a wallpaper already installed by the wallpapers feature, by writing
# a gschema override. Users can still change it afterwards from Settings.
# The filename to look up (under /usr/share/backgrounds) comes from the
# UBLUE_WALLPAPER env var set in the recipe.

wallpaper="${UBLUE_WALLPAPER:?UBLUE_WALLPAPER env var is required}"
wall="$(find /usr/share/backgrounds -type f -iname "${wallpaper}" -print -quit 2>/dev/null || true)"
if [[ -z "${wall}" ]]; then
    echo "error: wallpaper '${wallpaper}' not found under /usr/share/backgrounds" >&2
    exit 1
fi

override="/usr/share/glib-2.0/schemas/zz99-ublue-wallpaper.gschema.override"
{
    printf '[org.gnome.desktop.background]\n'
    printf "picture-uri='file://%s'\n" "$wall"
    printf "picture-uri-dark='file://%s'\n" "$wall"
    printf "picture-options='zoom'\n"
} > "$override"

glib-compile-schemas /usr/share/glib-2.0/schemas
echo "Default wallpaper set to ${wall}"