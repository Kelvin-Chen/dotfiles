# Config

## Overview

This is a repo to store dotfiles and other configuration.
It is implemented as a git repository with the working tree rooted to the
home directory.
Manipulation of this repo is done with the `config` alias.

## Installing

```sh
git clone --separate-git-dir="$HOME/.myconf" \
    git@github.com:Kelvin-Chen/config.git \
    "$HOME/myconf-tmp"

cp ~/myconf-tmp/.gitmodules ~ # For submodules

alias config='git --git-dir=$HOME/.myconf/ --work-tree=$HOME'

config config --local status.showUntrackedFiles no

config reset --hard HEAD

rm -rf ~/myconf-tmp/

curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

config submodule update --init --recursive
```
