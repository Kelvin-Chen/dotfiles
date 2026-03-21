return {
    {
        'lewis6991/gitsigns.nvim',
        event = 'VeryLazy',
        opts = {
            on_attach = function(bufnr)
                local gs = require('gitsigns')
                local map = function(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                end
                map('n', ']h', gs.next_hunk, 'Next hunk')
                map('n', '[h', gs.prev_hunk, 'Prev hunk')
                map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
                map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
                map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, 'Blame line')
            end,
        },
    },

    {
        'tpope/vim-fugitive',
        cmd = 'Git',
        init = function()
            vim.api.nvim_create_autocmd('FileType', {
                pattern = 'fugitive',
                callback = function(ev)
                    vim.keymap.set('n', '<cr>', 'dv', { buffer = ev.buf, remap = true, desc = 'Diff file (vertical)' })
                end,
            })
        end,
        keys = {
            { '<leader>gc', '<cmd>Git commit<cr>', desc = 'Git commit' },
            { '<leader>gd', '<cmd>Gvdiffsplit<cr>', desc = 'Git diff' },
            { '<leader>gs', function() vim.cmd('topleft vertical Git') vim.cmd('vertical resize 40') end, desc = 'Git status' },
            { '<leader>gp', '<cmd>Git push<cr>', desc = 'Git push' },
        },
    },
}
