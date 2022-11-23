# dotfiles

## Overview

This is a git repo to store my dotfiles and other config files. It uses GNU Stow
to symlink the dotfiles from this repo to the `$HOME` directory.

## Installation

### Prerequisites

The following prequisites are needed:

- stow
- make

Make is not actually a hard prerequisite, it just helps provide the build
targets to run `stow`.  Alternatively, just manually run the command listed in
the Makefile.

### Symlinking the dotfiles

```sh
make
```

### Cleaning up the dotfiles

```sh
make delete
```

## Setting up zsh

### Installing zplug and plugins

zsh plugins are managed using [zplug](https://github.com/zplug/zplug).

Install with the following command:

```sh
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
```

Then install all plugins defined in `.zshrc`:

```sh
zplug install
```

## Setting up tmux

Using tmux requires installing the tpm plugin:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then in tmux use `<Ctrl-B> I` to install the tmux plugins.
