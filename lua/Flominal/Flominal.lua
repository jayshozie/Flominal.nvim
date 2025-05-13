-- Flominal.lua
-- Yanked from TJ DeVries, thanks.

local M = {}

---@class Flominal.Config
local defaults = {
    width = 0.6,
    height = 0.6,
    border = "rounded",
    command_name = "Flominal",
    keymap = "<M-n>",
    keymap_desc = "Toggle Flominal",
    cleanup_command_name = "FlominalClear",
    cleanup_keymap = "<M-c>",
    cleanup_keymap_desc = "<M-c> to cleanup Flominal",
}

---@type Flominal.Config
M.options = {}


local state = {
    floating = {
        buf = -1,
        win = -1,
    }
}

local function create_floating_window(opts)
    opts = opts or {}
    -- if not 0 < config.width < 1 and type(config.width) ~= "number" then
    --     config.width = default.width
    -- end
    -- if not 0 < config.height < 1 and type(config.height) ~= "number" then
    --     config.height = default.height
    -- end

    local width = math.floor(vim.o.columns * M.options.width)
    local height = math.floor(vim.o.lines * M.options.height)

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
        border = M.options.border,
    }

    -- Create the floating window
    local win = vim.api.nvim_open_win(buf, true, win_config)

    return { buf = buf, win = win }
end


function M.cleanup()
    if state.floating.buf ~= -1 and vim.api.nvim_buf_is_valid(state.floating.buf) then
        vim.api.nvim_buf_delete(state.floating.buf, { force = true })
        state.floating.buf = -1
    end
    if state.floating.win ~= -1 and vim.api.nvim_win_is_valid(state.floating.win) then
        vim.api.nvim_win_close(state.floating.win, true)
        state.floating.win = -1
    end
    print("Flominal: Cleared last buffer and window.")
end


function M.toggle_terminal()
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
    vim.cmd("startinsert")
end


function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})

    -- Initialize user command and keymapping
    vim.api.nvim_create_user_command(M.options.command_name, M.toggle_terminal, {})
    vim.keymap.set({ "n", "t" }, M.options.keymap, M.toggle_terminal, { desc = M.options.keymap_desc })

    -- Intended for use if the plugin crashes
    local cleanup_command_name = M.options.cleanup_command_name or "FlominalClear"
    vim.api.nvim_create_user_command(cleanup_command_name, M.cleanup, { desc = "Clear last Flominal buffer/window" })
    vim.keymap.set( { "n", "t" }, M.options.cleanup_keymap, M.cleanup, { desc = M.options.cleanup_keymap_desc } )
end


return M
