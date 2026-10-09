# XaiBoot

XaiBoot is a reproducible Debian 13 trixie live ISO for troubleshooting,
repair, recovery, and hardware inspection on modern amd64 systems.

The project uses Debian's official `live-build` workflow. All image behavior is
defined by files in this repository; there are no manual post-build remastering
steps.

## What It Builds

- Debian 13 trixie live ISO
- amd64 target
- BIOS and UEFI boot support through live-build's hybrid ISO output
- Text-mode-first rescue environment
- Default live user: `xaiboot`
- Console autologin on `tty1`
- Passwordless sudo for `xaiboot`
- NetworkManager for easier wired and wireless networking
- XFCE desktop installed but not started automatically
- Manual desktop launch with `xaidesktop` or `startx`

## Get The Source

```bash
git clone https://github.com/cxaiverb/xaiboot.git
cd xaiboot
```

Clone onto a Linux filesystem. live-build creates device nodes and root-owned
files in its chroot, so building from a Windows drive mounted in WSL
(`/mnt/c/...`) does not work. On Windows, build inside a Debian WSL distro's
home directory.

## Build Host Requirements

Build on Debian 13 trixie or a compatible Debian host with these packages:

```bash
sudo apt update
sudo apt install live-build ca-certificates git
```

For UEFI-capable hybrid images, the build host may also need packages normally
pulled by live-build for the selected bootloaders, such as `xorriso`,
`isolinux`, `syslinux-common`, `grub-pc-bin`, and `grub-efi-amd64-bin`.
If live-build reports a missing helper package, install the package it names and
run the build again.

## Build The ISO

```bash
./build.sh
```

The resulting ISO is copied to:

```text
dist/xaiboot-trixie-amd64.iso
```

live-build also leaves its native output in the repository root, usually named
`live-image-amd64.hybrid.iso`.

## Rebuild From Clean State

```bash
./clean.sh
./build.sh
```

Use `./clean.sh --dist` to remove the copied ISO artifacts as well.

Run a clean rebuild after changing bootloader artwork or other binary includes,
because live-build tracks completed stages in `.build/`.

## How The Live User Works

The live username and hostname are passed through live-build's live boot
arguments in `auto/config`:

```text
username=xaiboot hostname=xaiboot
```

Debian's live-config stack creates the live user during boot. The repository
then layers standard system configuration on top of that user.

## Console Autologin

Console autologin is configured with a systemd getty override:

```text
config/includes.chroot/etc/systemd/system/getty@tty1.service.d/override.conf
```

The override starts `agetty` with `--autologin xaiboot` on `tty1`. Other TTYs
remain normal getty sessions.

## Passwordless Sudo

Passwordless sudo is configured with a sudoers drop-in:

```text
config/includes.chroot/etc/sudoers.d/010-xaiboot
```

The file grants:

```text
xaiboot ALL=(ALL) NOPASSWD:ALL
```

## Starting The Desktop

XaiBoot boots to text mode. Start XFCE manually from the shell:

```bash
xaidesktop
```

`xaidesktop` is a small wrapper around `startx`. Plain `startx` also works
because `/etc/X11/xinit/xinitrc` starts XFCE.

Exit the desktop by logging out from XFCE. You will return to the text console.

## Networking

NetworkManager is installed and enabled through the normal Debian package
defaults. Useful commands:

```bash
nmcli device
nmcli radio wifi on
nmcli device wifi list
sudo nmtui
```

The XFCE desktop also includes NetworkManager integration where the relevant
Debian packages are available.

## Package Customization

Package lists live in:

```text
config/package-lists/
```

Add packages to the existing `.list.chroot` files or create a new file ending
in `.list.chroot`. live-build installs those packages into the live system.

Keep rescue-critical tools in `xaiboot-rescue.list.chroot` and desktop packages
in `xaiboot-desktop.list.chroot` so the image purpose stays clear.

## Branding Customization

Current branding is intentionally light:

- `/etc/motd`
- `/etc/profile.d/xaiboot-help.sh`
- `/etc/skel/.bashrc`

Future branding can add boot splash assets, desktop wallpaper, icons, and
custom GRUB/SYSLINUX themes through live-build includes under
`config/includes.chroot/` and binary includes under `config/includes.binary/`.

The current boot menu background is sourced from:

```text
config/includes.binary/isolinux/splash.png
config/includes.binary/boot/grub/splash.png
```

Both files are copied from the root `isolinux-bg.png` artwork. The ISOLINUX
path is used for the BIOS boot menu. The GRUB path is included for UEFI boot
menu branding.

## Repository Layout

```text
.
├── README.md
├── build.sh
├── clean.sh
├── auto/
│   └── config
├── config/
│   ├── hooks/
│   │   └── normal/
│   │       ├── 010-xaiboot-default-target.hook.chroot
│   │       └── 020-xaiboot-permissions.hook.chroot
│   ├── includes.binary/
│   │   ├── boot/grub/splash.png
│   │   └── isolinux/splash.png
│   ├── includes.chroot/
│   │   ├── etc/
│   │   │   ├── NetworkManager/conf.d/10-xaiboot.conf
│   │   │   ├── X11/xinit/xinitrc
│   │   │   ├── motd
│   │   │   ├── profile.d/xaiboot-help.sh
│   │   │   ├── skel/.bashrc
│   │   │   ├── sudoers.d/010-xaiboot
│   │   │   └── systemd/system/getty@tty1.service.d/override.conf
│   │   └── usr/local/bin/
│   │       ├── xaidesktop
│   │       └── xaihelp
│   └── package-lists/
│       ├── live.list.chroot
│       ├── xaiboot-desktop.list.chroot
│       ├── xaiboot-network.list.chroot
│       └── xaiboot-rescue.list.chroot
├── docs/
│   └── live-build-notes.md
└── scripts/
    └── check-tree.sh
```

`lb config` regenerates `config/binary`, `config/bootstrap`, `config/chroot`,
`config/common`, `config/source`, and live-build's stock hooks from
`auto/config` on every build, so they are not tracked. Change build options in
`auto/config`. Name new hooks with a 3-digit prefix (for example `030-*`);
4-digit names are reserved for live-build's stock hooks and are git-ignored.

## Notes

This first implementation favors standard Debian mechanisms:

- live-build for image creation
- live-boot/live-config boot arguments for live session defaults
- systemd getty override for console autologin
- sudoers drop-in for passwordless sudo
- xinit/startx for manual desktop launch

That keeps XaiBoot maintainable as a rescue environment first and a desktop
environment second.
