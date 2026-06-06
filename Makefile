.PHONY: all delete setup check shellcheck stow-check

PACKAGES = git intellij kitty latex neovim shell tmux vim zsh
SCRIPTS = install.sh scripts/bootstrap.sh scripts/common.sh scripts/macos.sh scripts/linux.sh

all:
	stow --verbose --target=$(HOME) --restow $(PACKAGES)

delete:
	stow --verbose --target=$(HOME) --delete $(PACKAGES)

setup:
	@bash scripts/bootstrap.sh

check: shellcheck stow-check

shellcheck:
	@bash -n $(SCRIPTS)
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck -x $(SCRIPTS); \
	else \
		echo "shellcheck not found; bash syntax check passed."; \
	fi

stow-check:
	stow --verbose --simulate --target=$(HOME) --restow $(PACKAGES)
