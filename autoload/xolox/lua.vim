" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: September 14, 2014
" URL: http://peterodding.com/code/vim/lua-ftplugin

let g:xolox#lua#version = '1.0'

function! xolox#lua#includeexpr(fname) " {{{1
  " Search module path for matching Lua scripts.
  let module = substitute(a:fname, '\.', '/', 'g')
  for template in xolox#lua#getsearchpath('$LUA_PATH', 'package.path')
    let expanded = substitute(template, '?', module, 'g')
    call xolox#misc#msg#debug("lua.vim %s: Expanded %s -> %s", g:xolox#lua#version, template, expanded)
    if filereadable(expanded)
      call xolox#misc#msg#debug("lua.vim %s: Matched existing file %s", g:xolox#lua#version, expanded)
      return expanded
    endif
  endfor
  " Default to given name.
  return a:fname
endfunction

function! xolox#lua#getsearchpath(envvar, luavar) " {{{1
  let path = ''
  if xolox#misc#option#get('lua_internal', has('lua'))
    " Try to get the search path using the Lua Interface for Vim.
    try
      redir => path
      execute 'silent lua print(' . a:luavar . ')'
      redir END
      call xolox#misc#msg#debug("lua.vim %s: Got %s from Lua Interface for Vim", g:xolox#lua#version, a:luavar)
    catch
      redir END
    endtry
  endif
  if empty(path)
    let path = eval(a:envvar)
    if !empty(path)
      call xolox#misc#msg#debug("lua.vim %s: Got %s from %s", g:xolox#lua#version, a:luavar, a:envvar)
    else
      try
        let interpreter = xolox#misc#escape#shell(xolox#misc#option#get('lua_interpreter_path', 'lua'))
        let command = printf('%s -e "io.write(%s)"', interpreter, a:luavar)
        let path = xolox#misc#os#exec({'command': command})['stdout'][0]
        call xolox#misc#msg#debug("lua.vim %s: Got %s from external Lua interpreter", g:xolox#lua#version, a:luavar)
      catch
        call xolox#misc#msg#warn("lua.vim %s: Failed to get %s from external Lua interpreter: %s", g:xolox#lua#version, a:luavar, v:exception)
      endtry
    endif
  endif
  if exists('+shellslash') && &shellslash
    " Can't use expand() because it will return empty for paths with lua
    " wildcards because they don't exist.
    let path = substitute(path, '\\', '/', 'g')
  endif
  return split(xolox#misc#str#trim(path), ';')
endfunction

function! xolox#lua#help() " {{{1
  " Get the expression under the cursor.
  let cword = ''
  try
    let isk_save = &isk
    set iskeyword+=.,:
    let cword = expand('<cword>')
    let cword_whole = expand('<cWORD>')
  finally
    let &isk = isk_save
  endtry
  if cword != ''
    try
      call s:lookupmethod(cword, 'lrv-string.', '\v<(byte|char|dump|g?find|format|len|lower|g?match|rep|reverse|g?sub|upper)>')
      call s:lookupmethod(cword, 'lrv-file:', '\v<(close|flush|lines|read|seek|setvbuf|write)>')
      call s:lookupmethod(cword, '', '\v:\w+>')
      " nvim: vim.api and vim.fn aren't in the helptags.
      " Use whole word to find the function instead of the command (substitute() vs :substitute).
      call s:lookupmethod(cword_whole, '', '\vvim.api.\zs\k+\(')
      call s:lookupmethod(cword_whole, '', '\vvim.fn.\zs\k+\(')
      call s:lookupmethod(cword, '', '\vvim.api.\zs\k+>')
      call s:lookupmethod(cword, '', '\vvim.fn.\zs\k+>')
      call s:lookupmethod(cword, "'", '\vvim.[bgw]?o.\zs\k+>')
      call s:lookupmethod(cword, '', '\vvim.[gbwtv].\zs\k+>')
      " /nvim
      call s:lookuptopic('lrv-' . cword)
      call s:lookuptopic('love-' . cword)
      call s:lookuptopic(cword)
      call s:lookuptopic('luarefvim.txt')
      help
    catch /^done$/
      return
    endtry
  endif
  help
endfunction

function! s:lookupmethod(cword, prefix, pattern)
  let method = matchstr(a:cword, a:pattern)
  if method != ''
    let identifier = a:prefix . method
    call xolox#misc#msg#debug("lua.vim %s: Translating '%s' -> '%s'", g:xolox#lua#version, a:cword, identifier)
    call s:lookuptopic(identifier)
  endif
endfunction

function! s:lookuptopic(topic)
  try
    " Lookup the given topic in Vim's help files.
    execute 'help' escape(a:topic, ' []*?')
    " Abuse exceptions for non local jumping.
    throw 'done'
  catch /^Vim\%((\a\+)\)\=:E149/
    " Ignore E149: Sorry, no help for <keyword>.
    return
  endtry
endfunction

function! xolox#lua#jumpblock(forward) " {{{1
  let start = '\<\%(for\|function\|if\|repeat\|while\)\>'
  let middle = '\<\%(elseif\|else\)\>'
  let end = '\<\%(end\|until\)\>'
  let flags = a:forward ? '' : 'b'
  return searchpair(start, middle, end, flags, '!xolox#lua#tokeniscode()')
endfunction

function! s:jumpthisfuncstart()
  while search('\<function\>\|\%^', 'bcW')
    if xolox#lua#tokeniscode()
      break
    endif
  endwhile
endfunction

function! xolox#lua#jumpfuncstart(forward) " {{{1
  while search('\<function\>\|\%^\|\%$', a:forward ? 'W' : 'bW')
    if xolox#lua#tokeniscode()
      break
    endif
  endwhile
endfunction

function! xolox#lua#jumpfuncend(forward) " {{{1
  let origline = line('.')
  call s:jumpthisfuncstart()
  call xolox#lua#jumpblock(1)
  if a:forward && line('.') > origline || !a:forward && line('.') < origline
    return
  endif
  call xolox#lua#jumpfuncstart(a:forward)
  if !a:forward
    call xolox#lua#jumpfuncstart(a:forward)
  endif
  call xolox#lua#jumpblock(1)
endfunction

function! xolox#lua#tokeniscode() " {{{1
  return s:getsynid(0) !~? 'string\|comment'
endfunction

function! s:getsynid(transparent)
  let id = synID(line('.'), col('.'), 1)
  if a:transparent
    let id = synIDtrans(id)
  endif
  return synIDattr(id, 'name')
endfunction

if exists('loaded_matchit')

  function! xolox#lua#matchit() " {{{1
    let cword = expand('<cword>')
    if cword == 'end'
      let s = ['function', 'if', 'for', 'while']
      let e = ['end']
      unlet! b:match_skip
    elseif cword =~ '^\(function\|return\|yield\)$'
      let s = ['function']
      let m = ['return', 'yield']
      let e = ['end']
      let b:match_skip = "xolox#lua#matchit_ignore('^luaCond$')"
      let b:match_skip .= " || (expand('<cword>') == 'end' && xolox#lua#matchit_ignore('^luaStatement$'))"
    elseif cword =~ '^\(for\|in\|while\|do\|repeat\|until\|break\)$'
      let s = ['for', 'repeat', 'while']
      let m = ['break']
      let e = ['end', 'until']
      let b:match_skip = "xolox#lua#matchit_ignore('^\\(luaCond\\|luaFunction\\)$')"
    elseif cword =~ '\(if\|then\|elseif\|else\)$'
      let s = ['if']
      let m = ['elseif', 'else']
      let e = ['end']
      let b:match_skip = "xolox#lua#matchit_ignore('^\\(luaFunction\\|luaStatement\\)$')"
    else
      let s = ['for', 'function', 'if', 'repeat', 'while']
      let m = ['break', 'elseif', 'else', 'return']
      let e = ['eend', 'until']
      unlet! b:match_skip
    endif
    let p = '\<\(' . join(s, '\|') . '\)\>'
    if exists('m')
      let p .=  ':\<\(' . join(m, '\|') . '\)\>'
    endif
    return p . ':\<\(' . join(e, '\|') . '\)\>'
  endfunction

  function! xolox#lua#matchit_ignore(ignored) " {{{1
    let word = expand('<cword>')
    let type = s:getsynid(0)
    return type =~? a:ignored || type =~? 'string\|comment'
  endfunction

endif

" vim: ts=2 sw=2 et
