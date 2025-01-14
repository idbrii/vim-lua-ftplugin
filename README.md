
This is a **stripped-down version** of vim-lua for use with
[LuaLS](https://github.com/LuaLS/lua-language-server) or other [LSP
servers](https://microsoft.github.io/language-server-protocol/). It excludes
completion, syntax checking, and other redundant features. I wanted to simplify
my lua setup to reduce any potential sources of errors. See the [deluxe
branch](https://github.com/idbrii/vim-lua-ftplugin/tree/deluxe) or [Peter
Odding's original lua ftplugin](http://peterodding.com/code/vim/lua-ftplugin)
for a version that includes more features (most are toggleable).


# Lua file type plug-in for the Vim text editor

The [Lua][lua] file type plug-in for [Vim][vim] makes it easier to work with Lua source code in Vim by providing the following features:

 * The ['includeexpr'][inex] option is set so that the [gf][gf] (go to file) mapping knows how to resolve Lua module names using [package.path][pp]

 * The ['include'][inc] option is set so that Vim follows [dofile()][dof], [loadfile()][lof] and [require()][req] calls when looking for identifiers in included files (this works together with the ['includeexpr'][inex] option)

 * `K` (normal mode) and `<F1>` (insert mode) on a Lua function or 'method' call will try to open the relevant documentation in the [Lua Reference for Vim][lrv]

 * Several [text-objects][tob] are defined so you can jump between blocks and functions

 * A pretty nifty hack of the [matchit plug-in][mit] is included: When the cursor is on a `function` or `return` keyword the `%` mapping cycles between the relevant keywords (`function`, `return`, `end`), this also works for branching statements (`if`, `elseif`, `else`, `end`) and looping statements (`for`, `while`, `repeat`, `until`, `end`)

## Installation

Install this plugin and the vim-misc plugin with vim-plug or similar plugin
manager:
```vimscript
 Plug 'idbrii/vim-lua-ftplugin'
 Plug 'xolox/vim-misc'
```

Or clone these two repositories into ~/.vim/pack/lua-ftplugin/start
* https://github.com/idbrii/vim-lua-ftplugin
* http://github.com/xolox/vim-misc

Now try it out: Edit a Lua script and try any of the features documented above.

## Options

The Lua file type plug-in handles options as follows: First it looks at buffer local variables, then it looks at global variables and if neither exists a default is chosen. This means you can change how the plug-in works for individual buffers. For example to change the location of the Lua compiler used to check the syntax:

    " This sets the default value for all buffers.
    :let g:lua_interpreter_path = '/usr/local/bin/lua'

    " This is how you change the value for one buffer.
    :let b:lua_interpreter_path = '/usr/local/bin/lua52'

### The `lua_interpreter_path` option

The name or path of the Lua interpreter used to evaluate Lua scripts used by the plug-in (for example the script that checks for undefined global variables, see `:LuaCheckGlobals`).

### The `lua_internal` option

If you're running a version of Vim that supports the Lua Interface for Vim (see [if_lua.txt][if_lua.txt]) then all Lua code evaluated by the Lua file type plug-in is evaluated using the Lua Interface for Vim. If the Lua Interface for Vim is not available the plug-in falls back to using an external Lua interpreter. You can set this to false (0) to force the plug-in to use an external Lua interpreter.

## Contact

If you have suggestions or feature requests, first check out the
deluxe version https://github.com/idbrii/vim-lua-ftplugin/tree/deluxe or the
original at http://peterodding.com/code/vim/lua-ftplugin .

If you have any issues with this simplified version, see
https://github.com/idbrii/vim-lua-ftplugin/issues

## License

This software is licensed under the [MIT license](http://en.wikipedia.org/wiki/MIT_License).
© 2014 Peter Odding &lt;<peter@peterodding.com>&gt;.

Thanks go out to everyone who has helped to improve the Lua file type plug-in for Vim (whether through pull requests, bug reports or personal e-mails).


[cfu]: http://vimdoc.sourceforge.net/htmldoc/options.html#%27completefunc%27
[dll]: http://en.wikipedia.org/wiki/Dynamic-link_library
[dof]: http://www.lua.org/manual/5.2/manual.html#pdf-dofile
[download-lua-ftplugin]: http://peterodding.com/code/vim/downloads/lua-ftplugin.zip
[download-misc]: http://peterodding.com/code/vim/downloads/misc.zip
[gf]: http://vimdoc.sourceforge.net/htmldoc/editing.html#gf
[github-lua-ftplugin]: http://github.com/xolox/vim-lua-ftplugin
[github-misc]: http://github.com/xolox/vim-misc
[if_lua.txt]: http://vimdoc.sourceforge.net/htmldoc/if_lua.html#if_lua.txt
[inc]: http://vimdoc.sourceforge.net/htmldoc/options.html#%27include%27
[inex]: http://vimdoc.sourceforge.net/htmldoc/options.html#%27includeexpr%27
[ll]: http://lua-users.org/wiki/LuaLint
[lof]: http://www.lua.org/manual/5.2/manual.html#pdf-loadfile
[lrv]: https://github.com/idbrii/luarefvim
[lua]: http://www.lua.org/
[mit]: http://vimdoc.sourceforge.net/htmldoc/usr_05.html#matchit-install
[ofu]: http://vimdoc.sourceforge.net/htmldoc/options.html#%27omnifunc%27
[pathogen]: http://www.vim.org/scripts/script.php?script_id=2332
[pp]: http://www.lua.org/manual/5.2/manual.html#pdf-package.path
[req]: http://www.lua.org/manual/5.2/manual.html#pdf-require
[shell]: http://peterodding.com/code/vim/shell/
[tob]: http://vimdoc.sourceforge.net/htmldoc/motion.html#text-objects
[vim]: http://www.vim.org/
[vimrc]: http://vimdoc.sourceforge.net/htmldoc/starting.html#vimrc
[vundle]: https://github.com/gmarik/vundle
