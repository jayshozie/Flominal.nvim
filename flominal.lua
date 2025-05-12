-- Flominal.lua

local Flominal = {}

-- Yanked from TJ DeVries

local state = {
    floating = {
        buf = -1,
        win = -1,
    }
}

local function create_floating_window(opts)
    opts = opts or {}
    local width = opts.width or math.floor(vim.o.columns * 0.8)
    local height = opts.height or math.floor(vim.o.lines * 0.8)

    -- Calculate the position to center the window
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    -- Create a buffer
    local buf = nil
    if type(opts.buf) == "number" and opts.buf >= 0 and vim.api.nvim_buf_is_valid(opts.buf) then
        buf = opts.buf
    else
        buf = vim.api.nvim_create_buf(false, true)
    end

    -- Define window configuration
    local win_config = {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded",
    }

    -- Create the floating window
    local win = vim.api.nvim_open_win(buf, true, win_config)

    return { buf = buf, win = win }
end


local toggle_terminal = function()
    if state.floating.win ~= -1 and vim.api.nvim_win_is_valid(state.floating.win) then
        -- Window exists and is valid, hide it
        vim.api.nvim_win_hide(state.floating.win)
    else
        -- Create new floating window with existing buffer if valid
        local buf_to_use = nil
        if state.floating.buf ~= -1 and vim.api.nvim_buf_is_valid(state.floating.buf) then
            buf_to_use = state.floating.buf
        end

        state.floating = create_floating_window({ buf = buf_to_use })

        -- Ensure we're working with the buffer in the floating window
        local buf = state.floating.buf

        -- Create terminal in this buffer if it's not already a terminal
        if vim.bo[buf].buftype ~= "terminal" then
            -- Use vim.api calls for more explicit control
            -- Save current window to return to it after operations

            -- Make sure we're in the floating window
            vim.api.nvim_set_current_win(state.floating.win)

            -- Create terminal in the current window (the floating window)
            vim.cmd("terminal")

            -- Enter terminal mode automatically
            vim.cmd("startinsert")
        end
    end
end

flominal.toggle_terminal = toggle_terminal -- Add the function to the module

vim.api.nvim_create_user_command("Flominal", toggle_terminal, {})
vim.keymap.set({ "n", "t" }, "<M-n>", toggle_terminal, { desc = "Toggle Flominal" })
