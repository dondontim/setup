" This file will be loaded for gvim after ~/.vimrc

" Use the VSCode Dark+ theme
set background=dark

" Below 3 lines are in case terminal app not supporting 256 colors
" https://github.com/tomasiser/vim-code-dark#3-terminal-support
set t_Co=256
set t_ut=
let g:codedark_term256=1

" Set more conservative (more identical as Dark+)
"let g:codedark_conservative = 1

colorscheme codedark

" Use 14pt Monaco
set guifont=Monaco:h14
" Don’t blink cursor in normal mode
set guicursor=n:blinkon0
" Better line-height
set linespace=8
