fun! VimFlexStart()
    lua for k in pairs(package.loaded) do if k:match("^vim%-flex") then package.loaded[k] = nill end end
    lua require("vim-flex").startVimFlex()
endfun

fun! VimFlexStop()
    lua for k in pairs(package.loaded) do if k:match("^vim%-flex") then package.loaded[k] = nill end end
    lua require("vim-flex").stopVimFlex()
endfun

fun! VimFlexTimeToFlex(timer)
    lua for k in pairs(package.loaded) do if k:match("^vim%-flex") then package.loaded[k] = nill end end
    lua require("vim-flex").timeToFlex()
endfun

augroup vimFlexPlugin
    autocmd!
    autocmd VimEnter * call VimFlexStart()
augroup END
