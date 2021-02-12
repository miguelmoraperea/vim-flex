fun! VimFlexStart()
    lua for k in pairs(package.loaded) do if k:match("^vim%-flex") then package.loaded[k] = nill end end
    lua require("vim-flex").start_timer_to_flex()
endfun

fun! VimFlexStop()
    lua for k in pairs(package.loaded) do if k:match("^vim%-flex") then package.loaded[k] = nill end end
    lua require("vim-flex").stop_timer_to_flex()
endfun

fun! VimFlexTimeToFlex()
    lua for k in pairs(package.loaded) do if k:match("^vim%-flex") then package.loaded[k] = nill end end
    lua require("vim-flex").time_to_flex()
endfun

augroup VimFlexPlugin
    autocmd!
    autocmd VimEnter * call VimFlexStart()
augroup END
