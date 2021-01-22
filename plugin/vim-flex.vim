fun! VimFlexPlugin()
    lua for k in pairs(package.loaded) do if k:match("^vim%-flex") then package.loaded[k] = nill end end
    lua require("vim-flex").createFloatingWindow()
endfun

let g:vim_flex_variable = 42

augroup vimFlexPlugin
    autocmd!
    autocmd VimResized * :lua require("vim-flex").onResize()
augroup END
