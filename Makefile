.PHONY: all delete setup

PACKAGES = git intellij kitty latex neovim shell tmux vim zsh

all:
	stow --verbose --target=$(HOME) --restow $(PACKAGES)

delete:
	stow --verbose --target=$(HOME) --delete $(PACKAGES)

setup:
	@bash scripts/bootstrap.sh
