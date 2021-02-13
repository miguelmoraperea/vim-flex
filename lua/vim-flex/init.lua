-- Define local variables
local default_interval_min = 15
local default_flex_time_min = 1

local flex_msec
local stop_time
local width
local height
local buffer_handler
local win_id


local function start_timer_to_flex()
    local interval_min = vim.g.vim_flex_interval_min or default_interval_min

    local interval_msec = interval_min * 1000 * 60
    -- interval_msec = interval_min * 1000       -- Use value as seconds, for debugging

    vim.api.nvim_exec("let g:vim_flex_timer_id = timer_start(" ..interval_msec.. ", 'VimFlexTimeToFlex', {'repeat': -1})", true)
end

local function stop_timer_to_flex()
    vim.api.nvim_exec("call timer_stop(" ..vim.g.vim_flex_timer_id.. ")", true)
end

local function file_exists(name)
   local file = io.open(name, 'r')
   if file ~= nil then
       io.close(file)
       return true
   else
       return false
   end
end

local function read_logo()
    local rtp = vim.api.nvim_exec('set rtp?', true)
    local home = os.getenv('HOME')

    local results = {}
    for match in string.gmatch(rtp, "[^,]+") do
      table.insert(results, match)
    end

    local file = nil
    for _,v in ipairs(results) do
        local name = v..'/lua/vim-flex/time_to_flex_text'
        name = name:gsub('~', home..'/')
        if file_exists(name) then
            file = name
            break
        end
    end

    local lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = line
    end

    return lines
end

local function create_timestamps()
    local flex_min = vim.g.vim_flex_time_min or default_flex_time_min
    local flex_sec = flex_min * 60
    flex_msec = flex_sec * 1000

    local start_time = os.time()
    stop_time = start_time + flex_sec
end

local function center_horizontally(lines, columns)
    local centered_lines = {}

    for _, line in ipairs(lines) do
        local line_length = string.len(line) / 3
        local leading_cnt = (columns - line_length) / 2
        local leading_spaces = string.rep(' ', leading_cnt)
        centered_lines[#centered_lines + 1] = leading_spaces .. line
    end

    return centered_lines
end

local function center_vertically(lines, rows)
    local lines_above_cnt = math.floor((rows - #lines) / 2)

    local empty_lines = {}
    for _ = 1,lines_above_cnt do
    empty_lines[#empty_lines + 1] = ""
    end

    for _,v in ipairs(empty_lines) do
        table.insert(lines, 1, v)
    end

    return lines
end

local function create_floating_window()
    create_timestamps()

    -- Get UI dimensions
    local stats = vim.api.nvim_list_uis()[1]
    local ui_width = stats.width
    local ui_height = stats.height

    print("Available UI size:", ui_width, ui_height)

    local columns_per_row = 4
    local margin = 5

    -- Create new buffer
    local lines = read_logo()

    -- Add emty lines below the logo
    lines[#lines + 1] = ""
    lines[#lines + 1] = ""

    -- Define window sizes
    local line_length = string.len(lines[1]) / 3
    width = line_length + (margin * columns_per_row * 2)
    height = #lines + (margin * 2)

    -- Center lines in window
    lines = center_horizontally(lines, width)
    lines = center_vertically(lines, height)

    buffer_handler = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer_handler, 0, -1, true, lines)

    -- Create new window
    win_id = vim.api.nvim_open_win(buffer_handler, true, {
        relative="editor",
        width = width,
        height = height,
        col = 5,
        row = 3,
        style="minimal",
    })

    -- Clear and redraw the screen
    vim.api.nvim_command('mode')
end

local function delete_floating_window()
    vim.api.nvim_win_close(win_id, true)

    -- Clear and redraw the screen
    vim.api.nvim_command('mode')
end

local function update_time()
    -- Read current buffer lines
    local lines  = vim.api.nvim_buf_get_lines(buffer_handler, 0, -1, true)

    -- Append current time
    local time_diff = stop_time - os.time()
    local time_diff_str = " " .. os.date('%M:%S', time_diff)
    local centered_time = center_horizontally({time_diff_str}, width)
    lines[#lines] = centered_time[1]

    vim.api.nvim_buf_set_lines(buffer_handler, 0, -1, true, lines)

    -- Redraw the screen without clearing it
    vim.api.nvim_command('redraw')
    return false
end

local function time_to_flex()
    -- If vim flex is disabled do nothing
    if vim.g.vim_flex_disable == 1 then
        return
    end

    create_floating_window()
    vim.wait(flex_msec, update_time, 1000, false)
    delete_floating_window()
end

return {
    start_timer_to_flex = start_timer_to_flex,
    stop_timer_to_flex = stop_timer_to_flex,
    time_to_flex = time_to_flex,
}
