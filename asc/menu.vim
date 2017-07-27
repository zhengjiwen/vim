"======================================================================
"
" menu.vim - 
"
" Created by skywind on 2017/07/06
" Last change: 2017/07/06 16:59:26
"
"======================================================================



"----------------------------------------------------------------------
" internal help
"----------------------------------------------------------------------

function! menu#FindInProject()
	let p = vimmake#get_root('%')
	let t = expand('<cword>')
	echohl Type
	call inputsave()
	let t = input('find word ('. p.'): ', t)
	call inputrestore()
	echohl None
	redraw | echo "" | redraw
	if strlen(t) > 0
		silent exec "GrepCode! ".fnameescape(t)
		call asclib#quickfix_title('- searching "'. t. '"')
	endif
endfunc

function! menu#CodeCheck()
	if &ft == 'python'
		call asclib#lint_pylint('')
	elseif &ft == 'c' || &ft == 'cpp'
		call asclib#lint_cppcheck('')
	else
		call asclib#errmsg('file type unsupported, only support python/c/cpp')
	endif
endfunc

function! menu#DelimitSwitch(on)
	if a:on
		exec "DelimitMateOn"
	else
		exec "DelimitMateOff"
	endif
endfunc

function! menu#TogglePaste()
	if &paste
		set nopaste
	else
		set paste
	endif
endfunc

function! menu#CurrentWord(limit)
	let text = expand('<cword>')
	if len(text) < a:limit
		return text
	endif
	return text[:a:limit] . '..'
endfunc

function! menu#CurrentFile(limit)
	let text = expand('%:t')
	if len(text) < a:limit
		return text
	endif
	return text[:a:limit] . '..'
endfunc

function! menu#DiffSplit()
	let filename = input('Enter filename to compare: ')
	if filename == ''
		return
	endif
	exec "vertical diffsplit ".fnameescape(filename)
endfunc


"----------------------------------------------------------------------
" menu initialize
"----------------------------------------------------------------------

let g:quickmenu_options = 'LH'

call quickmenu#current(0)
call quickmenu#reset()

call quickmenu#append('# Development', '')
call quickmenu#append('Execute', 'VimExecute run', 'run %{expand("%")}')
call quickmenu#append('GCC', 'VimBuild gcc', 'compile %{expand("%")}')
call quickmenu#append('Make', 'VimBuild make', 'make current project')
call quickmenu#append('Emake', 'VimBuild emake', 'emake current project')

if 1
call quickmenu#append('# Find', '')
call quickmenu#append('Find word', 'call menu#FindInProject()', 'Find (%{expand("<cword>")}) in current project')
call quickmenu#append('Stop searching', 'VimStop', 'Stop searching')
call quickmenu#append('Tag view', 'call asclib#preview_tag(expand("<cword>"))', 'Find (%{expand("<cword>")}) in ctags database')
call quickmenu#append('Tag update', 'call vimmake#update_tags("!", "ctags", ".tags")', 'reindex ctags database')
call quickmenu#append('Switch Header', 'call Open_HeaderFile(1)', 'switch header/source', 'c,cpp,objc,objcpp')
endif

call quickmenu#append('Check: flake8', 'call asclib#lint_flake8("")', 'run flake8 in current document, [e to display error', 'python')
call quickmenu#append('Check: pylint', 'call asclib#lint_pylint("")', 'run pylint in current document, [e to display error', 'python')
call quickmenu#append('Check: cppcheck', 'call asclib#lint_cppcheck("")', 'run cppcheck, [e to display error', 'c,cpp,objc,objcpp')
call quickmenu#append('Clear error marks', 'GuiSignRemove errormarker_error errormarker_warning', 'clear error marks', 'python,c,cpp,objc,objcpp')

if 1
call quickmenu#append('# SVN / GIT', '')
call quickmenu#append("svn diff", 'call asclib#svn_diff("%")', '提交前的修改版本对比，使用 "]c" 和 "[c" 查找下一处和上一处改动，二次运行关闭对比')
call quickmenu#append("svn log", 'VimMake! -raw svn log %', '查看当前文件的修改日志，在 Quickfix窗口中显示结果，按F10可以隐藏/切换 Quickfix')

call quickmenu#append('# Utility', '')
call quickmenu#append('Paste Mode %{&paste? "[x]" :"[ ]"}', 'call menu#TogglePaste()', '切换粘贴模式')
call quickmenu#append('File Compare', 'call menu#DiffSplit()', 'use vertical diffsplit')
call quickmenu#append('Function List', 'call Toggle_Tagbar()', '显示或隐藏 Tagbar 查看函数列表')
call quickmenu#append('DelimitMate %{get(b:, "delimitMate_enabled", 0)? "[x]":"[ ]"}', 'DelimitMateSwitch', '在当前文档打开或者关闭符号补全插件')

endif


