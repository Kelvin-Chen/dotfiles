# Agent Instructions

This file provides guidance to AI coding agents when working with code in this repository.

## Overview

Personal dotfiles managed with **GNU Stow**. Each top-level directory is a stow package — its contents get symlinked into `$HOME`.

## Commands

```sh
brew bundle          # Install packages from Brewfile
make                 # Symlink all explicit dotfile packages to $HOME
make check           # Bash syntax, optional ShellCheck, and Stow dry-run
make delete          # Remove all symlinks
```

```sh
# Bootstrap a new machine (run from anywhere, no repo required)
curl -fsSL https://raw.githubusercontent.com/Kelvin-Chen/dotfiles/master/install.sh \
  -o /tmp/dotfiles-install.sh && bash /tmp/dotfiles-install.sh

# Or if repo is already cloned:
make setup
```

Post-install (one-time):
```sh
# Zsh plugins — zinit auto-bootstraps on first zsh launch

# Tmux plugins — then press <Ctrl-B> I inside tmux to install
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Neovim — lazy.nvim auto-bootstraps on first launch; run :Mason to install LSP servers
```

## Architecture

### Stow layout

Each directory (e.g. `git/`, `zsh/`, `neovim/`) mirrors the home directory structure. `git/.gitconfig` → `~/.gitconfig`, `neovim/.config/nvim/init.lua` → `~/.config/nvim/init.lua`, etc.

**Important:** Stow sometimes links entire directories rather than individual files (e.g. `~/.zsh → dotfiles/zsh/.zsh`). When this happens, files under `~/.zsh/` are the actual dotfiles — not copies. Deleting or overwriting via the `~/` path modifies the repo directly. Always check `ls -la` before removing anything under a stow-managed path.

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

### Vim (`vim/`)

Minimal, **plugin-free** vimscript fallback — no plugin manager (no vim-plug)
and no external dependencies, so it works out of the box on any machine with
plain `vim`. In contrast to `neovim/` (the primary, full-featured editor),
`vim/` relies only on built-ins:

- Built-in colorscheme and a hand-written `statusline` (no airline/catppuccin).
- netrw for the file explorer (`<leader>n` → `:Explore`) and `:find` with
  `path+=**` / `wildmenu` for file finding (`<leader>f`).
- Built-in syntax highlighting and filetype detection; `vim/.vim/ftplugin/*`
  holds only plain per-filetype options (indent, `textwidth`, etc.).
- Shares neovim's core muscle-memory maps: leader = `<Space>`, `;`→`:`,
  `jk`/`kj`→`<Esc>`, `j`/`k`→`gj`/`gk`, `<C-h/j/k/l>` window nav, `<leader>w`
  save, `<leader>cd`, `<leader>tn`.

### Zsh (`zsh/`)

- `.zshenv` — minimal environment setup: XDG base directories, PATH, `$EDITOR`, `$LANG`, `$PAGER`, NVM/FZF defaults, and optional `~/.zshenv_local`
- `.zshrc` — bootstraps zinit when git is available, loads oh-my-zsh snippets eagerly in `light-mode`, defers heavy plugins (autosuggestions, fast-syntax-highlighting, completions) via turbo/async mode, and lazy-loads NVM only when installed
- `shell/.aliases` — shared aliases (`vi`/`vim` → `$EDITOR`, `fzfc` fuzzy grep, etc.)
- `.zsh/completions/` — custom zsh completion scripts (e.g. `_claude`). Stowed as a directory symlink. `.zshrc` prepends `$HOME/.zsh/completions` to `fpath` before the turbo block, because that block is where `compinit` runs.
- `.zsh/lib/cached-source.zsh` — defines `cached_source`, which sources a file through a local copy under `$XDG_CACHE_HOME/zsh` and refreshes it in a detached background job. Used for config on network filesystems (Piper `/google/src/head`, `/google/data/ro`), where a direct read costs ~100ms per shell and can stall for several hundred. Tradeoff: an edit to the source lands in the *next* shell.

#### Startup performance

Two constraints are easy to regress and cost real time, so both are commented
in `.zshrc`:

- **Keep the turbo (`zinit wait lucid`) list short.** The queue is drained
  roughly one item per prompt, so anything added there delays everything
  behind it. Moving the oh-my-zsh snippets into turbo saved only ~21ms but
  left `gst`/`docker` aliases undefined for the first several commands and
  pushed the syntax highlighter several prompts out. They stay eager.
- **`compinit` should run exactly once here.** `/etc/zsh/zshrc` (corp-managed)
  already runs an audited `compinit` before `.zshrc`, but it does so before
  `fpath` is extended, so the turbo block runs the one that matters. Each
  extra call re-runs `compaudit` over every `fpath` entry (~60ms). Note that
  `OMZL::completion.zsh` only sets zstyles — it does *not* call `compinit`.

To profile, remember `zprof` only measures *functions*: top-level `source` and
network I/O are invisible to it. Use `PS4='+$EPOCHREALTIME %N:%i> '` with
`setopt xtrace` to get per-line wall-clock timings.

### Tmux (`tmux/.tmux.conf`)

Plugins via tpm: vim-tmux-navigator, tmux-sensible, tmux-yank. Vi-style copy with OSC 52 clipboard (works over SSH). Statusline uses terminal color indices (color-scheme agnostic).

### Bootstrap scripts (`scripts/`)

- `install.sh` — curl target at repo root; checks for git, clones repo via HTTPS, execs bootstrap
- `scripts/bootstrap.sh` — orchestrator; interactive phase (git identity, SSH key), then unattended
- `scripts/macos.sh` — Homebrew install if missing + `brew bundle`
- `scripts/linux.sh` — apt/pacman detection, best-effort package install
- `scripts/common.sh` — stow conflict backup, `make` (stow), tpm clone

All scripts use `#!/usr/bin/env bash` and are idempotent.
`.stow-local-ignore` is committed to prevent `docs/`, `scripts/`, etc. from being stowed into `$HOME`.
The `Makefile` uses an explicit `PACKAGES` list instead of `*/` glob to avoid stowing non-dotfile dirs.
`make check` is the lightweight verification entry point for Bash syntax, optional ShellCheck, and Stow dry-runs.
`chsh` to set zsh as default shell is handled by `bootstrap.sh` (Linux only).
Git identity is written to `~/.config/git/gitconfig` (included by `git/.gitconfig` via `[include]`, never committed).
