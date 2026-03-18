# dotfiles

Config files managed with [GNU Stow](https://www.gnu.org/software/stow/),
which symlinks everything from this repo into `$HOME`.

## Quick start

```sh
# Install Homebrew packages
brew bundle

# Symlink all dotfiles
make
```

To remove all symlinks:

```sh
make delete
```

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

### zsh plugins

Plugins are managed with [zinit](https://github.com/zdharma-continuum/zinit).
On first launch, `.zshrc` will automatically clone zinit and install plugins.

### Neovim

On first launch, [lazy.nvim](https://github.com/folke/lazy.nvim) will
auto-install all plugins. Run `:Mason` to manage LSP servers.

### tmux

Install the [tpm](https://github.com/tmux-plugins/tpm) plugin manager:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then press `<Ctrl-B> I` inside tmux to install plugins.

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
