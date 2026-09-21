#!/usr/bin/bash
set -euo pipefail

# Wire up Fedora's official Nix packages with sane defaults for Floatfin:
#
#  - Flakes + nice defaults on for everyone via /etc/nix/nix.conf
#    (sandbox off: Nix's build sandbox misbehaves on immutable roots).
#  - Start the multi-user daemon. Prefer the socket-activated unit (zero idle
#    RAM, spawns only on first nix command) with a guarded fallback to the
#    always-on service, so this survives Fedora packaging changes.

# --- Enable the Nix daemon (guarded so a missing unit can't fail the build) --
if systemctl list-unit-files nix-daemon.socket >/dev/null 2>&1; then
    echo "Enabling nix-daemon.socket (socket-activated daemon)"
    systemctl enable nix-daemon.socket 2>/dev/null || true
elif systemctl list-unit-files nix-daemon.service >/dev/null 2>&1; then
    echo "Enabling nix-daemon.service"
    systemctl enable nix-daemon.service 2>/dev/null || true
else
    echo "nix-daemon unit not present; skipping daemon integration" >&2
fi

# --- Flakes on, and keep the daemon honest -----------------------------------
# Merge into any config the package ships: single idempotent block guarded by a
# marker so rebuilds don't duplicate it.
mkdir -p /etc/nix
CONF=/etc/nix/nix.conf
MARKER="# Floatfin nix defaults"
touch "$CONF"
if ! grep -q "$MARKER" "$CONF"; then
    cat >>"$CONF" <<EOF

$MARKER
experimental-features = nix-command flakes
keep-derivations = true
keep-outputs = true
sandbox = false
EOF
    echo "Appended flake defaults to $CONF"
else
    echo "$CONF already has Floatfin nix defaults (rebuild-friendly, no-op)"
fi

echo "Nix is ready: 'nix run nixpkgs#hello' exercises the whole stack."