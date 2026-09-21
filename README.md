# floatfin &nbsp; [![bluebuild build badge](https://github.com/floatingskies/floatfin/actions/workflows/build-daily.yml/badge.svg)](https://github.com/floatingskies/floatfin/actions/workflows/build-daily.yml)

Custom bootable container images tailored for production systems, workstations, and gaming. Built on top of **Bluefin DX** and **Bazzite (GNOME)** using **BlueBuild** tooling. All configurations are baked into the image layers at build time, including a regenerated initramfs to ensure branding persists from initial boot.

---

## Features & Enhancements

### Production & Corporate Stability
* **GTS (Great Timber Stable)** edition available for enterprise deployments, server management, and production environments requiring maximum stability and predictable updates.

### System Branding & Aesthetic
* **Float Identity:** Custom *Floatfin* and *Floatite* identity integrated into Settings, installer branding, hostname, Plymouth boot splash, and GDM login screen.
* **Default Wallpaper:** `fox.jpg` from the `floating-skies` collection set as default, alongside `floating-woof`, System76, Framework, Ubuntu, and KDE/Plasma options.
* **Typography:** **Intel One Mono** set as the primary interface font (Adwaita Sans retained for documents).
* **Terminal Experience:** Custom `fastfetch` and login greeting displaying system status alongside the `foxy.png` logo, replacing *uwelcome*.
* **Appearance:** Dark mode enabled out of the box.

### Desktop & Interface Tweaks
* **Dock & Navigation:** Dash-to-Dock docked at the bottom, configured to skip the Overview screen on login.
* **Window Controls:** Minimize and maximize buttons enabled.
* **File Manager (Nautilus):** Single-click item opening, compact icon view, and directories sorted first across Nautilus and GTK file choosers.
* **Input & Clock:** Touchpad tap-to-click enabled by default; 12-hour AM/PM clock display with weekday headers.

### Applications & Tooling
* **Browsing & Gaming:** Firefox installed as the default browser via RPM. Steam pre-installed from `negativo17` on Bluefin builds (native on Bazzite).
* **Bluefin DX Base:** Retains VS Code, Docker/Podman support, Logo Menu, AppIndicator integration, and the `<Ctrl><Alt>T` terminal shortcut.
* **Baked-in DevOps & Sysadmin Suite:**
  * **Automation & Dev:** `ansible-core`, `gh`, `git-lfs`, `jq`, `shellcheck`, `nodejs`, `npm`, `python3-pip`
  * **Networking & Utilities:** `bind-utils`, `iperf3`, `mtr`, `net-tools`, `sshpass`, `whois`, `wget`
  * **System Monitoring & CLI Utilities:** `btop`, `fd-find`, `fzf`, `htop`, `iotop`, `ncdu`, `pv`, `ripgrep`, `sysstat`, `tmux`, `tree`

---

## Image Tags

Container images are hosted on the GitHub Container Registry (`ghcr.io`):

| Image Tag | Base Stream | Update Schedule | Target Use Case |
| :--- | :--- | :--- | :--- |
| `ghcr.io/floatingskies/floatfin:gts` | Bluefin GTS (Great Timber Stable) | Weekly | Production machines & corporate environments |
| `ghcr.io/floatingskies/floatfin:stable` | Bluefin Stable | Weekly | Standard desktop deployment |
| `ghcr.io/floatingskies/floatfin:latest` | Bluefin Latest | Daily | Cutting-edge desktop features |
| `ghcr.io/floatingskies/floatite:latest` | Bazzite DX (GNOME) | Daily | Gaming & handheld devices |

---

## Installation

### Switching from an Existing Installation
From any existing Fedora Atomic Desktop (Silverblue, Kinoite, etc.) or Universal Blue variant:

```bash
sudo bootc switch ghcr.io/floatingskies/floatfin:gts --enforce-container-sigpolicy
systemctl reboot
```

### Generating an ISO
To build an offline installation ISO using Podman:

```bash
./download-iso.sh floatfin gts
```
*(Options for tag name: `gts`, `stable`, or `latest`)*

### Live ISO Images
Live desktop ISOs are built using [Titanoboa](https://github.com/ublue-os/titanoboa). You can trigger the **Build Live ISOs** workflow via GitHub Actions (**Actions → Build Live ISOs**) and download the resulting `floatfin-gts-live-amd64.iso` artifact.

Boot the live environment and launch **Install to Disk** (Anaconda) to write the image directly to storage.

---

## Verification

Images are cryptographically signed via [Cosign](https://github.com/sigstore/cosign). Verify image integrity using the public key from this repository:

```bash
cosign verify --key cosign.pub ghcr.io/floatingskies/floatfin:gts
cosign verify --key cosign.pub ghcr.io/floatingskies/floatfin:stable
cosign verify --key cosign.pub ghcr.io/floatingskies/floatfin:latest
cosign verify --key cosign.pub ghcr.io/floatingskies/floatite:latest
```

---

## Building Locally

To trigger a local build using BlueBuild recipes:

```bash
./build-image.sh [recipe file]
```
