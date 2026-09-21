#!/usr/bin/bash
# Floatfin GNOME optimization: free up RAM (target ~900 MB - 1 GB idle GNOME)
# and make the desktop feel snappy.
#
#  1. Removes RPM-installed GNOME apps that sit unused on a Bluefin/Bazzite DX
#     desktop (GNOME games, the welcome tour, help docs, the old App Center).
#     Every package is checked against the rpmdb first, so this is a safe
#     no-op on images that don't ship them.
#  2. Disables systemd services/timers that burn RAM or CPU in the background
#     for hardware/features we don't use (Bluetooth, ModemManager, ABRT,
#     printer browsing, tuned, reporting daemons, auto-update timers).
#  3. Masks PackageKit and the user-level Tracker indexers so nothing spins up
#     background package transactions or mines the filesystem on its own.
#
# Fast rollback for purists: enable the units again with `systemctl enable`.

set -euo pipefail

# --- 1. Bloatware / unneeded GNOME apps ------------------------------------
bloat_packages=(
    five-or-more
    four-in-a-row
    gnome-2048
    gnome-chess
    gnome-hitori
    gnome-klotski
    gnome-lightsoff
    gnome-mahjongg
    gnome-mines
    gnome-nibbles
    gnome-robots
    gnome-sudoku
    gnome-taquin
    gnome-tetravex
    gnome-tour
    gnome-user-docs
    hitori
    iagno
    quadrapassel
    swell-foop
    tali
    gnome-software
)

for pkg in "${bloat_packages[@]}"; do
    if rpm -q "$pkg" >/dev/null 2>&1; then
        echo "Removing bloatware: $pkg"
        rpm -e "$pkg" 2>/dev/null || true
    fi
done

# --- 2. Disable background services & timers -------------------------------
disable_units=(
    abrtd.service
    abrt-journal-core.service
    abrt-oops.service
    abrt-vmcore.service
    abrt-xorg.service
    avahi-daemon.service
    avahi-daemon.socket
    bluetooth.service
    cups-browsed.service
    dnf-makecache.timer
    flatpak-system-update.timer
    ModemManager.service
    NetworkManager-wait-online.service
    rhsmcertd.service
    rpm-ostreed-automatic.timer
    switcheroo-control.service
    tailscaled.service
    tuned.service
    ublue-flatpak-manager.service
    uupd.timer
)

for unit in "${disable_units[@]}"; do
    if systemctl list-unit-files "$unit" >/dev/null 2>&1; then
        echo "Disabling service: $unit"
        systemctl disable "$unit" 2>/dev/null || true
    fi
done

# --- 3. Mask services that must never start, even on demand ----------------
mask_units=(
    packagekit.service
    packagekit-offline-update.service
)

for unit in "${mask_units[@]}"; do
    if systemctl list-unit-files "$unit" >/dev/null 2>&1; then
        echo "Masking service: $unit"
        systemctl mask "$unit" 2>/dev/null || true
    fi
done

# --- 4. User-level indexers (Tracker) ---------------------------------------
# Masked for every user so the file indexer never wakes up.
user_units=(
    tracker-extract-3.service
    tracker-miner-apps-3.service
    tracker-miner-fs-3.service
    tracker-miner-rss-3.service
    tracker-writeback-3.service
)

for unit in "${user_units[@]}"; do
    if systemctl --global list-unit-files "$unit" >/dev/null 2>&1; then
        echo "Masking user service: $unit"
        systemctl --global mask "$unit" 2>/dev/null || true
    fi
done

echo "GNOME optimization complete: bloatware removed, background services trimmed."