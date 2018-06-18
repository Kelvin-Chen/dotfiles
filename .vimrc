let &rtp = expand('~/.vim') . ',' . &rtp

" Use system Python for Neovim
let g:python_host_prog = '/usr/bin/python2'
let g:python3_host_prog = '/usr/bin/python3'

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source "$HOME/.vimrc"
endif
call plug#begin('~/.vim/plugged')

function! DoRemote(arg)
    UpdateRemotePlugins
endfunction

function! SetupParinfer(arg)
    !lein npm install
    UpdateRemotePlugins
endfunction

" Plugins
Plug 'airblade/vim-gitgutter'
Plug 'benekastah/neomake'
Plug 'carlitux/deoplete-ternjs'
Plug 'christoomey/vim-tmux-navigator'
Plug 'clojure-vim/async-clj-omni'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'edkolev/tmuxline.vim'
Plug 'ekalinin/Dockerfile.vim'
Plug 'elzr/vim-json'
Plug 'fatih/vim-go'
Plug 'chriskempson/base16-vim'
Plug 'guns/vim-clojure-static'
Plug 'guns/vim-sexp'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'JuliaLang/julia-vim'
Plug 'junegunn/vim-easy-align'
Plug 'lervag/vimtex'
Plug 'Lokaltog/vim-easymotion'
Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle'}
Plug 'mxw/vim-jsx'
Plug 'neovimhaskell/haskell-vim'
Plug 'pangloss/vim-javascript'
Plug 'plasticboy/vim-markdown'
Plug 'python-mode/python-mode'
Plug 'Raimondi/delimitMate'
Plug 'sbdchd/neoformat'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'snoe/nvim-parinfer.js', { 'do': function('SetupParinfer') }
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-fireplace'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'zchee/deoplete-jedi'
Plug 'chase/vim-ansible-yaml'
Plug 'vim-scripts/haproxy'
Plug 'benjie/neomake-local-eslint.vim'
Plug 'chr4/nginx.vim'

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
if has('nvim')
    set termguicolors
endif
set background=dark
colorscheme base16-default-dark

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
nnoremap <F2> :Neomake<CR>

" Run Neoformat on save and trim trailing whitespace
" augroup fmt
    " autocmd!
    " autocmd BufWritePre * Neoformat
" augroup END<Paste>
let g:neoformat_basic_format_trim = 1
nnoremap <F3> :Neoformat<CR>

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

" Deoplete settings
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_smart_case = 1
inoremap <silent><expr> <S-Tab>
            \ pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <silent><expr> <Tab>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<Tab>" :
            \ deoplete#mappings#manual_complete()
function! s:check_back_space() abort "{{{
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction"}}}

" Fix multiple-cursors and deoplete conflict
func! Multiple_cursors_before()
    call deoplete#init#_disable()
endfunc
func! Multiple_cursors_after()
    call deoplete#init#_enable()
endfunc

let delimitMate_expand_cr = 1

" Add space after comments delimeter.
let g:NERDSpaceDelims = 1

let g:tmuxline_powerline_separators = 1

let g:sexp_mappings = {
    \ 'sexp_round_head_wrap_element': '<LocalLeader>e(',
    \ 'sexp_round_tail_wrap_element': '<LocalLeader>e)',
    \ }

autocmd InsertEnter *.clj DelimitMateOff
