fun! VimFlexPlugin(timer)
    lua for k in pairs(package.loaded) do if k:match("^vim%-flex") then package.loaded[k] = nill end end
    lua require("vim-flex").timeToFlex()
endfun

augroup vimFlexPlugin
    autocmd!
    autocmd VimEnter * call timer_start(60 * 60 * 1000, 'VimFlexPlugin', {'repeat': -1})
augroup END
