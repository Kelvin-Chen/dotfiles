-- Options
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.hlsearch = true
vim.opt.colorcolumn = '80'
-- Neovim detects truecolor support itself (COLORTERM, terminfo, and querying
-- the terminal). Only force it on; never force it off, so detection still works
-- where COLORTERM was not forwarded (ssh, sudo).
if vim.env.COLORTERM == 'truecolor' or vim.env.COLORTERM == '24bit' then
    vim.opt.termguicolors = true
end
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true

vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 250
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.modeline = true
vim.opt.laststatus = 3
vim.opt.mouse = 'a'

-- Keymaps
vim.keymap.set('n', ';', ':')
vim.keymap.set('n', '<leader>w', '<cmd>w!<cr>', { desc = 'Save' })
vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('i', 'kj', '<Esc>')
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<cr>')
vim.keymap.set('n', '<leader>cd', '<cmd>lcd %:p:h<cr>', { desc = 'cd to file dir' })

-- Window navigation (tmux-navigator overrides these)
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Tabs
vim.keymap.set('n', '<leader>tn', '<cmd>tabnew<cr>', { desc = 'New tab' })

-- Diagnostic keymaps ([d / ]d are built in since 0.11)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Diagnostic float' })

-- Disable unused providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- The plugin specs use 0.11+ APIs (vim.lsp.config, vim.uv). On older builds
-- (distro packages are often years behind) keep the options and keymaps above
-- and stop here rather than failing with a wall of errors.
if vim.fn.has('nvim-0.11') == 0 then
    vim.api.nvim_echo({ { 'nvim < 0.11: plugins disabled (see ~/.config/nvim/init.lua)', 'WarningMsg' } }, true, {})
    return
end
if vim.fn.executable('git') == 0 then
    vim.api.nvim_echo({ { 'git not found: plugins disabled', 'WarningMsg' } }, true, {})
    return
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        'git', 'clone', '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
vim.opt.rtp:append(vim.fn.stdpath('data') .. '/site')

require('lazy').setup('plugins', {
    rocks = { hererocks = false },
})
