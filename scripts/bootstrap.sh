#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

###############################
# Helpers
###############################

info()    { echo "==> $*"; }
success() { echo "✓ $*"; }
warn()    { echo "WARNING: $*"; }

prompt() {
  # prompt <var_name> <prompt_text> [default]
  local var="$1" text="$2" default="${3:-}"
  if [[ -n "$default" ]]; then
    read -rp "$text [$default]: " value
    printf -v "$var" '%s' "${value:-$default}"
  else
    read -rp "$text: " value
    printf -v "$var" '%s' "$value"
  fi
}

###############################
# Preflight
###############################

if ! command -v git &>/dev/null; then
  echo "ERROR: git is required but not found. Install git and re-run."
  exit 1
fi

###############################
# Interactive phase
###############################

echo ""
echo "╔══════════════════════════════════╗"
echo "║   dotfiles bootstrap             ║"
echo "╚══════════════════════════════════╝"
echo ""

# Git identity — skip if machine-local config already exists
GIT_NAME=""
GIT_EMAIL=""
if [[ ! -f "$HOME/.config/git/gitconfig" ]]; then
  info "Git identity setup (written to ~/.config/git/gitconfig — not committed)"
  prompt GIT_NAME  "  Git name"
  prompt GIT_EMAIL "  Git email"
else
  info "~/.config/git/gitconfig already exists — skipping git identity prompt."
fi

# SSH key
SSH_KEY_REQUESTED=false
read -rp "==> Generate SSH key for GitHub? [y/N] " ssh_answer
if [[ "${ssh_answer,,}" == "y" ]]; then
  SSH_KEY_REQUESTED=true
fi

echo ""

###############################
# Automated phase
###############################

# 1. Platform packages
UNAME="$(uname)"
if [[ "$UNAME" == "Darwin" ]]; then
  # shellcheck source=scripts/macos.sh
  source "$DOTFILES_DIR/scripts/macos.sh"
elif [[ "$UNAME" == "Linux" ]]; then
  # shellcheck source=scripts/linux.sh
  source "$DOTFILES_DIR/scripts/linux.sh"
else
  warn "Unknown OS: $UNAME — skipping package install."
fi

# 2. Stow + tpm
# shellcheck source=scripts/common.sh
source "$DOTFILES_DIR/scripts/common.sh"

# 3. Git identity
if [[ -n "$GIT_NAME" && -n "$GIT_EMAIL" ]]; then
  info "Writing git identity to ~/.config/git/gitconfig ..."
  mkdir -p "$HOME/.config/git"
  cat > "$HOME/.config/git/gitconfig" <<EOF
[user]
	name = $GIT_NAME
	email = $GIT_EMAIL
EOF
  success "Git identity written."
fi

# 4. SSH key
if [[ "$SSH_KEY_REQUESTED" == true ]]; then
  SSH_KEY="$HOME/.ssh/id_ed25519"
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  if [[ -f "$SSH_KEY" ]]; then
    info "SSH key already exists at $SSH_KEY — skipping generation."
  else
    info "Generating SSH key..."
    ssh-keygen -t ed25519 -C "${GIT_EMAIL:-$(whoami)@$(hostname)}" -f "$SSH_KEY" -N ""
    success "SSH key generated."
  fi

  echo ""
  echo "==> Your public key (add this to https://github.com/settings/ssh/new):"
  echo "--------------------------------------------------------------------"
  cat "${SSH_KEY}.pub"
  echo "--------------------------------------------------------------------"
  echo ""
  read -rp "==> Press Enter once you've added the key to GitHub..."

  # Offer SSH remote conversion
  CURRENT_REMOTE="$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null || true)"
  if [[ "$CURRENT_REMOTE" == https://github.com/* ]]; then
    SSH_REMOTE="${CURRENT_REMOTE/https:\/\/github.com\//git@github.com:}"
    read -rp "==> Convert git remote to SSH ($SSH_REMOTE)? [y/N] " convert_answer
    if [[ "${convert_answer,,}" == "y" ]]; then
      git -C "$DOTFILES_DIR" remote set-url origin "$SSH_REMOTE"
      success "Remote updated to $SSH_REMOTE"
    fi
  fi
fi

# 5. Set default shell (Linux only — macOS handles this via System Settings)
if [[ "$UNAME" == "Linux" ]]; then
  ZSH_PATH="$(command -v zsh || true)"
  if [[ -n "$ZSH_PATH" && "$SHELL" != "$ZSH_PATH" ]]; then
    info "Setting zsh as default shell..."
    chsh -s "$ZSH_PATH"
    success "Default shell set to zsh. Re-login to apply."
  fi
fi

###############################
# End-of-run summary
###############################

echo ""
echo "╔══════════════════════════════════╗"
echo "║   Setup complete!                ║"
echo "╚══════════════════════════════════╝"
echo ""
echo "Remaining manual steps:"
echo "  • Open nvim — lazy.nvim installs plugins on first launch"
echo "    Then run :Mason to install LSP servers"
echo "  • Open tmux, then press <Ctrl-B> I to install tmux plugins"
echo "  • Add machine config to: ~/.zshrc_local, ~/.zshenv_local"
if [[ "$SSH_KEY_REQUESTED" == true ]]; then
  echo "  • Verify GitHub SSH: ssh -T git@github.com"
fi
echo ""
