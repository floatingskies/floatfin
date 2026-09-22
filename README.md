# floatfin &nbsp; [![bluebuild build badge](https://github.com/floatingskies/floatfin/actions/workflows/build-daily.yml/badge.svg)](https://github.com/floatingskies/floatfin/actions/workflows/build-daily.yml)

Immutable, signed, bootable-container desktop images tuned for **sysadmin / devops work and gaming**. Built on [Bluefin DX](https://projectbluefin.io) and [Bazzite (GNOME)](https://bazzite.gg) with [BlueBuild](https://blue-build.org); every tweak is baked in at build time.

**Ours is the *wizard-fox* terminal-first edition**: same rock-solid immutable base, but the terminal is a first-class citizen and every skill level has a door. Type `float` in any terminal and the wizard walks you from first boot to power-user tricks.

<p align="center"><img src="branding/foxy.png" alt="Floatfin — the wizard fox" width="320"></p>

## Why you'd retire for this

- **A real admin console out of the box** — [Cockpit](https://cockpit-project.org) (system/storage/network/containers web UI) enabled on boot at `https://<host>:9090`, `sshd` enabled, and a full CLI battery: `ansible-core`, `tmux`, `btop`, `htop`, `iotop`, `ncdu`, `lsof`, `psmisc`, `strace`, `nmap`, `tcpdump`, `rsync`, `sysstat`, `iperf3`, `mtr`, `smartctl`…
- **Terminal-first, but friendly** — curated **fish** + **Starship** prompt in Fira Code: `l`/`cat`/`top` already map to `eza`/`bat`/`btop`, `cd` jumps with zoxide, and the **`float` wizard** walks you through three tiers: *the easy tour* (updates, installs, GNOME Tour), *the workbench* (distrobox, nix, podman, ssh, Cockpit) and *system power tools* (bootc rebase/rollback, cosign verify, audits). Beginners aren't an afterthought.
- **The whole GNOME core, native RPMs** — Calendar, Clocks, Contacts, Maps, Weather, Connections, Calculator, Characters, Text Editor, `seahorse`… plus the interactive **GNOME Tour** for first-timers. No flatpaks baked in; search providers wired up for the installed set.
- **Performance-tuned GNOME** — idle RAM ~1.5 GB (stock desktop images idle near 2 GB and up): bloatware and ~20 idle services (Bluetooth daemon, remote desktop, ModemManager, ABRT, PackageKit, Tracker indexers, auto-update timers…) purged; animations off; tuned swap/cache + BBR networking.
- **Devops workbench** — Bluefin DX base: VS Code, rootless Docker + podman, Homebrew. On top: `podman.socket`, `podman-compose`, **`distrobox`**, `buildah`, `skopeo`, `gh`, `git-lfs`, `yq`, `bat`, `eza`, `duf`, `fzf`, `ripgrep`, `fd-find`, `nodejs`/`npm`/`python3-pip`.
- **Nix, ready to go** — Fedora's official Nix with **flakes enabled by default** and a socket-activated multi-user daemon sharing one store across users: `nix run nixpkgs#hello`, `nix develop`, `nix-shell`. (Also Homebrew and Flatpak coexist fine.)
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
| `floatfin-silverblue:gts` | **Silverblue 43** | weekly | backup edition |
| `floatfin-silverblue:latest` (also `stable`) | **Silverblue 44** | daily | backup edition |

The **Silverblue backup editions** are insurance: the exact same Floatfin customizations (terminal-first tools, `float` wizard, Nix, distrobox, dock, cockpit/SSH/podman sockets, fox branding) baked onto **stock Fedora Silverblue**, always one Fedora release behind Bluefin — no Universal Blue base involved. If Bluefin ever disappears, run `sudo bootc switch ghcr.io/floatingskies/floatfin-silverblue:latest` and nothing changes.

## ISO & live desktop

- **Live ISO:** trigger the **Build Live ISOs** workflow in Actions, download the `*-live` artifact (kept **7 days** — too big for GitHub Releases), boot it, then run **Install to Disk**. Secure Boot supported.
- **Offline ISO:** `./download-iso.sh floatfin gts` *(tag: `gts`, `stable` or `latest`)*

## Day-1 commands

```bash
float                           # the wizard: easy tour → workbench → power tools
ssh <host>                      # remote shell (openssh socket-activated)
https://<host>:9090             # Cockpit admin web UI
distrobox enter fedora          # drop into a full Fedora container, share ~
distrobox enter ubuntu -- bash  # ...or any other distro
nix run nixpkgs#hello           # first Nix command (multi-user daemon is already running)
nix develop nixpkgs#python3     # drop into a Python shell from nixpkgs
# Nix store lives on persistent /var: the immutable root bind-mounts /var/lib/nix onto /nix at boot.
# The daemon runs as an always-on service (socket activation is blocked by SELinux on immutable roots).
gamemoderun %command%           # per-game: GameMode CPU/I-O priority (Steam launch option)
MANGOHUD=1 %command%            # per-game: enable the Mangohud overlay
```

## Verify & build locally

```bash
cosign verify --key cosign.pub ghcr.io/floatingskies/floatfin:gts
./build-image.sh [recipe]       # recipes live in recipes/ (floatfin-{latest,stable,gts}.yml, floatite.yml, floatfin-silverblue{-gts}.yml)
```