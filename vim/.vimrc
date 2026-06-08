" ~/.vimrc — minimal, plugin-free fallback editor.
" neovim (~/.config/nvim) is the primary, full-featured editor.
" Pure vimscript, zero plugins; works out of the box on any stock vim.

" --- Runtime path (load stowed ~/.vim/ftplugin) ---
let &rtp = expand('~/.vim') . ',' . &rtp

" --- Filetype + syntax (built-in) ---
filetype plugin indent on
syntax enable

" Force julia filetype (.jl is otherwise mis-detected as lisp).
autocmd BufRead,BufNewFile *.jl set filetype=julia

" --- Leaders (MUST precede all <leader> mappings) ---
let mapleader=' '
let maplocalleader=' '

" --- Core keymaps (parity with neovim init.lua) ---
" Easier colon
nnoremap ; :
" Clear search highlight
nnoremap <Esc> :nohlsearch<CR>
" Save / paste-toggle / cd-to-file-dir
nnoremap <leader>w :w!<cr>
nnoremap <leader>pp :setlocal paste!<cr>
nnoremap <leader>cd :lcd %:p:h<cr>
" Insert-mode escape
inoremap jk <Esc>
inoremap kj <Esc>
" Treat long lines as break lines (normal-mode only, matches neovim)
nnoremap j gj
nnoremap k gk
" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
" Tabs
nnoremap <leader>tn :tabnew<cr>
nnoremap <leader>te :tabedit 

" --- File explorer (netrw, built-in) ---
nnoremap <leader>n :Explore<cr>

" --- Built-in fuzzy file find ---
set path+=**
set wildmenu
set wildmode=longest:full,full
nnoremap <leader>f :find 
nnoremap <leader>b :buffer 

" --- Display ---
set modeline
set number
set relativenumber
set hlsearch
set colorcolumn=80

" --- Search behavior (mirrors neovim) ---
set ignorecase
set smartcase

" --- Splits (mirrors neovim) ---
set splitright
set splitbelow

" --- Colorscheme (built-in, fallback-safe) ---
if has('termguicolors')
    set termguicolors
endif
silent! colorscheme habamax

" --- Statusline (built-in) ---
set laststatus=2
set statusline=%f\ %m%r%h%w%=%y\ %l:%c\ %p%%

" --- Backups off ---
set noswapfile
set nowritebackup
set nobackup

" --- Editing behavior ---
set backspace=indent,eol,start
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set autoindent
set smartindent
set wrap

" --- Esc-map terminal responsiveness ---
set ttimeout
set ttimeoutlen=10
