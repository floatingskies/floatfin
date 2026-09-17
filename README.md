# ublue-float &nbsp; [![bluebuild build badge](https://github.com/floatingskies/ublue-float/actions/workflows/build-daily.yml/badge.svg)](https://github.com/floatingskies/ublue-float/actions/workflows/build-daily.yml)

A bit opinionated distro made by Float.

These are [Bootable Container](https://containers.github.io/bootable/) images built from [Universal Blue](https://universal-blue.org) base images with [BlueBuild](https://blue-build.org)'s tools. The images contain either the [Fedora Silverblue](https://silverblue.fedoraproject.org), [Bluefin](https://projectbluefin.io), or [Bazzite](https://bazzite.gg) operating system with my personal preferences baked in. All images get a similar GNOME desktop experience.

Modifications common to all images:

-   Brave installed as default browser
-   Curated selection of Flatpak apps baked into the image (this overrides Bluefin's default flatpak choices)
-   [Web App Hub](https://github.com/pvermeer/webapp-hub) to turn your favourite sites into desktop web apps
-   Network tools baked in as Flatpaks: Wireshark and FileZilla
-   Creative Flatpaks: GIMP, Krita, Inkscape, darktable, Audacity, Pinta
-   Clocks set to AM/PM view with Weekday Display
-   Single click to open items in Nautilus
-   Use smaller icons in Nautilus icon view
-   Sort directories first in Nautilus and GTK file choosers
-   Dark styles enabled by default
-   Floating-woof wallpapers, one per edition (Silverblue, Bluefin, Bazzite), available in the GNOME wallpaper picker
-   [System76 wallpaper collection](https://system76.com/merch/desktop-wallpapers)
-   [Framework 12](https://frame.work/laptop12) wallpapers
-   Historical Ubuntu wallpapers, mostly from the LTS versions
-   Historical KDE and modern Plasma wallpaper collections
-   [Intel One Mono](https://www.intel.com/content/www/us/en/company-overview/one-monospace-font.html) set as default monospace font

For the ublue-float Images (`ghcr.io/floatingskies/ublue-float`):

-   Visual Studio Code RPM installed
-   Libvirt/Virt-Manager installed on host
-   Docker CE installed with rootful Docker disabled
-   Dash-to-Dock enabled by default, skipping Overview on login
-   Appindicators enabled by default
-   Logo Menu enabled by default (like Bluefin)
-   Windows have minimize and maximize buttons (like Ubuntu and Bluefin)
-   Additional packages (e.g. Firewall GUI, rclone/restic, Universal Blue enhancements)
-   `<CTRL><ALT>t` opens a terminal

For the bluefin-float Image (`ghcr.io/floatingskies/bluefin-float`):

-   Starship disabled by default (users can enable if needed)
-   Rootful Docker disabled. Users can set up [rootless Docker](https://docs.docker.com/engine/security/rootless/) for themselves.
-   A different list of default flatpaks

For the bazzite-float Image (`ghcr.io/floatingskies/bazzite-float`)

-   GNOME desktop with similar UI to the other images
-   Developer mode enabled (i.e. based on `bazzite-dx-gnome`)
-   Steam does not autostart on login

## Which Image? Which Version?

ublue-float (Fedora Silverblue):

-   `ghcr.io/floatingskies/ublue-float:gts` -- Fedora 43, updated weekly
-   `ghcr.io/floatingskies/ublue-float:stable` -- Fedora 44, updated weekly
-   `ghcr.io/floatingskies/ublue-float:latest` -- Fedora 44, updated daily

bluefin-float:

-   `ghcr.io/floatingskies/bluefin-float:latest` -- [Bluefin DX](https://docs.projectbluefin.io/administration#upgrades-and-throttle-settings) with developer tools, following Bluefin's latest stream, updated daily

bazzite-float:

-   `ghcr.io/floatingskies/bazzite-float:latest` -- Bazzite DX GNOME following the latest stream, updated daily

## Installation

First, install any [Fedora Atomic](https://fedoraproject.org/atomic-desktops/) or [Universal Blue](https://universal-blue.org) desktop edition (preferably one that features GNOME, like Silverblue or Bluefin).

Then use `bootc switch` to switch to the image you want. For example:

```
sudo bootc switch ghcr.io/floatingskies/ublue-float:latest --enforce-container-sigpolicy
```

Then reboot

```
systemctl reboot
```

## Installing via ISO

If you have `podman` installed on your system, you can generate an offline ISO with the `download-iso.sh` script in this directory, like this:

```
./download-iso.sh $IMAGE_NAME $TAG_NAME
```

where `$IMAGE_NAME` is one of `ublue-float`, `bluefin-float`, or `bazzite-float` and `TAG_NAME` corresponds to `stable` (`ublue-float` only), `gts`, or `latest`.

## Live ISO Images

Like [Bluefin](https://projectbluefin.io) and [Bazzite](https://bazzite.gg), live desktop ISOs are built using [Titanoboa](https://github.com/ublue-os/titanoboa). Trigger the **"Build Live ISOs"** GitHub Actions workflow ([Actions → Build Live ISOs](https://github.com/floatingskies/ublue-float/actions/workflows/build-iso.yml)) and download the artifacts:

-   `ublue-float-stable-live-amd64.iso` — live Silverblue desktop with the installed image inside
-   `bluefin-float-latest-live-amd64.iso` — live Bluefin desktop with the installed image inside
-   `bazzite-float-latest-live-amd64.iso` — live Bazzite desktop with the installed image inside

Boot the ISO and you get the full desktop running live from the image. To install the image to disk, launch **"Install to Disk"** from the desktop (Anaconda). The installer will also offer to enroll the Universal Blue secure boot key (password: `universalblue`) so it can boot with Secure Boot; it also works fine without Secure Boot, or you can enroll your own keys later.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```
cosign verify --key cosign.pub ghcr.io/floatingskies/ublue-float:gts
cosign verify --key cosign.pub ghcr.io/floatingskies/ublue-float:stable
cosign verify --key cosign.pub ghcr.io/floatingskies/ublue-float:latest
cosign verify --key cosign.pub ghcr.io/floatingskies/bluefin-float:latest
cosign verify --key cosign.pub ghcr.io/floatingskies/bazzite-float:latest
```

## Building Locally

```
./build-image.sh [recipe file]
```