" vimrc configuration file by lilde90

syntax on
filetype plugin indent on

colorscheme desert
" 让文本背景透明
highlight Normal ctermbg=NONE guibg=NONE
highlight NonText ctermbg=NONE guibg=NONE
highlight LineNr ctermbg=NONE guibg=NONE
highlight SignColumn ctermbg=NONE guibg=NONE

set novisualbell
set vb
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ %{strftime(\"%d/%m/%y\ -\ %H:%M\")}
set laststatus=2
set cmdheight=2
set showcmd
set ruler
set number
set relativenumber
set scrolloff=3
set textwidth=100
set wildmenu

set autoread
set autowrite
set confirm
set history=1000
set magic
set backspace=indent,eol,start
set whichwrap+=<,>,h,l
set mouse=a
set report=0

set autoindent
set smartindent
set cindent

set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smarttab

set hlsearch
set incsearch
set showmatch
set matchtime=1

set foldmethod=indent
set foldlevel=3
set foldcolumn=0
set foldenable

set completeopt=menu,longest
set iskeyword+=_,$,@,%,#

set nobackup
set noswapfile

" Clipboard integration for macOS/Linux
if has('unnamedplus')
  set clipboard=unnamedplus,unnamed
elseif has('clipboard')
  set clipboard=unnamed
endif

function! s:EchoError(message) abort
  echohl ErrorMsg
  echom a:message
  echohl None
endfunction

function! s:ClosePair(char) abort
  if col('.') <= len(getline('.')) && getline('.')[col('.') - 1] ==# a:char
    return "\<Right>"
  endif
  return a:char
endfunction

function! SetTitle() abort
  if line('$') > 1 || getline(1) !=# ''
    return
  endif

  if &filetype ==# 'sh'
    call setline(1, '#!/usr/bin/env bash')
    call append(1, '# Copyright ' . strftime('%Y') . ' lilde90. All Rights Reserved.')
    call append(2, '# Author: Pan Li (panli.me@gmail.com)')
    call append(3, '#')
  else
    call setline(1, '// Copyright ' . strftime('%Y') . ' lilde90. All Rights Reserved.')
    call append(1, '// Author: Pan Li (panli.me@gmail.com)')
    call append(2, '//')
  endif

  normal! G
endfunction

function! CompileRunGcc() abort
  write

  let l:file = expand('%:p')
  let l:binary = expand('%:p:r')

  if &filetype ==# 'c'
    execute '!cc -Wall ' . shellescape(l:file) . ' -o ' . shellescape(l:binary)
    execute '!' . shellescape(l:binary)
  elseif &filetype ==# 'cpp'
    execute '!c++ -Wall ' . shellescape(l:file) . ' -o ' . shellescape(l:binary)
    execute '!' . shellescape(l:binary)
  elseif &filetype ==# 'java'
    execute '!javac ' . shellescape(l:file)
    execute '!java -cp ' . shellescape(expand('%:p:h')) . ' ' . expand('%:t:r')
  elseif &filetype ==# 'sh'
    execute '!bash ' . shellescape(l:file)
  elseif &filetype ==# 'py'
    if executable('python3')
      execute '!python3 ' . shellescape(l:file)
    elseif executable('python')
      execute '!python ' . shellescape(l:file)
    else
      call s:EchoError('No python interpreter found (python3/python).')
    endif
  else
    call s:EchoError('CompileRunGcc() does not support filetype: ' . &filetype)
  endif
endfunction

function! RunGdb() abort
  write

  let l:file = expand('%:p')
  let l:binary = expand('%:p:r')
  let l:compiler = &filetype ==# 'c' ? 'cc' : 'c++'

  execute '!' . l:compiler . ' -g ' . shellescape(l:file) . ' -o ' . shellescape(l:binary)
  execute '!gdb ' . shellescape(l:binary)
endfunction

function! NumberToggle() abort
  if &relativenumber
    set norelativenumber
  else
    set relativenumber
  endif
endfunction

function! s:FindSupportedCtags() abort
  for l:cmd in ['ctags', 'uctags', 'universal-ctags', 'exuberant-ctags']
    if !executable(l:cmd)
      continue
    endif

    let l:version = join(systemlist(shellescape(exepath(l:cmd)) . ' --version'), "\n")
    if l:version =~? 'Universal Ctags\|Exuberant Ctags'
      return exepath(l:cmd)
    endif
  endfor

  return ''
endfunction

function! s:AddTags(path) abort
  let l:path = expand(a:path)
  if filereadable(l:path)
    execute 'set tags+=' . fnameescape(l:path)
  endif
endfunction

function! s:AddCscope(db, root) abort
  let l:db = expand(a:db)
  let l:root = expand(a:root)

  if has('cscope') && filereadable(l:db) && isdirectory(l:root)
    execute 'silent! cs add ' . fnameescape(l:db) . ' ' . fnameescape(l:root)
  endif
endfunction

augroup lilde90_filetypes
  autocmd!
  autocmd BufRead,BufNewFile * if &filetype ==# '' | setfiletype text | endif
  autocmd BufNewFile *.c,*.h,*.cpp,*.hpp,*.sh,*.java,*.idl call SetTitle()
  autocmd FileType c setlocal makeprg=cc\ -Wall\ %:S\ -o\ %<:S
  autocmd FileType cpp setlocal makeprg=c++\ -Wall\ %:S\ -o\ %<:S
  autocmd FileType c,cpp nnoremap <buffer> <leader><Space> :write<CR>:make<CR>
augroup END

augroup lilde90_numbers
  autocmd!
  autocmd FocusLost,InsertEnter * set norelativenumber
  autocmd FocusGained,InsertLeave * set relativenumber
augroup END

nnoremap <F12> gg=G
if has('clipboard')
  vnoremap <C-c> "+y
endif
nnoremap <F2> :g/^\s*$/d<CR>
nnoremap <C-F2> :vert diffsplit<Space>
nnoremap <M-F2> :tabnew<CR>
nnoremap <F3> :tabnew .<CR>
nnoremap <C-F3> <Leader>be
nnoremap <F5> :call CompileRunGcc()<CR>
nnoremap <F7> :NERDTree<CR>
nnoremap <F8> :call RunGdb()<CR>
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <C-n> :call NumberToggle()<CR>

inoremap ( ()<Left>
inoremap <expr> ) <SID>ClosePair(')')
inoremap [ []<Left>
inoremap <expr> ] <SID>ClosePair(']')
inoremap <expr> } <SID>ClosePair('}')

nnoremap <Left> <Nop>
nnoremap <Right> <Nop>
nnoremap <Up> <Nop>
nnoremap <Down> <Nop>

call s:AddTags('~/code/tags')
call s:AddTags('~/github/tags')
call s:AddCscope('~/code/cscope.out', '~/code')
call s:AddCscope('~/github/cscope.out', '~/github')

let g:NERDChristmasTree = 1
let g:NERDTreeAutoCenter = 1
let g:NERDTreeBookmarksFile = expand('~/.vim/.NERDTreeBookmarks')
let g:NERDTreeMouseMode = 2
let g:NERDTreeShowBookmarks = 1
let g:NERDTreeShowFiles = 1
let g:NERDTreeShowHidden = 1
let g:NERDTreeShowLineNumbers = 1
let g:NERDTreeWinPos = 'left'
let g:NERDTreeWinSize = 25

let g:Tlist_Auto_Open = 0
let g:Tlist_Use_Right_Window = 1
let g:Tlist_Exit_OnlyWindow = 1

let s:ctags_cmd = s:FindSupportedCtags()
if !empty(s:ctags_cmd)
  let g:Tlist_Ctags_Cmd = s:ctags_cmd
else
  let loaded_taglist = 1
endif

nnoremap <C-]> g<C-]>
let OmniCpp_MayCompleteDot = 1
