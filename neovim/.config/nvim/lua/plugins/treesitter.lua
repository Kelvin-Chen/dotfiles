local parsers = {
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
}

return {
    {
        -- The `main` branch is a rewrite: it does not lazy-load, `setup()` no
        -- longer accepts `ensure_installed`, and highlighting is not enabled
        -- for you. Parsers are installed explicitly and started per buffer.
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        build = ':TSUpdate',
        lazy = false,
        config = function()
            -- Compiling parsers needs the tree-sitter CLI and a C compiler.
            -- Without them, skip quietly and keep regex syntax highlighting.
            if vim.fn.executable('tree-sitter') == 1 then
                require('nvim-treesitter').install(parsers)
            end

            vim.api.nvim_create_autocmd('FileType', {
                callback = function(ev)
                    -- Fails (harmlessly) when no parser exists for the filetype.
                    pcall(vim.treesitter.start, ev.buf)
                end,
            })
        end,
    },
}
