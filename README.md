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

Before changing symlinks, you can run the lightweight checks:

```sh
make check
```

This runs Bash syntax checks, ShellCheck when installed, and a GNU Stow dry-run
against the explicit package list in the Makefile.

## Verifying the vim fallback

The `vim/` package is a zero-dependency fallback, so it needs no install step.
To verify it after changes, run the headless smoke test from the repo root:

```sh
bash scripts/vim_smoke_test.sh
```

It checks that vim loads with no errors, that the core keybindings are present,
that no plugin-manager artifacts remain, and that `make check` passes.

Manual sanity check — open a file with only the fallback config and try the
core muscle-memory keys:

```sh
vim -u vim/.vimrc README.md
```

| Action | Expected result |
|---|---|
| Press `;` (normal mode) | Enters command-line mode (`:`) |
| Type `jk` or `kj` (insert mode) | Returns to normal mode |
| Press `j` / `k` on a wrapped long line | Cursor moves by *screen* line (`gj`/`gk`) |
| `<Space>w` | Saves the file (`:w!`) |
| `<Space>cd` | `:lcd` to the file's dir — confirm with `:pwd` |
| `<Space>tn` | Opens a new tab |
| `:vsplit` then `<Ctrl-h>`/`<Ctrl-l>` | Moves between windows |
| `<Space>n` | Opens the **netrw** file explorer |
| `<Space>f` | Starts `:find ` (type a name, `<Tab>` completes via `path`+`wildmenu`) |
| Overall | No error messages; statusline + colors render with **no plugins installed** |

## What's included

| Directory  | What it configures                          |
|------------|---------------------------------------------|
| `git/`     | Git config, aliases, LFS                    |
| `intellij/`| IdeaVim settings                            |
| `kitty/`   | Kitty terminal emulator                     |
| `latex/`   | latexmk (XeLaTeX)                           |
| `neovim/`  | Neovim — primary editor (lua config, lazy.nvim) |
| `shell/`   | Shared shell aliases                        |
| `tmux/`    | tmux config and statusline                  |
| `vim/`     | Minimal, plugin-free Vim fallback (vimscript) |
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
| `~/.config/kitty/local.conf` | Kitty overrides       |
| `~/.config/git/gitconfig`    | Git overrides (e.g. work email) |

The tracked `~/.zshrc_mac` and `~/.zshrc_linux` files are sourced
automatically on their matching platforms. Use `~/.zshrc_local` for
machine-specific shell customizations that should not be committed.
