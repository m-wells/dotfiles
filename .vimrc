""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                          Plugins (using vim-plug)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("autocmd")
    augroup vimplug_install
        au!
        if empty(glob('~/.vim/autoload/plug.vim'))
            silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
            autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
        endif
    augroup END

    call plug#begin('~/.vim/plugged')
        Plug 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}
        Plug 'airblade/vim-gitgutter'
        Plug 'majutsushi/tagbar'
        Plug 'ludovicchabant/vim-gutentags'
        Plug 'scrooloose/nerdtree'
        Plug 'ryanoasis/vim-devicons'
        Plug 'shime/vim-livedown', {'do': 'npm install -g livedown'}
        Plug 'lervag/vimtex'
        Plug 'christoomey/vim-tmux-navigator'
        Plug 'aperezdc/vim-template', {'do': 'gem install licensee'}
        " Plug 'jpalardy/vim-slime'
        Plug 'altercation/vim-colors-solarized'
        Plug 'lifepillar/vim-solarized8'
        Plug 'honza/vim-snippets'
        function! DoCoc(info)
            if a:info.status == 'installed' || a:info.force
                :CocInstall coc-julia
                :CocInstall coc-snippets
            endif
        endfunction
        Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': function('DoCoc')}
        Plug 'godlygeek/tabular'
        Plug 'sheerun/vim-polyglot'
    call plug#end()
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                Vim Behavior
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set shell=/bin/bash

if has('mouse')
    set mouse=a                             " if terminal has mouse enable it
endif

if !has('nvim')
    set ttymouse=sgr
    set ttyfast
endif

if !isdirectory($HOME.'/.vim/backup')
    silent call mkdir ($HOME.'/.vim/backup', 'p')
endif
set backupdir=$HOME/.vim/backup//

if !isdirectory($HOME.'/.vim/swp')
    silent call mkdir ($HOME.'/.vim/swp', 'p')
endif
set directory=$HOME/.vim/swp//

if !isdirectory($HOME.'/.vim/undo')
    silent call mkdir ($HOME.'/.vim/undo', 'p')
endif
set undodir=$HOME/.vim/swp//

filetype plugin indent on
"set autoindent                  " Uses indent from previous line
"set smartindent                 " Like cindent except lil' more clever
"set copyindent                  " Copy the structure of existing line's indent when autoindetinng a new line.
syntax enable

if has("autocmd")
    augroup buffer_io
        au!
        " When vimrc is edited, reload it
        autocmd BufWritePost ~/.vimrc nested source %
        " When editing a file, always jump to the last known cursor position.
        " Don't do it when the position is invalid or when inside an event handler
        " (happens when dropping a file on gvim).
        " Also don't do it when the mark is in the first line, that is the default
        " position when opening a file.
        autocmd BufReadPost *
            \ if line("'\"") > 1 && line("'\"") <= line("$") |
            \   exe "normal! g`\"" |
            \ endif

        " autocmd FileType julia setlocal indentkeys-=),],}
        autocmd FileType tex setlocal spell spelllang=en_us

    augroup END

    autocmd BufEnter * :syntax sync fromstart
endif

set modeline                    " allow files to specify vim settings
set scrolloff=999               " keep cursor in the middle of the screen
set backspace=indent,eol,start  " allow backspacing over everything in insert mode
set whichwrap+=<,>,h,l,[,]      " allow cursor and h,l to go to next line

set wildmenu                    " vim command completion
" set ignorecase                  " ignore case when searching.
set smartcase                   " ignore case unless it's uppercase.
set incsearch                   " use incremental search

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                    TABS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set tabstop=4           " a tab is 4 spaces
set shiftwidth=4        " an indent is 4 spaces
set softtabstop=4       " insert 4 spaces when tab is pressed
set expandtab           " use spaces instead of tab
" allow toggling between virtual and default mode
function TabToggle()
    if &expandtab
        set shiftwidth=8
        set softtabstop=0
        set noexpandtab
    else
        set shiftwidth=4
        set softtabstop=4
        set expandtab
    endif
endfunction

nmap <F3> mz:execute TabToggle()<CR>'z


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                            Plugin Configuration
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plug 'aperezdc/vim-template'
if $NAME != ''
    let g:username = $NAME
endif
if $EMAIL != ''
    let g:email = $EMAIL
endif

" Plug 'powerline/powerline' -------------------------------------------------------------
try
    let g:powerline_pycmd = "py3"
endtry

" Plug 'scrooloose/nerdtree' -------------------------------------------------------------
if has("autocmd")
    autocmd BufEnter *
        \ if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) |
        \   q |
        \ endif
endif

" Plug 'shime/vim-livedown' --------------------------------------------------------------
" should markdown preview get shown automatically upon opening markdown buffer
let g:livedown_autorun = 1
" should the browser window pop-up upon previewing
let g:livedown_open = 1
" the port on which Livedown server will run
let g:livedown_port = 1337
" the browser to use, can also be firefox, chrome or other, depending on your executable
let g:livedown_browser = "vivaldi-stable --app=http://localhost:" . g:livedown_port

" Plug 'lervag/vimtex' -------------------------------------------------------------------
let g:vimtex_enabled = 1
let g:vimtex_view_method = 'zathura'

