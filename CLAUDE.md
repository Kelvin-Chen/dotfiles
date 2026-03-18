# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles managed with **GNU Stow**. Each top-level directory is a stow package — its contents get symlinked into `$HOME`.

## Commands

```sh
brew bundle          # Install packages from Brewfile
make                 # Symlink all dotfiles to $HOME (stow --restow */)
make delete          # Remove all symlinks
```

Post-install (one-time):
```sh
# Zsh plugins
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

# Tmux plugins — then press <Ctrl-B> I inside tmux to install
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Neovim — lazy.nvim auto-bootstraps on first launch; run :Mason to install LSP servers
```

## Architecture

### Stow layout

Each directory (e.g. `git/`, `zsh/`, `neovim/`) mirrors the home directory structure. `git/.gitconfig` → `~/.gitconfig`, `neovim/.config/nvim/init.lua` → `~/.config/nvim/init.lua`, etc.

### Machine-specific overrides (not tracked)

These files are sourced if present but never committed:
- `~/.zshenv_local` — PATH, environment variables
- `~/.zshrc_local` — aliases, shell config
- `~/.config/git/gitconfig` — git identity/overrides
- `~/.config/kitty/local.conf` — kitty overrides

### Neovim (`neovim/.config/nvim/`)

Lua config using lazy.nvim. Plugin specs are split by category in `lua/plugins/`:
- `editor.lua` — surround, comments, autopairs, flash
- `lsp.lua` — Mason + mason-lspconfig (Lua, Python, TypeScript LSPs)
- `treesitter.lua` — syntax highlighting
- `ui.lua` — UI enhancements
- `navigation.lua` — navigation plugins
- `git.lua` — git integration

### Zsh (`zsh/`)

- `.zshenv` — sets `$EDITOR`, `$LANG`, FZF defaults, lazy NVM loading
- `.zshrc` — loads zplug plugins (oh-my-zsh modules, zsh-users/autosuggestions, syntax-highlighting), then sources `.zshrc_mac` or `.zshrc_linux`
- `shell/.aliases` — shared aliases (`vi`/`vim` → `$EDITOR`, `fzfc` fuzzy grep, etc.)

### Tmux (`tmux/.tmux.conf`)

Plugins via tpm: vim-tmux-navigator, tmux-sensible, tmux-yank. Vi-style copy with OSC 52 clipboard (works over SSH). Statusline uses terminal color indices (color-scheme agnostic).
