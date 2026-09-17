#!/usr/bin/bash
set -euo pipefail

# Bakes the Flatpak apps into the image's read-only /usr, so they are already
# present on the live ISO / on first boot / after install -- no runtime
# install service needed. They live in an "image" flatpak installation at
# /usr/share/flatpaks, which is versioned with the image (the documented bootc
# pattern). A plain `flatpak install --system` would land in /var/lib/flatpak,
# and bootc treats /var as machine-local state, so those would be discarded.

mkdir -p /etc/flatpak/installations.d
cat > /etc/flatpak/installations.d/image.conf <<'EOF'
[Installation "image"]
Path=/usr/share/flatpaks
EOF

flatpak remote-add --installation=image --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install --installation=image --noninteractive --assumeyes flathub \
    org.gtk.Gtk3theme.adw-gtk3 \
    org.gtk.Gtk3theme.adw-gtk3-dark \
    org.gnome.Firmware \
    io.missioncenter.MissionCenter \
    org.cockpit_project.CockpitClient \
    org.gnome.Logs \
    org.gnome.Calculator \
    org.gnome.TextEditor \
    org.gnome.font-viewer \
    org.gnome.FileRoller \
    ca.desrt.dconf-editor \
    com.github.tchx84.Flatseal \
    com.mattjakeman.ExtensionManager \
    org.gnome.Weather \
    org.gnome.Papers \
    org.gnome.Loupe \
    org.gnome.baobab \
    com.github.rafostar.Clapper \
    org.gnome.Snapshot \
    org.libreoffice.LibreOffice \
    org.fedoraproject.MediaWriter \
    io.github.flattool.Warehouse \
    io.github.kolunmi.Bazaar \
    org.gnome.SimpleScan \
    org.gustavoperedo.FontDownloader \
    org.gnome.NautilusPreviewer \
    com.github.PintaProject.Pinta \
    org.gnome.clocks \
    org.gnome.Connections \
    org.gnome.DejaDup \
    com.discordapp.Discord \
    com.brave.Browser \
    org.gimp.GIMP \
    org.audacityteam.Audacity \
    org.darktable.Darktable \
    io.dbeaver.DBeaverCommunity \
    com.ranfdev.DistroShelf \
    sh.loft.devpod \
    me.iepure.devtoolbox \
    io.podman_desktop.PodmanDesktop \
    org.wireshark.Wireshark \
    org.filezillaproject.Filezilla \
    org.kde.krita \
    org.inkscape.Inkscape \
    org.pvermeer.WebAppHub

# --- Light weight trimming (keeps every app, drops what's not needed) ---

# 1. Orphaned runtimes/extensions, i.e. ones no installed app references.
flatpak uninstall --installation=image --unused --noninteractive --assumeyes || true

# 2. Locale packs: each runtime ships a per-language .Locale extension that
#    duplicates translations/help for every available language. Removing them
#    saves a few hundred MB with no impact on the apps themselves (they fall
#    back to the base language).
flatpak list --installation=image --columns=ref 2>/dev/null \
    | grep -E '\.Locale$' \
    | xargs -r flatpak uninstall --installation=image --noninteractive --assumeyes || true

# 3. Garbage-collect the internal ostree repo so the objects freed by the
#    uninstalls actually disappear from the layer instead of lingering as
#    unreachable data.
if command -v ostree >/dev/null 2>&1 && [[ -d /usr/share/flatpaks/repo ]]; then
    ostree --repo=/usr/share/flatpaks/repo prune --refs-only || true
fi

# 4. Spent build caches.
rm -rf /var/cache/flatpak /root/.cache/flatpak /tmp/* 2>/dev/null || true