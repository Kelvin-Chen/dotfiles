" Clojure: rely on Vim's bundled clojure syntax + indent.
" These two vars configure the BUILT-IN indenter ($VIMRUNTIME/indent/clojure.vim),
" not a plugin — they tune fuzzy/special-form indentation.
let g:clojure_fuzzy_indent_patterns = ['^with', 'def', '^let', '^reg-']
let g:clojure_special_indent_words = 'deftype,defrecord,reify,proxy,extend-type,extend-protocol,letfn,render,defprotocol'
