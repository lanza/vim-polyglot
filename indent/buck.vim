if polyglot#init#is_disabled(expand('<sfile>:p'), 'buck', 'indent/buck.vim')
  finish
endif

" Vim indent file
" Language:	Bazel (http://bazel.io)
" Maintainer:	David Barnett (https://github.com/google/vim-ft-buck)
" Last Change:	2017 Jun 13

if exists('b:did_indent')
  finish
endif

" Load base python indent.
if !exists('*GetPythonIndent')
  runtime! indent/python.vim
endif

let b:did_indent = 1

" Only enable buck google indent if python google indent is enabled.
if !get(g:, 'no_google_python_indent')
  setlocal indentexpr=GetBuckIndent(v:lnum)
endif

if exists('*GetBuckIndent')
  finish
endif

let s:save_cpo = &cpo
set cpo-=C

" Maximum number of lines to look backwards.
let s:maxoff = 50

""
" Determine the correct indent level given an {lnum} in the current buffer.
function GetBuckIndent(lnum) abort
  let l:use_recursive_indent = !get(g:, 'no_google_python_recursive_indent')
  if l:use_recursive_indent
    " Backup and override indent setting variables.
    if exists('g:pyindent_nested_paren')
      let l:pyindent_nested_paren = g:pyindent_nested_paren
    endif
    if exists('g:pyindent_open_paren')
      let l:pyindent_open_paren = g:pyindent_open_paren
    endif
    let g:pyindent_nested_paren = 'shiftwidth() * 2'
    let g:pyindent_open_paren = 'shiftwidth() * 2'
  endif

  let l:indent = -1

  " Indent inside parens.
  " Align with the open paren unless it is at the end of the line.
  " E.g.
  "   open_paren_not_at_EOL(100,
  "                         (200,
  "                          300),
  "                         400)
  "   open_paren_at_EOL(
  "       100, 200, 300, 400)
  call cursor(a:lnum, 1)
  let [l:par_line, l:par_col] = searchpairpos('(\|{\|\[', '', ')\|}\|\]', 'bW',
      \ "line('.') < " . (a:lnum - s:maxoff) . " ? dummy :" .
      \ " synIDattr(synID(line('.'), col('.'), 1), 'name')" .
      \ " =~ '\\(Comment\\|String\\)$'")
  if l:par_line > 0
    call cursor(l:par_line, 1)
    if l:par_col != col('$') - 1
      let l:indent = l:par_col
    endif
  endif

  " Delegate the rest to the original function.
  if l:indent == -1
    let l:indent = GetPythonIndent(a:lnum)
  endif

  if l:use_recursive_indent
    " Restore global variables.
    if exists('l:pyindent_nested_paren')
      let g:pyindent_nested_paren = l:pyindent_nested_paren
    else
      unlet g:pyindent_nested_paren
    endif
    if exists('l:pyindent_open_paren')
      let g:pyindent_open_paren = l:pyindent_open_paren
    else
      unlet g:pyindent_open_paren
    endif
  endif

  return l:indent
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
