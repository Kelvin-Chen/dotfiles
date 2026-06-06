#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/Kelvin-Chen/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# Preflight: require git
if ! command -v git &>/dev/null; then
  echo "ERROR: git is required. Install it and re-run:"
  echo "  Debian/Ubuntu: sudo apt-get install git"
  echo "  Arch:          sudo pacman -S git"
  echo "  macOS:         xcode-select --install"
  exit 1
fi

# Clone repo if not already present
if [[ -d "$DOTFILES_DIR/.git" ]]; then
  echo "==> Dotfiles already cloned at $DOTFILES_DIR — skipping clone."
elif [[ -e "$DOTFILES_DIR" ]]; then
  echo "ERROR: $DOTFILES_DIR exists but is not a git checkout."
  echo "Move it aside or set DOTFILES_DIR to another path, then re-run."
  exit 1
else
  echo "==> Cloning dotfiles to $DOTFILES_DIR ..."
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# Hand off to bootstrap
exec bash "$DOTFILES_DIR/scripts/bootstrap.sh"
