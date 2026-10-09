#!/usr/bin/env bash
set -euo pipefail

REMOVE_DIST=0
if [ "${1:-}" = "--dist" ]; then
  REMOVE_DIST=1
fi

if ! command -v lb >/dev/null 2>&1; then
  echo "error: live-build is not installed." >&2
  echo "Install it on Debian with: sudo apt install live-build" >&2
  exit 1
fi

ROOT_CMD=()
if [ "$(id -u)" -ne 0 ]; then
  if ! command -v sudo >/dev/null 2>&1; then
    echo "error: live-build clean needs root privileges and sudo is unavailable." >&2
    echo "Run this script as root, or install sudo and run it from an interactive terminal." >&2
    exit 1
  fi

  if [ -t 0 ]; then
    ROOT_CMD=(sudo)
  elif sudo -n true >/dev/null 2>&1; then
    ROOT_CMD=(sudo -n)
  else
    echo "error: lb clean needs root privileges, but sudo cannot prompt in this session." >&2
    echo "Run from an interactive terminal with: ./clean.sh" >&2
    echo "Or run directly as root with: sudo ./clean.sh" >&2
    exit 1
  fi
else
  ROOT_CMD=()
fi

echo "==> Cleaning live-build artifacts"
"${ROOT_CMD[@]}" lb clean --purge

if [ "$REMOVE_DIST" -eq 1 ]; then
  echo "==> Removing dist artifacts"
  rm -rf dist
fi
