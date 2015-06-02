"vimrc configuration file by lilde90
"
""NeoBundle Scripts-----------------------------
if has('vim_starting')
  if &compatible
    set nocompatible               " Be iMproved
  endif

  " Required:
  set runtimepath+=/Users/lilde90/.vim/bundle/neobundle.vim/


endif

" Required:
call neobundle#begin(expand('/Users/lilde90/.vim/bundle'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" Add or remove your Bundles here:
NeoBundle 'Shougo/neosnippet.vim'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'ctrlpvim/ctrlp.vim'
NeoBundle 'flazz/vim-colorschemes'
NeoBundle 'scrooloose/syntastic'
" You can specify revision/branch/tag.
NeoBundle 'Shougo/vimshell', { 'rev' : '3787e5' }
NeoBundle 'rust-lang/rust.vim'

" Required:
call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck
"End NeoBundle Scripts-----------------------------
"colorschme setting: torte, murphy, desert, elflord, ron
syntax on             
colorscheme desert

set go=              
"autocmd InsertLeave * se nocul   
""autocmd InsertEnter * se cul    
"set ruler            
set novisualbell      
set vb
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ %{strftime(\"%d/%m/%y\ -\ %H:%M\")}    
set laststatus=1     
set foldenable       
set foldmethod=manual   
set nocompatible  

"set fonts
if (has("gui_running")) 
    set guifont=Bitstream\ Vera\ Sans\ Mono\ 14 
endif 

autocmd BufNewFile *.cpp,*.[ch],*.sh,*.java,*.idl,*.hpp exec ":call SetTitle()" 
func SetTitle() 
    if &filetype == 'sh' 
        call setline(1, "\# Copyright ".strftime("%Y")." lilde90. All Rights Reserved.") 
        call append(line("."), "\# Author: Pan Li (panli.me@gmail.com)") 
        call append(line(".")+1, "\#!/bin/bash") 
        call append(line(".")+2, "\#") 
    else
        call setline(1, "\/\/ Copyright ".strftime("%Y")." lilde90. All Rights Reserved.") 
        call append(line("."), "\/\/ Author: Pan Li (panli.me@gmail.com)") 
        call append(line(".")+1, "\/\/") 
    endif
    autocmd BufNewFile * normal G
endfunc 

"keybord stroke
"nmap <leader>w :w!<cr>
"nmap <leader>f :find<cr>
"
"map <C-A> ggVGY
"map! <C-A> <Esc>ggVGY
map <F12> gg=G
vmap <C-c> "+y
nnoremap <F2> :g/^\s*$/d<CR> 
nnoremap <C-F2> :vert diffsplit 
map <M-F2> :tabnew<CR>  
map <F3> :tabnew .<CR>  
map <C-F3> \be  
map <F5> :call CompileRunGcc()<CR>
func! CompileRunGcc()
    exec "w"
    if &filetype == 'c'
        exec "!g++ % -o %<"
        exec "! ./%<"
    elseif &filetype == 'cpp'
        exec "!g++ % -o %<"
        exec "! ./%<"
    elseif &filetype == 'java' 
        exec "!javac %" 
        exec "!java %<"
    elseif &filetype == 'sh'
        :!./%
    elseif &filetype == 'py'
        exec "!python %"
        exec "!tb
endfunc
"run gdb
map <F8> :call Rungdb()<CR>
func! Rungdb()
    exec "w"
    exec "!g++ % -g -o %<"
    exec "!gdb ./%<"
endfunc

set autoread
autocmd FileType c,cpp map <buffer> <leader><space> :w<cr>:make<cr>
set completeopt=preview,menu 
filetype plugin indent on
set clipboard+=unnamed 
set nobackup
set nocompatible
:set makeprg=g++\ -Wall\ \ %
set autowrite
set ruler                   
set magic                   
set guioptions-=T          
set guioptions-=m           
set foldcolumn=0
set foldmethod=indent 
set foldlevel=3 
set foldenable              
set confirm
set autoindent
set smartindent

set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4
set smarttab
set cindent

set number
set history=1000

set noswapfile

set hlsearch
set incsearch
set gdefault

set textwidth=100
"set colorcolumn=100
set laststatus=2
set cmdheight=2
set showcmd          

filetype on
filetype plugin on
filetype indent on
set viminfo+=!

set iskeyword+=_,$,@,%,#,-
set linespace=0
set wildmenu
set backspace=2
set whichwrap+=<,>,h,l
set mouse=a
set selection=exclusive
set selectmode=mouse,key
set report=0
set fillchars=vert:\ ,stl:\ ,stlnc:\
set showmatch
set matchtime=1
set scrolloff=3
au BufRead,BufNewFile *  setfiletype txt

:inoremap ( ()<ESC>i
:inoremap ) <c-r>=ClosePair(')')<CR>
":inoremap { {<CR>}<ESC>O
:inoremap } <c-r>=ClosePair('}')<CR>
:inoremap [ []<ESC>i
:inoremap ] <c-r>=ClosePair(']')<CR>

function! ClosePair(char)
    if getline('.')[col('.') - 1] == a:char
        return "\<Right>"
    else
        return a:char
    endif
endfunction

set completeopt=longest,menu

" tags setting
set tags+=~/code/tags
set tags+=~/github/tags
cs add ~/code/cscope.out ~/code/
cs add ~/github/cscope.out ~/github/

"NERD setting
let NERDChristmasTree=1
let NERDTreeAutoCenter=1
let NERDTreeBookmarksFile=$VIM.'\Data\NerdBookmarks.txt'
let NERDTreeMouseMode=2
let NERDTreeShowBookmarks=1
let NERDTreeShowFiles=1
let NERDTreeShowHidden=1
let NERDTreeShowLineNumbers=1
let NERDTreeWinPos='left'
let NERDTreeWinSize=25
nnoremap f :NERDTreeToggle
map <F7> :NERDTree<CR>  

"setting for Taglist
let Tlist_Auto_Open=0
let Tlist_Ctags_Cmd = '/usr/bin/ctags'
let Tlist_Use_Right_Window = 1
""let Tlist_Show_One_File = 2
let Tlist_Exit_OnlyWindow = 1
"global <c-]>
nmap <c-]> g<c-]>

"relative number configuration
function! NumberToggle()
    if(&relativenumber == 1)
        set number
    else
        set relativenumber
    endif
endfunc
:au FocusLost * :set number
:au FocusGained * :set relativenumber
autocmd InsertEnter * :set number
autocmd InsertLeave * :set relativenumber
nnoremap <C-n> :call NumberToggle()<cr>

"Disable arrow keys in normal mode
nmap <Left> <Nop>
nmap <Right> <Nop>
nmap <Up> <Nop>
nmap <Down> <Nop>

let OmniCpp_MayCompleteDot=1

"syntastic setting"
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
