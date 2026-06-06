#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

echo "==> [macOS] Setting up packages..."

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v brew &>/dev/null; then
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$brew_bin" ]]; then
      eval "$("$brew_bin" shellenv)"
      break
    fi
  done
fi

if ! command -v brew &>/dev/null; then
  echo "ERROR: Homebrew was installed but brew is not on PATH."
  echo "Open a new shell or add Homebrew shellenv to your local zsh config."
  exit 1
fi

echo "==> Running brew bundle..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

echo "==> [macOS] Done."
