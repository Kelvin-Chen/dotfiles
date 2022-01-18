let &rtp = expand('~/.vim') . ',' . &rtp

" Use system Python for Neovim
let g:python_host_prog = '/usr/local/bin/python2'
let g:python3_host_prog = '/usr/local/bin/python3'

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source "$HOME/.vimrc"
endif
call plug#begin('~/.vim/plugged')

function! DoRemote(arg)
    UpdateRemotePlugins
endfunction

" UX Plugins
Plug 'airblade/vim-gitgutter'
Plug 'christoomey/vim-tmux-navigator'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'edkolev/tmuxline.vim'
Plug 'junegunn/vim-easy-align'
Plug 'Lokaltog/vim-easymotion'
Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle'}
Plug 'Raimondi/delimitMate'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'w0rp/ale'

" UI Plugins
Plug 'chriskempson/base16-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Language Plugins
Plug 'chr4/nginx.vim'
Plug 'clojure-vim/async-clj-omni'
Plug 'ekalinin/Dockerfile.vim'
Plug 'elzr/vim-json'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'fatih/vim-go'
Plug 'guns/vim-clojure-static'
Plug 'guns/vim-sexp'
Plug 'JuliaLang/julia-vim'
Plug 'lervag/vimtex'
Plug 'mxw/vim-jsx'
Plug 'neovimhaskell/haskell-vim'
Plug 'pangloss/vim-javascript'
Plug 'plasticboy/vim-markdown'
Plug 'python-mode/python-mode'
Plug 'tpope/vim-fireplace'
Plug 'tpope/vim-git'
Plug 'vim-ruby/vim-ruby'
Plug 'vim-scripts/haproxy'


" Fix weird issue where julia files have lisp syntax settings enabled.
autocmd BufRead,BufNewFile *.jl set filetype=julia

call plug#end()

filetype plugin indent on

" Map leaders
let mapleader=' '
let maplocalleader=' '

" Easier colon
nnoremap ; :

" Allow vim to read modelines.
set modeline

" Convenience mappings
nmap <leader>w :w!<cr>
nmap <leader>pp :setlocal paste!<cr>
nmap <leader>cd :lcd %:p:h<cr>
inoremap jk <Esc>
inoremap kj <Esc>

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
let g:airline#extensions#tagbar#enabled = 0
let g:airline#extensions#tmuxline#enabled = 0

" Tmuxline settings
let g:tmuxline_powerline_separators = 1
let g:tmuxline_theme = 'vim_statusline_3'

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
if filereadable(expand("~/.vimrc_background"))
    let base16colorspace=256
    source ~/.vimrc_background
endif

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

" Let CtrlP ignore files in gitignore.
let g:ctrlp_user_command = [
    \ '.git',
    \ 'cd %s && git ls-files -co --exclude-standard'
    \ ]

" Bind C-Space to omnicomplete
inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
            \ "\<lt>C-n>" :
            \ "\<lt>C-x>\<lt>C-o><c-r>=pumvisible() ?" .
            \ "\"\\<lt>c-n>\\<lt>c-p>\\<lt>c-n>\" :" .
            \ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"
imap <C-@> <C-Space>

let delimitMate_expand_cr = 1

" Add space after comments delimeter.
let g:NERDSpaceDelims = 1

let g:sexp_mappings = {
    \ 'sexp_round_head_wrap_element': '<LocalLeader>e(',
    \ 'sexp_round_tail_wrap_element': '<LocalLeader>e)',
    \ }

" Turn off delimitmate for clojure
autocmd InsertEnter *.clj DelimitMateOff

" vim-ale settings
nnoremap <C-]> :ALEGoToDefinitionInTab<cr>
nnoremap <S-k> :ALEHover<cr>
let g:ale_completion_enabled = 1
let g:ale_set_highlights = 0
let g:ale_fixers = {
            \ 'ruby': ['rubocop'],
            \ 'typescript': ['tslint']
            \ }
set completeopt=menu,menuone,preview,noselect,noinsert
