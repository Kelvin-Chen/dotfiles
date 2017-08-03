export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"

export LANG=en_US.UTF-8

# Set vi/vim/nvim as $EDITOR and $GIT_EDITOR
export EDITOR=vi
hash vim 2>/dev/null && {
    export EDITOR=vim
}
hash nvim 2>/dev/null && {
    export EDITOR=nvim
}
export GIT_EDITOR=$EDITOR

export PAGER=less

export NVM_LAZY_LOAD=false
