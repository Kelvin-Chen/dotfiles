return {
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
        config = function()
            local telescope = require('telescope')
            telescope.setup({
                defaults = {
                    layout_strategy = 'horizontal',
                    layout_config = { prompt_position = 'top' },
                    sorting_strategy = 'ascending',
                    file_ignore_patterns = { '^%.git/' },
                },
            })
            telescope.load_extension('fzf')

            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>f', function()
                local git_root = vim.fn.systemlist('git rev-parse --show-toplevel 2>/dev/null')[1]
                builtin.find_files({ cwd = git_root or vim.fn.getcwd(), hidden = true })
            end, { desc = 'Find files' })
            vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Buffers' })
            vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Live grep' })
            vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Help tags' })
            vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Diagnostics' })
            vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = 'Resume search' })
        end,
    },

    {
        'stevearc/oil.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        keys = {
            { '<leader>n', '<cmd>Oil<cr>', desc = 'File explorer' },
            { '-', '<cmd>Oil<cr>', desc = 'File explorer' },
        },
        opts = {
            view_options = { show_hidden = true },
        },
    },

    {
        'christoomey/vim-tmux-navigator',
        event = 'VeryLazy',
    },
}
