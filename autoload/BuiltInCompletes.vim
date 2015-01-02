" BuiltInCompletes.vim: Completion functions that emulate the built-in ones.
"
" DEPENDENCIES:
"
" Copyright: (C) 2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	01-Jan-2015	file creation

function! BuiltInCompletes#LocalComplete( findstart, base )
    return s:Complete({'complete': '.'}, a:findstart, a:base)
endfunction
function! BuiltInCompletes#Complete( findstart, base )
    return s:Complete({'complete': &complete}, a:findstart, a:base)
endfunction

function! s:Complete( options, findstart, base )
    if a:findstart
	" Locate the start of the keyword.
	let l:startCol = searchpos('\k*\%#', 'bn', line('.'))[1]
	if l:startCol == 0
	    let l:startCol = col('.')
	endif
	return l:startCol - 1 " Return byte index, not column.
    else
	" Find matches starting with a:base.
	let l:matches = []
	call CompleteHelper#FindMatches( l:matches, '\V\<' . escape(a:base, '\') . '\k\+', a:options)
	return l:matches
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
