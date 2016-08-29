if !exists('g:config_vim_gui_label')
	let g:config_vim_gui_label = 0
endif



" make tabline in terminal mode
function! Vim_NeatTabLine()
	let s = ''
	for i in range(tabpagenr('$'))
		" select the highlighting
		if i + 1 == tabpagenr()
			let s .= '%#TabLineSel#'
		else
			let s .= '%#TabLine#'
		endif

		" set the tab page number (for mouse clicks)
		let s .= '%' . (i + 1) . 'T'

		" the label is made by MyTabLabel()
		let s .= ' %{Vim_NeatTabLabel(' . (i + 1) . ')} '
	endfor

	" after the last tab fill with TabLineFill and reset tab page nr
	let s .= '%#TabLineFill#%T'

	" right-align the label to close the current tab page
	if tabpagenr('$') > 1
		let s .= '%=%#TabLine#%999XX'
	endif

	return s
endfunc

" get a single tab name 
function! Vim_NeatBuffer(bufnr, fullname)
	let l:name = bufname(a:bufnr)
	if getbufvar(a:bufnr, '&modifiable')
		if l:name == ''
			return '[No Name]'
		else
			if a:fullname 
				return fnamemodify(l:name, ':p')
			else
				return fnamemodify(l:name, ':t')
			endif
		endif
	else
		let l:buftype = getbufvar(a:bufnr, '&buftype')
		if l:buftype == 'quickfix'
			return '[Quickfix]'
		elseif l:name != ''
			if a:fullname 
				return '-'.fnamemodify(l:name, ':p')
			else
				return '-'.fnamemodify(l:name, ':t')
			endif
		else
		endif
		return '[No Name]'
	endif
endfunc

" get a single tab label
function! Vim_NeatTabLabel(n)
	let l:buflist = tabpagebuflist(a:n)
	let l:winnr = tabpagewinnr(a:n)
	let l:bufnr = l:buflist[l:winnr - 1]
	return Vim_NeatBuffer(l:bufnr, 0)
endfunc


" get a single tab label in gui
function! Vim_NeatGuiTabLabel()
	let l:num = v:lnum
	let l:buflist = tabpagebuflist(l:num)
	let l:winnr = tabpagewinnr(l:num)
	let l:bufnr = l:buflist[l:winnr - 1]
	let l:fname = Vim_NeatBuffer(l:bufnr, 0)
	if g:config_vim_gui_label == 0
		return l:fname
	elseif g:config_vim_gui_label == 1
		return "[".l:num."] ".l:fname
	elseif g:config_vim_gui_label == 2
		return "".l:num." - ".l:fname
	endif
	if getbufvar(l:bufnr, '&modified')
		return "[".l:num."] ".l:fname." +"
	endif
	return "[".l:num."] ".l:fname
endfunc

" get a label tips
function! Vim_NeatGuiTabTip()
	let tip = ''
	let bufnrlist = tabpagebuflist(v:lnum)
	for bufnr in bufnrlist
		" separate buffer entries
		if tip != ''
			let tip .= " \n"
		endif
		" Add name of buffer
		let name = Vim_NeatBuffer(bufnr, 1)
		let tip .= name
		" add modified/modifiable flags
		if getbufvar(bufnr, "&modified")
			let tip .= ' [+]'
		endif
		if getbufvar(bufnr, "&modifiable")==0
			let tip .= ' [-]'
		endif
	endfor
	return tip
endfunc

" setup new tabline, just %M%t in macvim
set tabline=%!Vim_NeatTabLine()
set guitablabel=%{Vim_NeatGuiTabLabel()}
set guitabtooltip=%{Vim_NeatGuiTabTip()}




function! Python_InitTab()
	setlocal tabstop=4
	setlocal softtabstop=4
	setlocal shiftwidth=4
	setlocal noexpandtab
endfunc

if has('autocmd')
	filetype plugin indent on
	autocmd! BufNewFile,BufRead *.py call Python_InitTab()
endif


function! Tab_MoveLeft()
	let l:tabnr = tabpagenr() - 2
	if l:tabnr >= 0
		exec 'tabmove '.l:tabnr
	endif
endfunc

function! Tab_MoveRight()
	let l:tabnr = tabpagenr() + 1
	exec 'tabmove '.l:tabnr
endfunc

function! s:Filter_Push(desc, wildcard)
	let g:browsefilter .= a:desc . " (" . a:wildcard . ")\t" . a:wildcard . "\n"
endfunc

let g:browsefilter = ''
call s:Filter_Push("All Files", "*")
call s:Filter_Push("C/C++/Object-C", "*.c;*.cpp;*.cc;*.h;*.hh;*.hpp;*.m;*.mm")
call s:Filter_Push("Python", "*.py;*.pyw")
call s:Filter_Push("Text", "*.txt")
call s:Filter_Push("Vim Script", "*.vim")


" restore screen after quitting
if has('unix')
	let s:uname = system('uname')
	let s:xterm = 0
	if s:uname =~ "FreeBSD"
		let s:xterm = 1
	endif
	" restore screen after quitting
	if s:xterm != 0
		if &term =~ "xterm"
			let &t_ti="\0337\033[r\033[?47h"
			let &t_te="\033[?47l\0338"
			if has("terminfo")
				let &t_Sf="\033[3%p1%dm"
				let &t_Sb="\033[4%p1%dm"
			else
				let &t_Sf="\033[3%dm"
				let &t_Sb="\033[4%dm"
			endif
		endif
		set restorescreen
	endif
endif


function! Terminal_SwitchTab()
	if has('gui_running')
		return
	endif
	for i in range(10)
		exec "noremap <silent><M-".i."> :tabn ".i."<cr>"
		exec "inoremap <silent><M-".i."> <ESC>:tabn ".i."<cr>"
		exec "set <M-".i.">=\e]{0}".i."~"
	endfor
endfunc


call Terminal_SwitchTab()


