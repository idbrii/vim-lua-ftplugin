" Vim file type plug-in
" Language: Lua 5.2
" Author: Peter Odding <peter@peterodding.com>
" Last Change: 2023-07-19
" URL: http://peterodding.com/code/vim/lua-ftplugin

if exists('b:did_ftplugin')
  finish
else
  let b:did_ftplugin = 1
endif


if !exists('g:loaded_lua_ftplugin')
  try
    " Do something completely innocent while making sure the vim-misc plug-in
    " is installed since most commands will fail without it. We specifically
    " don't use Vim's exists() function because it doesn't load auto-load
    " scripts that haven't already been loaded yet (last tested on Vim 7.3).
    call type(g:xolox#misc#version)
    let g:loaded_lua_ftplugin = 1
  catch
    echomsg "Warning: vim-lua-ftplugin requires the vim-misc plugin which is not installed! See :help ft_lua-installation for details."
    echomsg "Disabling vim-lua-ftplugin."
    let g:loaded_lua_ftplugin = 0
  endtry
elseif g:loaded_lua_ftplugin == 0
  finish
endif




" A list of commands that undo buffer local changes made below.
let s:undo_ftplugin = []

" Set comment (formatting) related options. {{{1
setlocal fo-=t fo+=c fo+=r fo+=o fo+=q fo+=l
setlocal cms=--%s com=s:--[[,m:\ ,e:]],:--
call add(s:undo_ftplugin, 'setlocal fo< cms< com<')

" Tell Vim how to follow dofile(), loadfile() and require() calls. {{{1
let &l:include = '\v<((do|load)file|require)[^''"]*[''"]\zs[^''"]+'
let &l:includeexpr = 'xolox#lua#includeexpr(v:fname)'
call add(s:undo_ftplugin, 'setlocal inc< inex<')

" Set a filename filter for the Windows file open/save dialogs. {{{1
if has('gui_win32') && !exists('b:browsefilter')
  let b:browsefilter = "Lua Files (*.lua)\t*.lua\nAll Files (*.*)\t*.*\n"
  call add(s:undo_ftplugin, 'unlet! b:browsefilter')
endif

" Define mappings for context-sensitive help using Lua Reference for Vim. {{{1
imap <buffer> <F1> <C-o>:call xolox#lua#help()<Cr>
nmap <buffer> <F1>      :call xolox#lua#help()<Cr>
nmap <buffer> K         :call xolox#lua#help()<Cr>
call add(s:undo_ftplugin, 'iunmap <buffer> <F1>')
call add(s:undo_ftplugin, 'nunmap <buffer> <F1>')
call add(s:undo_ftplugin, 'nunmap <buffer> K')

" Define custom text objects to navigate Lua source code. {{{1
noremap <buffer> <silent> [{ m':call xolox#lua#jumpblock(0)<Cr>
noremap <buffer> <silent> ]} m':call xolox#lua#jumpblock(1)<Cr>
noremap <buffer> <silent> [[ m':call xolox#lua#jumpfuncstart(0)<Cr>
noremap <buffer> <silent> ][ m':call xolox#lua#jumpfuncend(1)<Cr>
noremap <buffer> <silent> [] m':call xolox#lua#jumpfuncend(0)<Cr>
noremap <buffer> <silent> ]] m':call xolox#lua#jumpfuncstart(1)<Cr>
call add(s:undo_ftplugin, 'unmap <buffer> [{')
call add(s:undo_ftplugin, 'unmap <buffer> ]}')
call add(s:undo_ftplugin, 'unmap <buffer> [[')
call add(s:undo_ftplugin, 'unmap <buffer> ][')
call add(s:undo_ftplugin, 'unmap <buffer> []')
call add(s:undo_ftplugin, 'unmap <buffer> ]]')

" Enable extended matching with "%" using the "matchit" plug-in. {{{1
if exists('loaded_matchit')
  let b:match_ignorecase = 0
  let b:match_words = 'xolox#lua#matchit()'
  call add(s:undo_ftplugin, 'unlet! b:match_ignorecase b:match_words b:match_skip')
endif

" }}}1

" Let Vim know how to disable the plug-in.
call map(s:undo_ftplugin, "'execute ' . string(v:val)")
let b:undo_ftplugin = join(s:undo_ftplugin, ' | ')
unlet s:undo_ftplugin

" vim: ts=2 sw=2 et
