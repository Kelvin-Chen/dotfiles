#!/usr/bin/env bash
set -uo pipefail   # No -e: we want to continue on individual package failures

echo "==> [Linux] Setting up packages..."

# Detect package manager
if command -v apt-get &>/dev/null; then
  PM="apt"
elif command -v pacman &>/dev/null; then
  PM="pacman"
else
  echo "WARNING: No supported package manager found (apt or pacman). Skipping package install."
  exit 1
fi

install_pkg() {
  local pkg="$1"
  echo "==> Installing $pkg..."
  if [[ "$PM" == "apt" ]]; then
    sudo apt-get install -y "$pkg" || echo "WARNING: Failed to install $pkg — skipping."
  elif [[ "$PM" == "pacman" ]]; then
    sudo pacman -S --noconfirm "$pkg" || echo "WARNING: Failed to install $pkg — skipping."
  fi
}

if [[ -n "$PM" ]]; then
  # Update package index first
  if [[ "$PM" == "apt" ]]; then
    sudo apt-get update -q
  elif [[ "$PM" == "pacman" ]]; then
    sudo pacman -Sy --noconfirm
  fi

  # Core packages (apt name / pacman name differ for some)
  install_pkg "git"
  install_pkg "zsh"
  install_pkg "neovim"
  install_pkg "tmux"
  install_pkg "fzf"
  install_pkg "ripgrep"
  install_pkg "stow"
  install_pkg "tree"

  # fd: different package name on apt
  if [[ "$PM" == "apt" ]]; then
    install_pkg "fd-find"
  else
    install_pkg "fd"
  fi

  # Node
  install_pkg "nodejs"
  install_pkg "npm"
fi

echo "==> [Linux] Done."
