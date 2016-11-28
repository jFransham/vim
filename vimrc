" Show numbers along the LHS of the file
set nu
" Put the 'Im' in 'Vim'
set nocompatible
set autoindent
" Shows incomplete normal-mode commands in bottom-right
set showcmd
" Fish-like autocomplete for ex mode
set wildmenu
set wildmode=list:longest,full
" Output format
set fileformat=unix
" Input formats (i.e. don't treat DOS files like Unix files)
set fileformats=unix,dos
" Prevents files being dropped when using -p
set tabpagemax=100
" noet = Hard tabs
" ci = See cinoptions, below
" sts,sw,ts = 4-space indentation, 4-space tabs, 4-space-equivalent shifting
set noet ci sts=4 sw=4 ts=4
" All automatic indents are 0 to prevent vim trying to be 'smart' when
" indenting
set cinoptions=(0,u0,U0
" Highlight search as we're typing
set incsearch
" Highlight all search results
set hlsearch
" Disabled hidden buffers, they're confusing and unintuitive
set nohidden
" Show tab names even when there is only one tab
set showtabline=2
" Force 256-color mode (this will be fun if I ever use a non-256 terminal)
set t_Co=256
" Always highlight the 81st column to remind me to keep lines short
set colorcolumn=81
" Show special whitespace
set list
" Replacement chars to use. '\ ' is just a literal space, extends is when a
" line is wider than the terminal
set listchars=tab:»\ ,trail:~,extends:>
" God save the queen
set spelllang=en_gb
" Use box-drawing vertical line instead of pipe (which is not full-height in
" some fonts)
set fillchars=vert:│
" Lowercase search = case-insensitive search, uppercase search =
" case-sensitive search
set smartcase
" All mouse powers: activate
set mouse=a
" Keep undos across executions of vim
set undofile
set undodir=$HOME/.vim/undo
set undolevels=1000
set undoreload=10000
" Use codex-generated tags as well as standard tags
set tags=tags;/,codex.tags;/
" Regular grep integrates poorly with vim by default, so don't check if
" ripgrep is installed first. Just let it explode
set grepprg=rg\ --vimgrep

" For bundle managers
filetype off
filetype plugin off

" Doesn't work well with tabula-rasa colorscheme, and MatchTagAlways gets the
" 90% of the required functionality
let g:rainbow_active = 0
let g:hoogle_search_count = 30

" By default, only .markdown files are detected. This is technically correct,
" but not de facto correct
autocmd BufNewFile,BufReadPost *.md setlocal filetype=markdown
" 2-space tabs for languages that I can get away with it
autocmd FileType html,html.*,css,markdown,haskell setlocal
			\ tabstop=2
			\ softtabstop=2
			\ expandtab
			\ shiftwidth=2
" Allow primes in <word>s, and use hscope instead of cscope
autocmd FileType haskell setlocal iskeyword=a-z,A-Z,_,48-57,39 cscopeprg=hscope
" Update ctags on file write
autocmd BufWritePost *.hs silent exec "!codex update>/dev/null&"

function! Strip(inp)
	return substitute(a:inp, '^\_s*\(.\{-}\)\_s*$', '\1', '')
endfunction

" Get selection in vimscript. Fucking nuts this isn't built in
function! FullSelection()
	return getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]-1]
endfunction

function! Translate(argstr)
	let a:args = split(a:argstr)
	let a:len = len(a:args)
	let a:target = a:len > 1 ? a:args[1] : a:args[0]
	let a:source = a:len > 1 ? a:args[0] : "en"
	let a:sel = FullSelection()
	let @@ =
		\ Strip(
			\ system(
				\ "trans" . " " .
				\ "-b" . " " .
				\ (a:source . ":" . a:target) . " " .
				\ shellescape(a:sel)
			\ )
		\ )
endfunction

command! -range -nargs=1 Trans :call Translate("<args>")

" Keep backslash available for search-related tasks
let mapleader=","
" Add handlebars to MatchTagAlways
let g:mta_filetypes = {
	\ 'html':1,
	\ 'xhtml':1,
	\ 'xml':1,
	\ 'jinja':1,
	\ 'html.handlebars':1
	\}

" Clear highlights
nnoremap <silent> \ :nohl<CR><C-l>:silent! GhcModTypeClear<CR>
" Autofill current directory when using capital E
nnoremap :E :e %:p:h/
nnoremap <silent> <C-e> :NERDTreeTabsToggle<CR>
nnoremap <silent> <Leader><C-e> :NERDTreeTabsOpen<CR><C-w><C-p>:NERDTreeTabsFind<CR>
nnoremap <silent> Y yy
nnoremap <silent> <Leader>s :source ~/.vim/vimrc<CR>
nnoremap <silent> <Leader>es :e ~/.vim/vimrc<CR>
nnoremap <C-@> @a
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-H> <C-W><C-H>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-\><C-h> :Hoogle <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-\><C-\> :grep! "\b<C-R>=expand("<cword>")<CR>\b" -t<C-R>=&ft<CR><CR>:cw<CR>
" Open current view as new tab
nnoremap <Leader>t <C-w>T
nnoremap <Leader>ht :GhcModType<CR>
nnoremap <Leader>hi :GhcModInfo<CR>
nnoremap <silent> <C-m><C-n> :tabm +1<CR>
nnoremap <silent> <C-m><C-p> :tabm -1<CR>
nnoremap <silent> <C-n> :tabnext<CR>
nnoremap <silent> <C-p> :tabprevious<CR>
nnoremap <silent> <C-t> :tabnew<CR>
nnoremap <silent> zj o<Esc>
nnoremap <silent> zk O<Esc>
nnoremap <silent> gl ggzz
nnoremap <silent> <Leader><Tab> >>
nnoremap <silent> <Leader><S-Tab> <<
nnoremap <silent> K kJ
nnoremap <silent> <Leader>/ :noh<CR>
vnoremap <silent> <Tab> >
vnoremap <silent> <S-Tab> <
vnoremap <C-\><C-h> :<C-w>Hoogle <C-R>=FullSelection()<CR><CR>
vnoremap <C-\><C-\> :<C-w>grep! "<C-R>=FullSelection()<CR>" -t<C-R>=&ft<CR><CR>:cw<CR>
" Allow C-d and C-u in insert mode
inoremap <silent> <C-d> <C-\><C-O><C-d>
inoremap <silent> <C-u> <C-\><C-O><C-u>
" Center view on search results
map N Nzz
map n nzz

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

Plugin 'vim-scripts/Smart-Tabs'
Plugin 'rust-lang/rust.vim'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
Plugin 'tomasr/molokai'
Plugin 'jFransham/tabula-rasa'
Plugin 'jtratner/vim-flavored-markdown'
Plugin 'kien/rainbow_parentheses.vim'
Plugin 'mustache/vim-mustache-handlebars'
Plugin 'groenewege/vim-less'
Plugin 'luochen1990/rainbow'
Plugin 'Valloric/MatchTagAlways'
Plugin 'joker1007/vim-ruby-heredoc-syntax'
Plugin 'kchmck/vim-coffee-script'
Plugin 'Shougo/vimproc.vim'
Plugin 'eagletmt/ghcmod-vim'
Plugin 'eagletmt/neco-ghc'
Plugin 'ervandew/supertab'
Plugin 'Twinside/vim-hoogle'
Plugin 'yegappan/grep'

call vundle#end()
filetype plugin indent on

" This has to be after `call vundle#end()`
colorscheme tabula-rasa
" colorscheme molokai
