setlocal tw=79

let g:pymode_lint_on_write = 0
" let g:pymode_python = 'python3'
let g:pymode_rope = 0

" Override default IPDB to support Juypter notebook
let g:pymode_breakpoint_cmd = 'from IPython.core.debugger import Tracer; Tracer()()  # XXX BREAKPOINT'

let g:pymode_rope_goto_definition_bind = '<C-]>'
let g:pymode_breakpoint_bind = '<leader>B'

let g:deoplete#sources#jedi#show_docstring = 1

nnoremap <buffer> <F2> :PymodeLint<CR>
