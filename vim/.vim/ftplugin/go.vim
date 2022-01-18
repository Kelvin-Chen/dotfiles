let g:go_fmt_fail_silently = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_jump_to_error = 0
let g:go_fmt_command = 'goimports'

nmap <buffer> <F5> :GoRun<CR>
nmap <buffer> <F6> :GoTest<CR>
