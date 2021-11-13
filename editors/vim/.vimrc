" Set compatibility to Vim only.
set nocompatible
set nolist
set rnu
set noesckeys
" Helps force plug-ins to load correctly when it is turned back on below.
filetype off

" Turn on syntax highlighting.
syntax on

" For plug-ins to load correctly.
filetype plugin indent on

" Turn off modelines
set modelines=0

" show invisible characters
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_

" Automatically wrap text that extends beyond the screen length.
set linebreak
" Vim's auto indentation feature does not work properly with text copied from outside of Vim. Press the <F2> key to toggle paste mode on/off.
nnoremap <F2> :set invpaste paste?<CR>
imap <F2> <C-O>:set invpaste paste?<CR>
set pastetoggle=<F2>

" When closing an unsaved file move it to a buffer
set hidden

" Uncomment below to set the max textwidth. Use a value corresponding to the width of your screen.
set textwidth=100
set formatoptions=tcqrn1
set tabstop=2
set shiftwidth=2
set nospell
set softtabstop=2
set expandtab
set noshiftround
set noerrorbells
set smartindent
set noswapfile
set nobackup

" set up undoing behaviour
set undodir=~/.vim/undodir
set undofile
set undolevels=10000
" copy indentation from current line to the new line
set autoindent
" set indentation level based on filetype
filetype plugin indent on
" Display 5 lines above/below the cursor when scrolling with a mouse.
set scrolloff=5
" Fixes common backspace problems
set backspace=indent,eol,start

" Speed up scrolling in Vim
set ttyfast

" enable hardtime mode. Stop repeating keys
" let g:hardtime_default_on = 1
" allow jj but not jjj
" let g:hardtime_maxcount = 2
" Status bar
set laststatus=2

" Display options
set showmode
set showcmd

" Highlight matching pairs of brackets. Use the '%' character to jump between them.
set matchpairs+=<:>

" Show line numbers
set number

" Set status line display
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ [BUFFER=%n]\ %{strftime('%c')}

" Encoding
set encoding=utf-8

" Highlight matching search patterns
set hlsearch
" Enable incremental search
set incsearch
" Include matching uppercase words with lowercase search term
set ignorecase
" Include only uppercase words with uppercase search term
set smartcase

set foldmethod=syntax
set nofoldenable
" Store info from no more than 100 files at a time, 9999 lines of text, 100kb of data. Useful for copying large amounts of data between files.
set viminfo='100,<9999,s100

if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif

autocmd BufWinEnter *.* silent loadview"
let mapleader = " "
noremap <leader>w :w<cr>
noremap <leader>gs :CocSearch
noremap <leader>p :Files<cr>
noremap <leader>b :Buffers<cr>
noremap <leader>f :Rg<cr>
noremap <leader>g :ALEFix<cr>

noremap <leader><cr> <cr><c-w>h:q<cr>
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

if empty(glob('~/.vim/autoload/plug.vim'))
    silent execute "!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
      autocmd VimEnter * PlugInstall | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')
Plug 'gruvbox-community/gruvbox'
Plug 'dense-analysis/ale'
Plug 'https://github.com/adelarsq/vim-matchit'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'leafgarland/typescript-vim' " TypeScript syntax
Plug 'maxmellon/vim-jsx-pretty'
Plug 'neoclide/coc.nvim' , { 'branch' : 'release' }
Plug 'pangloss/vim-javascript'    " JavaScript support
Plug 'preservim/nerdtree'
Plug 'shime/vim-livedown'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'vim-ruby/vim-ruby'
Plug 'kana/vim-textobj-user'
Plug 'nelstrom/vim-textobj-rubyblock'
Plug 'vim-airline/vim-airline'
Plug 'preservim/nerdtree'
Plug 'jesseleite/vim-noh'
Plug 'rakr/vim-one'
call plug#end()

"Credit joshdick
"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif

colorscheme one
set background=dark
function! s:check_back_space() abort
    let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~ '\s'
endfunction
inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)


autocmd CursorHold * silent call CocActionAsync('highlight')

nmap <leader>rn <Plug>(coc-rename)

xmap <leader>c  <Plug>(coc-codeaction-selected)
nmap <leader>c  <Plug>(coc-codeaction-selected)

let g:coc_global_extensions = [ 'coc-tsserver' , 'coc-solargraph']
let g:ale_linters = {'ruby': ['standardrb']}
let g:ale_fixers = {'ruby': ['standardrb'], 'javascript': ['prettier']}
let g:ale_fix_on_save = 0
let g:airline_powerline_fonts = 1
let g:airline_theme='one'
let g:UltiSnipsExpandTrigger = "<nop>"
let g:ale_linters_explicit = 1
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" go markdown shorthand for markdown edit
nmap gm :LivedownToggle

nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>

" select last pasted text
nnoremap <expr> gb '`[' . strpart(getregtype(), 0, 1) . '`]'

" NERDTree plugin remaps
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <leader>t :NERDTreeFind<CR>

" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif

:imap ii <Esc>
packadd! matchit
silent! helptags ALL
" Enable % to be used in every ruby keyword
runtime macros/matchit.vim
