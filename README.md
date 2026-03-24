# dotfiles

Config files managed with [GNU Stow](https://www.gnu.org/software/stow/),
which symlinks everything from this repo into `$HOME`.

## Quick start

```sh
curl -fsSL https://raw.githubusercontent.com/Kelvin-Chen/dotfiles/master/install.sh \
  -o /tmp/dotfiles-install.sh && bash /tmp/dotfiles-install.sh
```

This will:
1. Clone the repo to `~/dotfiles`
2. Ask for your git name/email and whether to generate an SSH key
3. Install packages (Homebrew + Brewfile on macOS; apt/pacman on Linux)
4. Symlink all dotfiles via GNU Stow
5. Clone the tmux plugin manager

Override the clone path: `DOTFILES_DIR=~/src/dotfiles bash /tmp/dotfiles-install.sh`

To remove all symlinks:

```sh
make delete
```

If the repo is already cloned, you can also run `make setup` directly.

## What's included

| Directory  | What it configures                          |
|------------|---------------------------------------------|
| `git/`     | Git config, aliases, LFS                    |
| `intellij/`| IdeaVim settings                            |
| `kitty/`   | Kitty terminal emulator                     |
| `latex/`   | latexmk (XeLaTeX)                           |
| `neovim/`  | Neovim (lua config with lazy.nvim)          |
| `shell/`   | Shared shell aliases                        |
| `tmux/`    | tmux config and statusline                  |
| `vim/`     | Vim fallback config (vimscript)             |
| `zsh/`     | Zsh config, plugins (zinit), prompt         |

## Post-install setup

The bootstrap handles most setup automatically. A few steps require manual interaction:

### Neovim

On first launch, [lazy.nvim](https://github.com/folke/lazy.nvim) will auto-install all plugins. Run `:Mason` to install LSP servers.

### tmux

The bootstrap clones [tpm](https://github.com/tmux-plugins/tpm) automatically. Press `<Ctrl-B> I` inside a running tmux session to install plugins.

### zsh plugins

Managed with [zinit](https://github.com/zdharma-continuum/zinit). Auto-bootstraps on first `zsh` launch.

## Local overrides

Machine-specific config can be added to these files (not tracked by git):

| File              | Purpose                          |
|-------------------|----------------------------------|
| `~/.zshenv_local` | Environment variables, PATH      |
| `~/.zshrc_local`  | Shell config, aliases            |
| `~/.zshrc_mac`    | macOS-specific shell config      |
| `~/.zshrc_linux`  | Linux-specific shell config      |
| `~/.config/kitty/local.conf` | Kitty overrides       |
| `~/.config/git/gitconfig`    | Git overrides (e.g. work email) |
