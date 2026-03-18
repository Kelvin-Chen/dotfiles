return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = 'VeryLazy',
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = {
                    'bash',
                    'c',
                    'css',
                    'dockerfile',
                    'go',
                    'haskell',
                    'html',
                    'javascript',
                    'json',
                    'lua',
                    'markdown',
                    'python',
                    'ruby',
                    'rust',
                    'tsx',
                    'typescript',
                    'vim',
                    'vimdoc',
                    'yaml',
                },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },
}
