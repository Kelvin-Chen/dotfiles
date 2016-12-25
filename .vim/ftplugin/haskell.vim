setl formatprg=hindent

let g:haskell_indent_disable = 1
let g:haskell_enable_quantification = 1
let g:haskell_enable_recursivedo = 1
let g:haskell_enable_arrowsyntax = 1
let g:haskell_enable_pattern_synonyms = 1
let g:haskell_enable_typeroles = 1
let g:haskell_enable_static_pointers = 1

nnoremap <buffer> <F1> :GhcModType<CR>
nnoremap <buffer> <F2> :GhcModTypeInsert<CR>