" Plug 'JuliaEditorSupport/julia-vim' ----------------------------------------------------
" set omnifunc=syntaxcomplete#Complete
" let g:default_julia_version = '1.0'
" let g:latex_to_unicode_suggestions = 0
" let g:latex_to_unicode_tab = 0
" let g:latex_to_unicode_auto = 0
" let g:latex_to_unicode_keymap = 0

" Plug 'majutsushi/tagbar' ---------------------------------------------------------------
let g:tagbar_type_julia = {
    \ 'ctagstype' : 'julia',
    \ 'kinds'     : ['t:struct', 'f:function', 'm:macro', 'c:const']
    \ }

" Plug 'neoclide/coc.nvim' ---------------------------------------------------------------
set updatetime=300
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=0

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Make <tab> used for trigger completion, completion confirm, snippet expand and jump like VSCode.
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
" inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" navigate pop up menu with TAB(to go down) and SHIFT-TAB (to go up)
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

let g:coc_snippet_next = '<tab>'
let g:coc_snippet_prev = '<s-tab>'

" Plug 'jpalardy/vim-slime' --------------------------------------------------------------
set splitbelow
set splitright
let g:slime_target = "vimterminal"

tmap <C-J> <C-W><C-J>
tmap <C-K> <C-W><C-K>
tmap <C-H> <C-W><C-H>
tmap <C-L> <C-W><C-L>
tmap <C-N> <C-W>N
" autocmd FileType julia let g:slime_vimterminal_cmd = "julia"

" Plug 'RRethy/vim-hexokinase' -----------------------------------------------------------
" let g:Hexokinase_optInPatterns = [
" \     'full_hex',
" \     'triple_hex',
" \     'rgb',
" \     'rgba',
" \     'hsl',
" \     'hsla'
" \ ]

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                               Vim Appearance
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" fallback colorscheme
try
    colorscheme desert
endtry

if $COLORTERM == 'truecolor' || has('gui_running')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
    set guioptions=d

    set hlsearch            " Highlight the last used search pattern
    set noruler             " show the cursor position all the time
    set cursorline          " highlight the current row
    set cursorcolumn        " highlight the current column
    set background=dark     " tell vim the bg is dark

    try | colorscheme solarized8 | catch | endtry
else
    try | colorscheme solarized | catch | endtry
endif

if &term =~ "rxvt-unicode" || &term =~ "alacritty"
    " pretty cursor setting
    let &t_SI = "\<Esc>[6 q"
    let &t_SR = "\<Esc>[4 q"
    let &t_EI = "\<Esc>[2 q"
endif

set laststatus=2            " Always display the statusline
set showtabline=1           " Only display the tabline when there are multiple tabs
set noshowmode              " Hide the default mode text (e.g. -- INSERT -- below the statusline)

set nowrap                  " no line wrap by default

set relativenumber          " show relative line numbers
set number                  " show line numbers

set novisualbell

set encoding=UTF-8                  " The encoding displayed.
set fileencoding=UTF-8              " The encoding written to file.

" share system clipboard
set clipboard^=unnamed,unnamedplus

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                Vim Mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Allow saving of files as sudo
ca w!! execute 'write !sudo /usr/bin/tee % >/dev/null' <bar> edit!

" set F2 to toggle the paste mode
set pastetoggle=<F2>

" let F4 toggle linewrap
map <F4> :setlocal wrap!<CR>
nmap <F5> :TagbarToggle<CR>
map <C-n> :NERDTreeToggle<CR>

let g:BASH_Ctrl_j = 'off'

" to use the <Alt> key we have to map things to <ESC>
" DO NOT USE <ESC> WITHOUT ANOTHER MODIFIER or commands may issue unexpectedly
" these behave like <Alt-Shift-H> and <Alt-Shift-J>
" nnoremap <ESC><S-H> :tabprevious<CR>
" nnoremap <ESC><S-L> :tabnext<CR>
" move a split to a new tab/page
" nnoremap <ESC><S-T> <C-W>T
" don't let <ESC> (<Alt>) mappings hang when returning to NORMAL mode from
" INSERT/VISUAL
" set noesckeys

" mimic NERDTree mappings
nnoremap <C-I> :split<CR>
nnoremap <C-S> :vsplit<CR>
nnoremap <C-Q> :quit<CR>

" make Y to be consistent with the C and D operators (yank to EOL)
nnoremap Y y$

" allow ; to act like :
nnoremap ; :

" natural movement with textwrap on
" k acts as gk in normal mode, but #k still jumps up # gutter lines
nnoremap <silent> k :<C-U>execute 'normal!' (v:count > 1 ? "m'" . v:count :'g') . 'k'<CR>
" j acts as gj in normal mode, but #j still jumps down # gutter lines
nnoremap <silent> j :<C-U>execute 'normal!' (v:count > 1 ? "m'" . v:count :'g') . 'j'<CR>

" nnoremap <C-[> :pop<CR>

" Alacritty uses Shift to bypass mouse capturing by applications like Vim (to click on links for example)
nnoremap <ScrollWheelUp> k
nnoremap <ScrollWheelDown> j
" move forward 1/2 a screen
nnoremap <A-ScrollWheelUp> <C-U>
" move back 1/2 a screen
nnoremap <A-ScrollWheelDown> <C-D>
" move forward one full screen
nnoremap <C-ScrollWheelUp> <C-B>
" move back one full screen
nnoremap <C-ScrollWheelDown> <C-F>

