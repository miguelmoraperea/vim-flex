local function createFloatingWindow()
    local stats = vim.api.nvim_list_uis()[1]
    local width = stats.width
    local height = stats.height

    print("Creating window size:", width, height)

    lines = {}
    for line in io.lines("/home/miguel/Desktop/git/vim-flex/lua/vim-flex/time_to_flex_text") do
        lines[#lines + 1] = line
    end

    time = os.time()
    now = os.date("%c", time)
    later = os.date("%c", time + 300)
    lines[#lines + 1] = "                           START = " .. now
    lines[#lines + 1] = "                           END   = " .. later

    local bufh = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufh, 0, -1, true, lines)
    winId = vim.api.nvim_open_win(bufh, true, {
        relative="editor",
        width = width - 10,
        height = height - 10,
        col = 5,
        row = 5,
    })
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
    createFloatingWindow = createFloatingWindow,
    onResize = onResize
}
