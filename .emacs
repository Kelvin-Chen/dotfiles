(require 'package)

;; My packages to install
(setq package-list '(evil
                     evil-surround
                     evil-nerd-commenter
                     autopair
                     flycheck
                     auto-complete
                     powerline
                     zenburn-theme
                     haskell-mode
                     ghc
                     flycheck-haskell
                     scala-mode2
                     js2-mode
                     auctex
                     go-mode
                     go-autocomplete))

;; Add package repos
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))

;; Initialize packages
(package-initialize)

;; Fetch List Of Available Packages
(unless package-archive-contents
  (package-refresh-contents))

;; Install missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

;; Don't use tab indent
(setq-default indent-tabs-mode nil)

;; Set width of tab to be 4 spaces
(setq-default tab-width 4)

;; Store emacs backup in ~/.saves
(setq backup-directory-alist '(("." . "~/.saves")))
(setq delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

;; Set color scheme
(load-theme 'zenburn t)

;; Add line numbers
(global-linum-mode t)
(setq linum-format " %d ")

;; Clean up whitespace on save
(add-hook 'before-save-hook 'whitespace-cleanup)

;; Set nerd-commenter hotkeys
(evilnc-default-hotkeys)

;; Map align-regexp command
(global-set-key (kbd "C-c a") 'align-regexp)

;; Add a vim emulator
(evil-mode t)

;; Enable autopair in all modes
(autopair-global-mode)

;; Set powerline theme
(powerline-default-theme)

;; Port of vim-surround
(global-evil-surround-mode t)

;; Enable flycheck
(add-hook 'after-init-hook #'global-flycheck-mode)

;; Enable auto-completion
(ac-config-default)

;; Haskell mode settings
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)

;; Enable ghc-mod
(autoload 'ghc-init "ghc" nil t)
(autoload 'ghc-debug "ghc" nil t)
(add-hook 'haskell-mode-hook (lambda () (ghc-init)))

;; Apply flycheck-haskell for better haskell syntax checking
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-haskell-setup))

;; Set LaTeX pdf mode
(setq TeX-PDF-mode t)

;; Spell check for LaTeX
(add-hook 'LaTeX-mode-hook 'turn-on-flyspell)

;; Js-2 mode
(autoload 'js2-mode "js2-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;; Go settings
(require 'go-autocomplete)
(require 'auto-complete-config)
(add-hook 'before-save-hook #'gofmt-before-save)
