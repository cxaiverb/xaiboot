#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="xaiboot-trixie-amd64.iso"
DIST_DIR="dist"

if ! command -v lb >/dev/null 2>&1; then
  echo "error: live-build is not installed." >&2
  echo "Install it on Debian with: sudo apt install live-build" >&2
  exit 1
fi

ROOT_CMD=()
if [ "$(id -u)" -ne 0 ]; then
  if ! command -v sudo >/dev/null 2>&1; then
    echo "error: live-build needs root privileges and sudo is unavailable." >&2
    echo "Run this script as root, or install sudo and run it from an interactive terminal." >&2
    exit 1
  fi

  if [ -t 0 ]; then
    ROOT_CMD=(sudo)
  elif sudo -n true >/dev/null 2>&1; then
    ROOT_CMD=(sudo -n)
  else
    echo "error: lb build needs root privileges, but sudo cannot prompt in this session." >&2
    echo "Run from an interactive terminal with: ./build.sh" >&2
    echo "Or run directly as root with: sudo ./build.sh" >&2
    exit 1
  fi
else
  ROOT_CMD=()
fi

mkdir -p "$DIST_DIR"

echo "==> Configuring XaiBoot live-build tree"
lb config

echo "==> Building XaiBoot ISO"
"${ROOT_CMD[@]}" lb build

ISO_CANDIDATE=""
for candidate in live-image-amd64.hybrid.iso live-image-amd64.iso; do
  if [ -f "$candidate" ]; then
    ISO_CANDIDATE="$candidate"
    break
  fi
done

if [ -z "$ISO_CANDIDATE" ]; then
  echo "error: live-build completed but no expected ISO was found." >&2
  exit 1
fi

cp "$ISO_CANDIDATE" "$DIST_DIR/$IMAGE_NAME"
echo "==> ISO copied to $DIST_DIR/$IMAGE_NAME"
