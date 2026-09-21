# floatfin &nbsp; [![bluebuild build badge](https://github.com/floatingskies/floatfin/actions/workflows/build-daily.yml/badge.svg)](https://github.com/floatingskies/floatfin/actions/workflows/build-daily.yml)

Immutable, signed, bootable-container desktop images tuned for **sysadmin / devops work and gaming**. Built on [Bluefin DX](https://projectbluefin.io) and [Bazzite (GNOME)](https://bazzite.gg) with [BlueBuild](https://blue-build.org); every tweak is baked in at build time.

## Why you'd retire for this

- **A real admin console out of the box** — [Cockpit](https://cockpit-project.org) (system/storage/network/containers web UI) enabled on boot at `https://<host>:9090`, `sshd` enabled, and a full CLI battery: `ansible-core`, `tmux`, `btop`, `htop`, `iotop`, `ncdu`, `lsof`, `psmisc`, `strace`, `nmap`, `tcpdump`, `rsync`, `sysstat`, `iperf3`, `mtr`, `smartctl`…
- **Performance-tuned GNOME** — idle RAM ~900 MB–1 GB. Bloatware and ~20 idle services (Bluetooth daemon, ModemManager, ABRT, PackageKit, Tracker indexers, auto-update timers…) purged; animations off; tuned swap/cache + BBR networking.
- **Devops workbench** — Bluefin DX base: VS Code, rootless Docker + podman, Homebrew. On top: `podman.socket`, `podman-compose`, `buildah`, `skopeo`, `gh`, `git-lfs`, `yq`, `bat`, `eza`, `duf`, `fzf`, `ripgrep`, `fd-find`, `nodejs`/`npm`/`python3-pip`. Nix works too.
- **KVM virtualization** — libvirt, `virt-manager` and VM tooling ready to go.
- **Gaming ready** — Steam (Bluefin builds), **GameMode**, **Gamescope**, **Mangohud** (32-bit included), Vulkan tools.
- **Flatpak-ready, zero flatpaks shipped** — Flathub works; nothing baked in. Dock shows only native apps.

## Install (from any Fedora Atomic / Universal Blue image)

```bash
sudo bootc switch ghcr.io/floatingskies/floatfin:latest --enforce-container-sigpolicy
systemctl reboot
```

## Images

| Tag | Base | Schedule | Use |
| :--- | :--- | :--- | :--- |
| `floatfin:gts` | Bluefin GTS | weekly | production / enterprise |
| `floatfin:stable` | Bluefin Stable | weekly | daily driver |
| `floatfin:latest` | Bluefin Latest | daily | newest features |
| `floatite:latest` | Bazzite DX GNOME | daily | gaming / handheld |

## ISO & live desktop

- **Live ISO:** trigger the **Build Live ISOs** workflow in Actions, boot the artifact, then run **Install to Disk**. Secure Boot supported.
- **Offline ISO:** `./download-iso.sh floatfin gts` *(tag: `gts`, `stable` or `latest`)*

## Day-1 commands

```bash
ssh <host>                      # remote shell (openssh enabled)
https://<host>:9090             # Cockpit admin web UI
gamemoderun %command%           # per-game: GameMode CPU/I-O priority (Steam launch option)
MANGOHUD=1 %command%            # per-game: enable the Mangohud overlay
```

## Verify & build locally

```bash
cosign verify --key cosign.pub ghcr.io/floatingskies/floatfin:gts
./build-image.sh [recipe]       # recipes live in recipes/ (floatfin-{latest,stable,gts}.yml, floatite.yml)
```