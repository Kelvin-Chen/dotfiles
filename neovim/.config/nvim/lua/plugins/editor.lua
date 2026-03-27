return {
    {
        'kylechui/nvim-surround',
        event = 'VeryLazy',
        opts = {},
    },

    {
        'numToStr/Comment.nvim',
        event = 'VeryLazy',
        opts = {},
    },

    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        opts = {},
    },

    {
        'junegunn/vim-easy-align',
        event = 'VeryLazy',
        keys = {
            { 'ga', '<Plug>(EasyAlign)', mode = 'n', desc = 'Easy align' },
            { '<Enter>', '<Plug>(EasyAlign)', mode = 'v', desc = 'Easy align' },
        },
    },

    {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = 'markdown',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        opts = {},
    },

    {
        'folke/flash.nvim',
        event = 'VeryLazy',
        keys = {
            { 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' },
            { 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash treesitter' },
        },
    },
}
