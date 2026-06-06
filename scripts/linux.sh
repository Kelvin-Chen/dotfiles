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
  return 0 2>/dev/null || exit 0
fi

if [[ "$EUID" -ne 0 ]] && ! command -v sudo &>/dev/null; then
  echo "WARNING: sudo is required for package installs. Skipping package install."
  return 0 2>/dev/null || exit 0
fi

run_as_root() {
  if [[ "$EUID" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

install_pkg() {
  local pkg="$1"
  echo "==> Installing $pkg..."
  if [[ "$PM" == "apt" ]]; then
    run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg" || echo "WARNING: Failed to install $pkg — skipping."
  elif [[ "$PM" == "pacman" ]]; then
    run_as_root pacman -S --noconfirm "$pkg" || echo "WARNING: Failed to install $pkg — skipping."
  fi
}

if [[ -n "$PM" ]]; then
  # Update package index first
  if [[ "$PM" == "apt" ]]; then
    run_as_root apt-get update -q || echo "WARNING: apt-get update failed; continuing with package installs."
  elif [[ "$PM" == "pacman" ]]; then
    run_as_root pacman -Syu --noconfirm || echo "WARNING: pacman update failed; continuing with package installs."
  fi

  # Core packages (apt name / pacman name differ for some)
  install_pkg "curl"
  install_pkg "git"
  install_pkg "git-lfs"
  install_pkg "make"
  install_pkg "zsh"
  install_pkg "neovim"
  install_pkg "tmux"
  install_pkg "fzf"
  install_pkg "ripgrep"
  install_pkg "shellcheck"
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
