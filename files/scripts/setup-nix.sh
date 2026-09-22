#!/usr/bin/bash
set -euo pipefail

# Wire up Fedora's official Nix packages with sane defaults for Floatfin:
#
#  - Flakes + nice defaults on for everyone via /etc/nix/nix.conf
#    (sandbox off: Nix's build sandbox misbehaves on immutable roots).
#  - Start the multi-user daemon as an always-on service (see below: socket
#    activation is blocked by SELinux on the immutable root).

# --- Enable the Nix daemon (guarded so a missing unit can't fail the build) --
#
# Prefer the always-on service over socket activation: with SELinux enforcing
# (Fedora default) systemd cannot bind /nix/var/nix/daemon-socket/socket —
# there is no policy allowing systemd to create that socket under /nix, so the
# socket unit dies with EACCES ("Permission denied"). The nix-daemon process
# itself *can* bind its own socket in its own domain, which is why the plain
# service works on Fedora Atomic images.
if systemctl list-unit-files nix-daemon.service >/dev/null 2>&1; then
    echo "Enabling nix-daemon.service (always-on daemon, binds its own socket)"
    systemctl disable nix-daemon.socket 2>/dev/null || true
    systemctl enable nix-daemon.service
elif systemctl list-unit-files nix-daemon.socket >/dev/null 2>&1; then
    # Fallback: only the socket exists (non-Fedora packaging or future rpm
    # change). Socket activation on the immutable root is blocked by SELinux,
    # but keep the enable so at least the unit is wired up.
    echo "Enabling nix-daemon.socket (socket-activated daemon; SELinux may block the bind)"
    systemctl enable nix-daemon.socket 2>/dev/null || true
else
    echo "nix-daemon unit not present; skipping daemon integration" >&2
fi

# --- Writable store on an immutable root --------------------------------------
# Fedora Atomic roots are read-only at boot, so the baked-in /nix directory
# can't hold a live store. floatfin-nix.mount binds persistent /var/lib/nix
# over /nix (backing dir created at boot by tmpfiles.d/floatfin-nix.conf).
# Without this, the first nix command dies with
# "/nix/store/.links: Read-only file system".
if systemctl list-unit-files floatfin-nix.mount >/dev/null 2>&1; then
    echo "Enabling floatfin-nix.mount (bind /var/lib/nix over /nix)"
    systemctl enable floatfin-nix.mount
else
    echo "floatfin-nix.mount not present; skipping writable-store integration" >&2
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