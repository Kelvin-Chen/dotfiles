let &rtp = expand('~/.vim') . ',' . &rtp

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source "$HOME/.vimrc"
endif
call plug#begin('~/.vim/plugged')

" Plugins
Plug 'neovim/node-host', { 'do': 'npm install' }
Plug 'christoomey/vim-tmux-navigator'
Plug 'edkolev/tmuxline.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-git'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdcommenter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'jistr/vim-nerdtree-tabs'
Plug 'majutsushi/tagbar'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --gocode-completer' }
" Plug 'flazz/vim-colorschemes'
Plug 'frankier/neovim-colors-solarized-truecolor-only'
Plug 'Lokaltog/vim-easymotion'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'benekastah/neomake'
Plug 'Raimondi/delimitMate'
Plug 'terryma/vim-multiple-cursors'
Plug 'elzr/vim-json'
Plug 'lervag/vimtex'
Plug 'junegunn/vim-easy-align'
Plug 'fatih/vim-go'
Plug 'ekalinin/Dockerfile.vim'
Plug 'klen/python-mode'
Plug 'nginx.vim'
Plug 'plasticboy/vim-markdown'
Plug 'guns/vim-clojure-static'
Plug 'guns/vim-sexp'
Plug 'snoe/nvim-parinfer.js'
Plug 'tpope/vim-fireplace'
Plug 'JuliaLang/julia-vim'


" Fix weird issue where julia files have lisp syntax settings enabled.
autocmd BufRead,BufNewFile *.jl set filetype=julia

call plug#end()
filetype plugin indent on

" Map leaders
let mapleader=' '
let maplocalleader=' '

" Easier colon
:nnoremap ; :

" Allow vim to read modelines.
set modeline

" Convenience mappings
nmap <leader>w :w!<cr>
nmap <leader>pp :setlocal paste!<cr>
nmap <leader>cd :lcd %:p:h<cr>

" Treat long lines as break lines
noremap j gj
noremap k gk

" Move between windows more easily
if has('nvim')
    nmap <BS> <C-h>
endif
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l

" Vim airline settings
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" Fugitive mappings
nmap <leader>gc :Gcommit<cr>
nmap <leader>gd :Gdiff<cr>
nmap <leader>gs :Gstatus<cr>
nmap <leader>gp :Gpush<cr>

" CtrlP mappings
nmap <leader>f :CtrlP .<cr>
nmap <leader>b :CtrlPBuffer<cr>
let g:ctrlp_map = ''

" Easier tabs
nmap <leader>tn :tabnew
nmap <leader>te :tabedit

" Toggle Nerdtree
nmap <leader>n :NERDTreeToggle<cr>

" Toggle tagbar
nmap <leader>tb :TagbarToggle<cr>
let g:tagbar_autofocus = 1

" Easy-align mappings
vmap <Enter> <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" Display settings
syntax enable
set nu
set hlsearch
set colorcolumn=80

" Colorscheme
" set termguicolors
set background=dark
colorscheme solarized

" Disable backup
set noswapfile
set nowb
set nobackup

" Enable backspace
set backspace=indent,eol,start

" Indent/tabs
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set autoindent
set smartindent
set wrap

" Always show status bar
set laststatus=2

" Neomake options
autocmd! BufWritePost * Neomake
let g:neomake_open_list = 2
let g:neomake_error_sign = {
    \ 'text': '>>',
    \ 'texthl': 'ErrorMsg',
    \ }
let g:neomake_warning_sign = {
    \ 'text': '>>',
    \ 'texthl': 'ErrorMsg',
    \ }

" Let CtrlP ignore files in gitignore.
let g:ctrlp_user_command = [
    \ '.git',
    \ 'cd %s && git ls-files -co --exclude-standard'
    \ ]

" YouCompleteMe settings
let g:ycm_seed_identifiers_with_syntax = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_cache_omnifunc = 0
let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'

let delimitMate_expand_cr = 1

" Add space after comments delimeter.
let g:NERDSpaceDelims = 1

let g:tmuxline_powerline_separators = 0

let g:sexp_mappings = {
    \ 'sexp_round_head_wrap_element': '<LocalLeader>e(',
    \ 'sexp_round_tail_wrap_element': '<LocalLeader>e)',
    \ }

autocmd InsertEnter *.clj DelimitMateOff
