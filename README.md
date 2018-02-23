# Config
Repo to store dotfiles and other configuration. Using it is the same as git
except `git` is replaced with `config`.  For example, to add a file `foo` just
do `config add foo` followed with `config commit` and `config push`.

# Installing
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
