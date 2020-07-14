" Switch syntax highlighting on
syntax on

" Specify a directory for plugins
" - Avoid using standard Vim directory names like 'plugins'
call plug#begin('~/.vim/plugged')

" Make backspace behave in a sane manner.	
set backspace=indent,eol,start

" Enable file type detection and do language-dependent indenting.
filetype plugin indent on

" Initialize plugin system
call plug#end()
