#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

echo "==> Running stow..."

# Must cd into dotfiles dir so stow's glob expands against the right directory
cd "$DOTFILES_DIR"

# Detect stow conflicts (files that exist at symlink targets but are not symlinks)
# Run stow in simulate mode to capture conflict output
CONFLICTS=$(stow --simulate --target="$HOME" --restow */ 2>&1 | grep "existing target is neither a link nor a directory" || true)

if [[ -n "$CONFLICTS" ]]; then
  echo "==> Backing up conflicting files to $BACKUP_DIR ..."
  mkdir -p "$BACKUP_DIR"
  while IFS= read -r line; do
    # Extract the target path from stow's error message
    # Format: "  * existing target is neither a link nor a directory: .zshrc"
    FILE=$(echo "$line" | grep -oE '[^: ]+$')
    if [[ -n "$FILE" && -e "$HOME/$FILE" && ! -L "$HOME/$FILE" ]]; then
      echo "  Backing up ~/$FILE"
      mkdir -p "$BACKUP_DIR/$(dirname "$FILE")"
      mv "$HOME/$FILE" "$BACKUP_DIR/$FILE"
    fi
  done <<< "$CONFLICTS"
  echo "==> Backed up to $BACKUP_DIR"
fi

make

# Clone tpm if not present
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  echo "==> Cloning tpm (tmux plugin manager)..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  echo "==> tpm already installed, skipping."
fi

echo "==> [common] Done."
