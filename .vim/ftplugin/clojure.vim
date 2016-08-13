let g:sexp_enable_insert_mode_mappings = 0
let g:clojure_fuzzy_indent_patterns = ['^with', 'def', '^let', '^reg-']
let g:clojure_special_indent_words = 'deftype,defrecord,reify,proxy,' .
			\ 'extend-type,extend-protocol,letfn,render,defprotocol'

let g:deoplete#keyword_patterns = {}
let g:deoplete#keyword_patterns.clojure = '[\w!$%&*+/:<=>?@\^_~\-\.]*'
