local M = {}

local state = {
    floating = {
        buf = -1,
        win = -1,
    }
}

local defaults = {
    terminal = {
        width = 0.6, -- 60% of the screen
        height = 0.6, -- 60% of the screen
        border = "rounded",
    },
    toggle = {
        command_name = "Flominal", -- Yes, you can change the name of the command.
        keymap = "<M-n>", -- Defaults to <M-n> (Alt+n)
        toggle_desc = "Toggle Flominal",
    },
    cleanup = {
        cleanup_command_name = "FlominalClean", -- Yes, you can change the clear command, too.
        cleanup_keymap = "<M-c>",
        cleanup_desc = "Clear the Flominal buffer/window",
    },
}


---@class Flominal.options
---@field terminal table<number, number, string>: Window size and shape
---@field toggle table<string, string, string>: Toggling the Flominal window
---@field cleanup table<string, string, string>: Cleanup function

---@type Flominal.options
local options = {
    terminal = {},
    toggle = {},
    cleanup = {},
}

local function create_floating_window(opts)
    opts = opts or {}
    -- if not 0 < config.width < 1 and type(config.width) ~= "number" then
    --     config.width = default.width
    -- end
    -- if not 0 < config.height < 1 and type(config.height) ~= "number" then
    --     config.height = default.height
    -- end

    local width = math.floor(vim.o.columns * options.terminal.width)
    local height = math.floor(vim.o.lines * options.terminal.height)

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
        border = options.terminal.border,
    }

    -- Create the floating window
    local win = vim.api.nvim_open_win(buf, true, win_config)

    return { buf = buf, win = win }
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


function M.cleanup()
    if state.floating.buf ~= -1 and vim.api.nvim_buf_is_valid(state.floating.buf) then
        vim.api.nvim_buf_delete(state.floating.buf, { force = true })
        state.floating.buf = -1
    end
    if state.floating.win ~= -1 and vim.api.nvim_win_is_valid(state.floating.win) then
        vim.api.nvim_win_close(state.floating.win, true)
        state.floating.win = -1
    end
    print("Flominal: Cleared the buffer and window.")
end


-- Setup the plugin
---@param opts Flominal.options
function M.setup(opts)
    options = vim.tbl_deep_extend("force", defaults, opts or {})

    -- Initialize user command and keymapping
    vim.api.nvim_create_user_command(options.toggle.command_name, M.toggle_terminal, {})
    vim.keymap.set({ "n", "t" }, options.toggle.keymap, M.toggle_terminal, { desc = options.toggle.toggle_desc })

    -- Intended for use if the plugin crashes
    local cleanup_command_name = options.cleanup.cleanup_command_name or "FlominalClean"
    vim.api.nvim_create_user_command(cleanup_command_name, M.cleanup, { desc = options.cleanup.cleanup_desc })
    vim.keymap.set( { "n", "t" }, options.cleanup.cleanup_keymap, M.cleanup, { desc = options.cleanup.cleanup_desc } )
end


return M
