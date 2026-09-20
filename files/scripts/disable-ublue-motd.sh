#!/usr/bin/bash

set -eou pipefail

# Remove the MOTD launchers and binaries baked into the Bluefin/Bazzite base
# images so no update/tip banner is shown on login for bash, zsh or fish.
rm -f /etc/profile.d/ublue-motd.sh
rm -f /etc/profile.d/user-motd.sh
rm -f /usr/libexec/ublue-motd
rm -f /usr/bin/ublue-motd
rm -f /usr/bin/umotd
rm -rf /usr/share/ublue-os/motd
rm -f /usr/share/fish/vendor_conf.d/fish_greeting.fish
rm -f /usr/share/fish/vendor_conf.d/fish_greeting.sh
rm -f /etc/fish/conf.d/fish_greeting.fish