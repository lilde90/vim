"vimrc configuration file by lilde90
"
"colorschme setting: torte, murphy, desert, elflord, ron
syntax on             
colorscheme desert

set go=              
"autocmd InsertLeave * se nocul   
""autocmd InsertEnter * se cul    
"set ruler            
set showcmd          
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
        call setline(1, "\# Copyright ".strftime("%Y")." Baidu Inc. All Rights Reserved.") 
        call append(line("."), "\# Author: Li Pan (lipan08@baidu.com)") 
        call append(line(".")+1, "\#!/bin/bash") 
        call append(line(".")+2, "\#") 
    else
        call setline(1, "\/\/ Copyright ".strftime("%Y")." Baidu Inc. All Rights Reserved.") 
        call append(line("."), "\/\/ Author: Li Pan (lipan08@baidu.com)") 
        call append(line(".")+1, "\/\/") 
    endif
    autocmd BufNewFile * normal G
endfunc 

"keybord stroke
nmap <leader>w :w!<cr>
nmap <leader>f :find<cr>

map <C-A> ggVGY
map! <C-A> <Esc>ggVGY
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
        exec "!python %<"
    endif
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
filetype plugin on
set clipboard+=unnamed 
set nobackup
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
set nocompatible
set noeb
set confirm
set autoindent
set cindent

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smarttab

set number
set history=1000

set nobackup
set noswapfile

set hlsearch
set incsearch
set gdefault

set laststatus=2
set cmdheight=2
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
set smartindent
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

filetype plugin indent on 
set completeopt=longest,menu

" tags setting
set tags+=~/dev/tags
set tags+=~/dev/usr_include.tags
cs add ~/dev/cscope.out ~/dev/

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
