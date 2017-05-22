setl sw=2

let g:haskell_enable_quantification = 1
let g:haskell_enable_recursivedo = 1
let g:haskell_enable_arrowsyntax = 1
let g:haskell_enable_pattern_synonyms = 1
let g:haskell_enable_typeroles = 1
let g:haskell_enable_static_pointers = 1

nnoremap <buffer> <leader>t :GhcModType<CR>
nnoremap <buffer> <leader>T :GhcModTypeClear<CR>
nnoremap <buffer> <F1> :GhcModTypeInsert<CR>
