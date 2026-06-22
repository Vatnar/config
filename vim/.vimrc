" =========================
" .vimrc for VSCodeVim
" Mirrors keybinds from .ideavimrc
" =========================
"
" Requires in VSCode settings.json:
"   "vim.vimrc.enable": true
"   "vim.vimrc.path": "~/.vimrc"
"
" =========================
" Basic Settings
" =========================
set number
set relativenumber
set incsearch
set ignorecase
set smartcase
set hlsearch
set scrolloff=8
set cursorline
set showcmd
set showmode
let mapleader = " "

" =========================
" Custom Keymaps
" =========================
nnoremap <leader>mm :marks<CR>

" =========================
" Insert Mode Arrow Navigation
" =========================
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>

" =========================
" Leader Key Mappings
" =========================

" Build / Project
nnoremap <leader>bb :call VSCodeCallNotify('workbench.action.tasks.build')<CR>
nnoremap <leader>br :call VSCodeCallNotify('workbench.action.tasks.runTask')<CR>
nnoremap <leader>bd :call VSCodeCallNotify('workbench.action.debug.start')<CR>
nnoremap <leader>bor :call VSCodeCallNotify('workbench.action.tasks.runTask')<CR>
nnoremap <leader>bod :call VSCodeCallNotify('workbench.action.debug.selectandstart')<CR>

" File Management
nnoremap <leader>fn :call VSCodeCallNotify('explorer.newFile')<CR>
nnoremap <leader>fr :call VSCodeCallNotify('renameFile')<CR>
nnoremap <leader>fd :call VSCodeCallNotify('deleteFile')<CR>
nnoremap <leader>fs :call VSCodeCallNotify('workbench.action.files.saveAll')<CR>

" File Search / Navigation
nnoremap <leader>se :call VSCodeCallNotify('workbench.action.quickOpen')<CR>
nnoremap <leader>ss :call VSCodeCallNotify('workbench.action.findInFiles')<CR>
nnoremap <leader>sr :call VSCodeCallNotify('workbench.action.openRecent')<CR>
nnoremap <leader>so :call VSCodeCallNotify('workbench.action.gotoSymbol')<CR>

" Intention / Quick Fix
nnoremap <leader><leader> :call VSCodeCallNotify('editor.action.quickFix')<CR>

" Window / Editor Management
nnoremap <leader>ws :call VSCodeCallNotify('workbench.action.splitEditorDown')<CR>
nnoremap <leader>wd :call VSCodeCallNotify('workbench.action.splitEditorRight')<CR>
nnoremap <leader>ww :call VSCodeCallNotify('workbench.action.closeActiveEditor')<CR>
nnoremap <leader>p  :call VSCodeCallNotify('workbench.view.explorer')<CR>

" Visual-Mode File Ops
xnoremap <leader>fd :call VSCodeCallNotify('deleteFile')<CR>

" =========================
" Movement & Editing Enhancements
" =========================
nnoremap n nzzzv
nnoremap N Nzzzv

nnoremap <A-j> :m .+1<CR>
nnoremap <A-k> :m .-2<CR>
inoremap <A-j> <Esc>:m .+1<CR>gi
inoremap <A-k> <Esc>:m .-2<CR>gi
xnoremap <A-j> :m '>+1<CR>gv
xnoremap <A-k> :m '<-2<CR>gv

nnoremap J mzJ`z
xnoremap < <gv
xnoremap > >gv

" =========================
" Window Navigation
" =========================
nnoremap <leader>wh <C-w>h
nnoremap <leader>wj <C-w>j
nnoremap <leader>wk <C-w>k
nnoremap <leader>wl <C-w>l
nnoremap [B <C-w>W
nnoremap ]B <C-w>w

" =========================
" Symbol & Definition Navigation
" =========================
nnoremap gd :call VSCodeCallNotify('editor.action.revealDeclaration')<CR>
nnoremap gi :call VSCodeCallNotify('editor.action.goToImplementation')<CR>
nnoremap gr :call VSCodeCallNotify('editor.action.referenceSearch.trigger')<CR>
nnoremap gR :call VSCodeCallNotify('editor.action.goToTypeDefinition')<CR>
nnoremap K :call VSCodeCallNotify('editor.action.showHover')<CR>

" =========================
" Diagnostics
" =========================
nnoremap <leader>q :call VSCodeCallNotify('editor.action.showHover')<CR>
nnoremap <F3> :call VSCodeCallNotify('editor.action.marker.nextInFiles')<CR>
nnoremap <S-F3> :call VSCodeCallNotify('editor.action.marker.prevInFiles')<CR>

" =========================
" Refactoring
" =========================
nnoremap <leader>rr :call VSCodeCallNotify('editor.action.refactor')<CR>
nnoremap <leader>rn :call VSCodeCallNotify('editor.action.rename')<CR>
xnoremap <leader>rn :call VSCodeCallNotify('editor.action.rename')<CR>
nnoremap <leader>re :call VSCodeCallNotify('editor.action.refactor')<CR>
xnoremap <leader>re :call VSCodeCallNotify('editor.action.refactor')<CR>
xnoremap <leader>riv :call VSCodeCallNotify('editor.action.refactor')<CR>
xnoremap <leader>ric :call VSCodeCallNotify('editor.action.refactor')<CR>
xnoremap <leader>rif :call VSCodeCallNotify('editor.action.refactor')<CR>
xnoremap <leader>rip :call VSCodeCallNotify('editor.action.refactor')<CR>
nnoremap <leader>rg :call VSCodeCallNotify('editor.action.sourceAction')<CR>
xnoremap <leader>rg :call VSCodeCallNotify('editor.action.sourceAction')<CR>

" =========================
" Debugging
" =========================
nnoremap <leader>dr :call VSCodeCallNotify('workbench.action.debug.start')<CR>
nnoremap <leader>db :call VSCodeCallNotify('editor.debug.action.toggleBreakpoint')<CR>
nnoremap <leader>ds :call VSCodeCallNotify('workbench.action.debug.stepOver')<CR>
nnoremap <leader>di :call VSCodeCallNotify('workbench.action.debug.stepInto')<CR>
nnoremap <leader>do :call VSCodeCallNotify('workbench.action.debug.stepOut')<CR>
nnoremap <leader>dl :call VSCodeCallNotify('workbench.action.debug.runToCursor')<CR>
nnoremap <leader>drr :call VSCodeCallNotify('workbench.action.debug.restart')<CR>
nnoremap <leader>dw :call VSCodeCallNotify('workbench.view.debug')<CR>

" Debug F-keys (VSCode defaults already match)
" F5: Continue,  F10: Step Over,  F11: Step Into,  Shift+F11: Step Out
" F9: Toggle breakpoint

" =========================
" Bookmarks (requires alefragnani.Bookmarks extension)
" =========================
nnoremap <leader>mb :call VSCodeCallNotify('editor.action.bookmark.toggle')<CR>
nnoremap <leader>md :call VSCodeCallNotify('editor.action.bookmark.toggle')<CR>
nnoremap <leader>mn :call VSCodeCallNotify('editor.action.bookmark.next')<CR>
nnoremap <leader>mp :call VSCodeCallNotify('editor.action.bookmark.prev')<CR>
nnoremap <leader>ml :call VSCodeCallNotify('editor.action.bookmark.list')<CR>
nnoremap \ :call VSCodeCallNotify('editor.action.bookmark.next')<CR>
