#!/usr/bin/env bash
set -uo pipefail   # No -e: we want to continue on individual package failures

echo "==> [Linux] Setting up packages..."

# Detect package manager
if command -v apt-get &>/dev/null; then
  PM="apt"
elif command -v pacman &>/dev/null; then
  PM="pacman"
elif command -v dnf &>/dev/null; then
  PM="dnf"
else
  echo "WARNING: No supported package manager found (apt, pacman or dnf). Skipping package install."
  # `return` works when sourced by bootstrap.sh; `exit` covers running it
  # directly. ShellCheck can't see the sourced case and flags `exit` as dead.
  # shellcheck disable=SC2317
  return 0 2>/dev/null || exit 0
fi

if [[ "$EUID" -ne 0 ]] && ! command -v sudo &>/dev/null; then
  echo "WARNING: sudo is required for package installs. Skipping package install."
  # shellcheck disable=SC2317  # see above
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
  elif [[ "$PM" == "dnf" ]]; then
    run_as_root dnf install -y "$pkg" || echo "WARNING: Failed to install $pkg — skipping."
  fi
}

if [[ -n "$PM" ]]; then
  # Update package index first
  if [[ "$PM" == "apt" ]]; then
    run_as_root apt-get update -q || echo "WARNING: apt-get update failed; continuing with package installs."
  elif [[ "$PM" == "pacman" ]]; then
    run_as_root pacman -Syu --noconfirm || echo "WARNING: pacman update failed; continuing with package installs."
  fi
  # dnf refreshes its metadata on demand; nothing to do up front.

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
  if [[ "$PM" == "dnf" ]]; then
    install_pkg "ShellCheck"
  else
    install_pkg "shellcheck"
  fi
  install_pkg "stow"
  install_pkg "tree"

  # fd: different package name on apt and dnf
  if [[ "$PM" == "apt" || "$PM" == "dnf" ]]; then
    install_pkg "fd-find"
  else
    install_pkg "fd"
  fi

  # Node
  install_pkg "nodejs"
  install_pkg "npm"
fi

echo "==> [Linux] Done."
