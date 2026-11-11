return {
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
        -- Loaded on first use (~6ms otherwise spent on every startup).
        cmd = 'Telescope',
        keys = {
            {
                '<leader>f',
                function()
                    local git_root = vim.fn.systemlist('git rev-parse --show-toplevel 2>/dev/null')[1]
                    require('telescope.builtin').find_files({ cwd = git_root or vim.fn.getcwd(), hidden = true })
                end,
                desc = 'Find files',
            },
            { '<leader>b', function() require('telescope.builtin').buffers() end, desc = 'Buffers' },
            { '<leader>sg', function() require('telescope.builtin').live_grep() end, desc = 'Live grep' },
            { '<leader>sh', function() require('telescope.builtin').help_tags() end, desc = 'Help tags' },
            { '<leader>sd', function() require('telescope.builtin').diagnostics() end, desc = 'Diagnostics' },
            { '<leader>sr', function() require('telescope.builtin').resume() end, desc = 'Resume search' },
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
            -- fzf-native needs `make` + a C compiler; fall back to the Lua sorter.
            pcall(telescope.load_extension, 'fzf')
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
