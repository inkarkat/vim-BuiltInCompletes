" BuiltInCompletes.vim: Completion functions that emulate the built-in ones.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"   - ingo/collections.vim autoload script
"
" Copyright: (C) 2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	01-Jan-2015	file creation
let s:save_cpo = &cpo
set cpo&vim

function! BuiltInCompletes#LocalComplete( findstart, base )
    return s:Complete({'complete': '.'}, a:findstart, a:base)
endfunction
function! BuiltInCompletes#Complete( findstart, base )
    let l:matches = s:Complete({'complete': &complete}, a:findstart, a:base)

    if ! a:findstart && ingo#option#Contains(&complete, 't')
	let l:tagNames = ingo#compat#uniq(
	\   map(
	\       taglist('\V\^' . escape(a:base, '\')),
	\       'v:val.name'
	\   )
	\)

	if ! empty(l:tagNames)
	    " Don't include tags that have been found already once again.
	    let l:words = ingo#collections#ToDict(map(copy(l:matches), 'v:val.word'))

	    let l:matches += map(
	    \   filter(
	    \       l:tagNames,
	    \       '! has_key(l:words, v:val)'
	    \   ),
	    \   '{"word": v:val}'
	    \)
	endif
    endif

    return l:matches
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

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
