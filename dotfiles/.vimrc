set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Only the true one color theme https://github.com/tomasiser/vim-code-dark#installation
Plugin 'tomasiser/vim-code-dark'


" VIM-AIRLINE
" https://github.com/vim-airline/vim-airline
Plugin 'vim-airline/vim-airline'
" https://github.com/vim-airline/vim-airline-themes
Plugin 'vim-airline/vim-airline-themes'


Plugin 'dikiaap/minimalist'


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required (enables ~/.vim/ftplugin/language.vim to apply language specific configuration)
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line


" UNTIL HERE is a sample from https://github.com/VundleVim/Vundle.vim Vundle plugin manager


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""




" Make Vim more useful
set nocompatible
" Use the OS clipboard by default (on versions compiled with `+clipboard`)
set clipboard=unnamed
" Enhance command-line completion
set wildmenu
" Allow cursor keys in insert mode
set esckeys
" Allow backspace in insert mode
set backspace=indent,eol,start
" Optimize for fast terminal connections
set ttyfast
" Add the g flag to search/replace by default
set gdefault
" Use UTF-8 without BOM
set encoding=utf-8 nobomb
" Change mapleader
let mapleader=","
" Centralize backups, swapfiles and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
	set undodir=~/.vim/undo
endif

" Don’t create backups when editing files in certain directories
set backupskip=/tmp/*,/private/tmp/*

" Respect modeline in files
set modeline
set modelines=4
" Enable per-directory .vimrc files and disable unsafe commands in them
set exrc
set secure
" Enable line numbers
set number
" Enable syntax highlighting
syntax on
" Highlight current line
set cursorline
" Highlight searches
set hlsearch

hi Search ctermbg=LightYellow
" Ignore case of searches
set ignorecase
" Highlight dynamically as pattern is typed
set incsearch

" Enable mouse in all modes
set mouse=a
" Disable error bells
set noerrorbells
" Don’t reset cursor to start of line when moving around.
set nostartofline
" Show the cursor position
set ruler
" Don’t show the intro message when starting Vim
set shortmess=atI
" Show the current mode
set showmode

" Show the (partial) command as it’s being typed
set showcmd
" Use relative line numbers
if exists("&relativenumber")
	set relativenumber
	au BufReadPost * set relativenumber
endif
" Start scrolling three lines before the horizontal window border
set scrolloff=3

" Strip trailing whitespace (,ss)
function! StripWhitespace()
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	:%s/\s\+$//e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endfunction
noremap <leader>ss :call StripWhitespace()<CR>
" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Automatic commands
if has("autocmd")
	" Enable file type detection
	filetype on
	" Treat .json files as .js
	autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
	" Treat .md files as Markdown
	autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
endif



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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


" Don’t add empty newlines at the end of files
"set binary
"set noeol

" Make tabs as wide as two spaces
set tabstop=2
" Show “invisible” characters
"set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
"set list

"------continue cuz u did't finished: https://realpython.com/vim-and-python-a-match-made-in-heaven/#lets-make-an-ide 

" Set Yellow as search highlight color
" https://stackoverflow.com/questions/7103173/vim-how-to-change-the-highlight-color-for-search-hits-and-quickfix-selection
hi Search ctermbg=LightYellow
hi Search ctermfg=Red

" On pressing tab, insert 2 spaces
set expandtab " allows to replace the tabs by white spaces character

" This makes the backspace key treat the four spaces like a tab (so one backspace goes back a full 4 spaces).
set softtabstop=2 " makes the spaces feel like real tabs



" when indenting with '>', use 2 spaces width
set shiftwidth=2

set wrapmargin=2

" This sets vim clipboard size in lines from 50 default to 1000
" This is not required here cuz above is line to copy to clipboard instead to yank
" set viminfo='20,<1000,s1000

set autoindent " http://vimdoc.sourceforge.net/htmldoc/options.html#%27autoindent%27
set smartindent " http://vimdoc.sourceforge.net/htmldoc/options.html#%27smartindent%27



" Show the filename in the window titlebar
set title

" Set column separator at 80 chars
set colorcolumn=80
" Set column separator color
" hi is short for highlight
highlight ColorColumn ctermbg=lightcyan guibg=blue


""" Vim-airline statusbar
"
" Always show status line
set laststatus=2
" Edited g:airline_section_c variable (replaced: %f to %F),
" so edited file path is absolute
let airline_section_c = '%<%F%m %#__accent_red#%{airline#util#wrap(airline#parts#readonly(),0)}%#__restore__#%#__accent_bold#%#__restore__#%#__accent_bold#%#__restore__#'



"""""""""""""""""""""""""" INSTALATION """""""""""""""""""""""""""""""""""""""""

" Install Vundle
"git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim



" Install Plugins:
" * Launch vim and run :PluginInstall
" * To install from command line: 
"vim +PluginInstall +qall
