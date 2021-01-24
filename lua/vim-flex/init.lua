local function startVimFlex()
    local interval_min = vim.g.vim_flex_interval_min or 60

    interval_msec = interval_min * 1000 * 60
    -- interval_msec = interval_min * 1000       -- Convert to sec for debugging

    vim.api.nvim_exec("let g:vim_flex_timer_id = timer_start(" ..interval_msec.. ", 'VimFlexTimeToFlex', {'repeat': -1})", true)
end

local function stopVimFlex()
    vim.api.nvim_exec("call timer_stop(" ..vim.g.vim_flex_timer_id.. ")", true)
end

local function generateLines()
    -- Read text from file
    lines = {}
    for line in io.lines("/home/miguel/Desktop/git/vim-flex/lua/vim-flex/time_to_flex_text") do
        lines[#lines + 1] = line
    end

    -- Calculate time stamps
    local flex_min = vim.g.vim_flex_time_min or 5
    local flex_sec = flex_min * 60
    flex_msec = flex_sec * 1000

    local start = os.time()
    local stop = start + flex_sec

    -- Append time stamps to lines
    lines[#lines + 1] = "                           START = " .. os.date("%c", start)
    lines[#lines + 1] = "                           STOP  = " .. os.date("%c", stop)
    lines[#lines + 1] = ""

    return lines
end

local function createFloatingWindow()
    -- Get UI dimensions
    local stats = vim.api.nvim_list_uis()[1]
    local width = stats.width
    local height = stats.height

    print("Creating window size:", width, height)

    -- Create new buffer
    local lines = generateLines()
    bufh = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufh, 0, -1, true, lines)

    -- Create new window
    winId = vim.api.nvim_open_win(bufh, true, {
        relative="editor",
        width = width - 10,
        height = height - 10,
        col = 5,
        row = 5,
    })

    -- Clear and redraw the screen
    vim.api.nvim_command('mode')
end

local function deleteFloatingWindow()
    vim.api.nvim_win_close(winId, true)

    -- Clear and redraw the screen
    vim.api.nvim_command('mode')
end

local function updateTime()
    -- Read current buffer lines
    local lines  = vim.api.nvim_buf_get_lines(bufh, 0, -1, true)

    -- Append current time
    lines[#lines] = "                           NOW   = " .. os.date("%c", os.time())
    vim.api.nvim_buf_set_lines(bufh, 0, -1, true, lines)
    --
    -- Redraw the screen withou clearing it
    vim.api.nvim_command('redraw')
    return false
end

local function timeToFlex()
    -- If vim flex is disabled do nothing
    if vim.g.vim_flex_disable == 1 then
        return
    end

    createFloatingWindow()
    vim.wait(flex_msec, updateTime, 1000, false)
    deleteFloatingWindow()
end

local function onResize()
    local stats = vim.api.nvim_list_uis()[1]
    local width = stats.width
    local height = stats.height

    print("Resizing window to size:", winId, width, height)
    vim.api.nvim_win_set_width(winId, width - 10)
    vim.api.nvim_win_set_height(winId, height - 10)
end


return {
    startVimFlex = startVimFlex,
    stopVimFlex = stopVimFlex,
    timeToFlex = timeToFlex,
}
