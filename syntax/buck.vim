if polyglot#init#is_disabled(expand('<sfile>:p'), 'buck', 'syntax/buck.vim')
  finish
endif

" Vim syntax file
" Language:	Bazel (http://bazel.io)
" Maintainer:	David Barnett (https://github.com/google/vim-ft-buck)
" Last Change:	2015 Aug 11

if exists('b:current_syntax')
  finish
endif


runtime! syntax/python.vim

let b:current_syntax = 'buck'

syn region buckRule start='^\w\+($' end='^)\n*' transparent fold
syn region buckList start='\[' end='\]' transparent fold
