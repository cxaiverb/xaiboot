#!/usr/bin/env bash
set -euo pipefail

required_files=(
  "README.md"
  "build.sh"
  "clean.sh"
  "auto/config"
  "config/includes.binary/isolinux/splash.png"
  "config/includes.binary/boot/grub/splash.png"
  "config/package-lists/live.list.chroot"
  "config/package-lists/xaiboot-rescue.list.chroot"
  "config/package-lists/xaiboot-network.list.chroot"
  "config/package-lists/xaiboot-desktop.list.chroot"
  "config/includes.chroot/etc/systemd/system/getty@tty1.service.d/override.conf"
  "config/includes.chroot/etc/sudoers.d/010-xaiboot"
  "config/includes.chroot/etc/X11/xinit/xinitrc"
  "config/includes.chroot/usr/local/bin/xaidesktop"
  "config/includes.chroot/usr/local/bin/xaihelp"
  "config/includes.chroot/etc/motd"
  "config/includes.chroot/etc/profile.d/xaiboot-help.sh"
  "config/includes.chroot/etc/skel/.bashrc"
  "config/includes.chroot/etc/NetworkManager/conf.d/10-xaiboot.conf"
  "config/hooks/normal/010-xaiboot-default-target.hook.chroot"
  "config/hooks/normal/020-xaiboot-permissions.hook.chroot"
  "docs/live-build-notes.md"
)

for path in "${required_files[@]}"; do
  if [ ! -f "$path" ]; then
    echo "missing: $path" >&2
    exit 1
  fi
done

for path in build.sh clean.sh auto/config \
  config/includes.chroot/usr/local/bin/xaidesktop \
  config/includes.chroot/usr/local/bin/xaihelp \
  config/hooks/normal/010-xaiboot-default-target.hook.chroot \
  config/hooks/normal/020-xaiboot-permissions.hook.chroot; do
  if [ ! -x "$path" ]; then
    echo "not executable: $path" >&2
    exit 1
  fi
done

echo "XaiBoot tree looks complete."
