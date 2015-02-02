" BuiltInCompletes.vim: Completion functions that emulate the built-in ones.
"
" DEPENDENCIES:
"   - ingo/collections.vim autoload script
"
" Copyright: (C) 2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	003	03-Feb-2015	FIX: taglist() output is not guaranteed to be
"				sorted; use ingo#collections#UniqueStable()
"				instead of uniq().
"	002	04-Jan-2015	Add BuiltInCompletes#TagComplete().
"				Split off two separate ...Prev / ...Next
"				functions to deliver the matches in the correct,
"				original order.
"	001	01-Jan-2015	file creation
let s:save_cpo = &cpo
set cpo&vim

function! BuiltInCompletes#LocalCompleteNext( findstart, base )
    return s:LocalComplete(0, a:findstart, a:base)
endfunction
function! BuiltInCompletes#LocalCompletePrev( findstart, base )
    return s:LocalComplete(1, a:findstart, a:base)
endfunction
function! s:LocalComplete( isBackward, findstart, base )
    return s:CompleteViaHelper({'complete': '.', 'backward_search': a:isBackward}, a:findstart, a:base)
endfunction

function! BuiltInCompletes#CompleteNext( findstart, base )
    return s:Complete(0, a:findstart, a:base)
endfunction
function! BuiltInCompletes#CompletePrev( findstart, base )
    return s:Complete(1, a:findstart, a:base)
endfunction
function! s:Complete( isBackward, findstart, base )
    let l:matches = s:CompleteViaHelper({'complete': &complete, 'backward_search': a:isBackward}, a:findstart, a:base)

    if ! a:findstart && ingo#option#Contains(&complete, 't')
	let l:tagNames = ingo#collections#UniqueStable(
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

function! s:CompleteViaHelper( options, findstart, base )
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

function! BuiltInCompletes#TagComplete( findstart, base )
    if a:findstart
	" Locate the start of the keyword.
	let l:startCol = searchpos('\k*\%#', 'bn', line('.'))[1]
	if l:startCol == 0
	    let l:startCol = col('.')
	endif
	return l:startCol - 1 " Return byte index, not column.
    else
	let l:tagNames = ingo#collections#UniqueStable(
	\   map(
	\       taglist('\V\^' . escape(a:base, '\')),
	\       'v:val.name'
	\   )
	\)

	let l:matches = map(
	\   l:tagNames,
	\   '{"word": v:val}'
	\)
    endif

    return l:matches
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
