local M = {}

-- Defaults
M.options = {
    terminal = {
        width = 0.6,
        height = 0.6,
        border = 'rounded',
    },
    commands = {
        toggle = "Flominal",
        new_tab = "new_tab",
        next_tab = "next_tab",
        prev_tab = "prev_tab",
        close_tab = "close_tab",
        cleanup = "cleanup",
    },
    keymaps = {
        k_toggle = "<M-n>",
        k_new_tab = "<M-a>",
        k_next_tab = "<M-e>",
        k_prev_tab = "<M-u>",
        k_close_tab = "<M-o>",
        k_cleanup = "<M-c>",
    },

}

local state = {
    bufs = {},
    win = nil,
    current_buf = nil,
    last_buf = nil,
}

function M.indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end



local function create_floating_win(buf)
    buf = buf or nil

    local width = math.floor(vim.o.columns * M.options.terminal.width)
    local height = math.floor(vim.o.lines * M.options.terminal.height)

    -- Calculate the position to center the window
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    -- Create a buffer
    if type(buf) == "number" and buf >= 0 and vim.api.nvim_buf_is_valid(buf) then
        state.current_buf = buf
    else
        buf = vim.api.nvim_create_buf(false, false)
        state.current_buf = buf
        table.insert(state.bufs, buf)
    end

    -- Define window configuration
    M.win_config = {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = M.options.terminal.border,
    }

    -- Create the floating window
    state.win = vim.api.nvim_open_win(buf, true, M.win_config)
    local win = state.win

    return { buf = buf, win = win }
end

function M.init_terminal(win, buf)
    if vim.api.nvim_win_is_valid(win) then
        if vim.bo[buf].buftype ~= 'terminal' then
            vim.api.nvim_set_current_win(win)
            vim.cmd('terminal')
            vim.cmd('startinsert')
        elseif vim.bo[buf].buftype == 'terminal' then
            vim.api.nvim_set_current_win(win)
            vim.cmd('startinsert')
        end
    else
        print("Flominal: Error while initiating terminal.")
    end
end

function M.toggle()
    if #state.bufs ~= 0 then
        if vim.api.nvim_win_is_valid(state.win) then
            vim.api.nvim_win_hide(state.win)
        else
            create_floating_win(state.current_buf)
            vim.api.nvim_set_current_win(state.win)
            M.init_terminal(state.win, state.current_buf)
        end
    else
        create_floating_win()
        vim.api.nvim_set_current_win(state.win)
        M.init_terminal(state.win, state.current_buf)
    end
end

function M.new_tab()
    if state.current_buf ~= nil then
        state.last_buf = state.current_buf
        state.current_buf = nil
        vim.api.nvim_win_hide(state.win)
        create_floating_win()
        vim.api.nvim_set_current_win(state.win)
        M.init_terminal(state.win, state.current_buf)
    end
end

function M.switch_tab(buf_to_switch)
    if vim.api.nvim_buf_is_valid(buf_to_switch) then
        vim.api.nvim_win_hide(state.win)
        state.last_buf = state.current_buf
        state.current_buf = buf_to_switch
        create_floating_win(state.current_buf)
        M.init_terminal(state.win, state.current_buf)
    else
        print("Flominal: Tab is not available")
    end
end


function M.next_tab()
    if #state.bufs <= 1 then
        print("Flominal: No next tab")
    else
        local indexOf_next_buf = M.indexOf(state.bufs, state.current_buf) + 1
        if indexOf_next_buf > #state.bufs then
            indexOf_next_buf = 1
        end
        local next_buf = state.bufs[indexOf_next_buf]
        if M.indexOf(state.bufs, next_buf) ~= 1 and vim.api.nvim_buf_is_valid(next_buf) then
            M.switch_tab(next_buf)
        elseif M.indexOf(state.bufs, next_buf) == 1 and vim.api.nvim_buf_is_valid(next_buf) then
            M.switch_tab(next_buf)
        else
            print("Flominal: No next tab")
        end
    end
end

function M.prev_tab()
    if #state.bufs <= 1 then
        print("Flominal: No previous tab")
    else
        local indexOf_prev_buf = M.indexOf(state.bufs, state.current_buf) - 1
        if indexOf_prev_buf == 0 then
            indexOf_prev_buf = #state.bufs
        end
        local prev_buf = state.bufs[indexOf_prev_buf]
        if M.indexOf(state.bufs, prev_buf) ~= #state.bufs and vim.api.nvim_buf_is_valid(prev_buf) then
            M.switch_tab(prev_buf)
        elseif M.indexOf(state.bufs, prev_buf) == #state.bufs and vim.api.nvim_buf_is_valid(prev_buf) then
            M.switch_tab(prev_buf)
        else
            print("Flominal: No previous tab")
        end
    end
end

function M.close_tab()
    if vim.api.nvim_win_is_valid(state.win) then
        state.last_buf = state.current_buf
        M.next_tab()
        vim.api.nvim_buf_delete(state.last_buf, { force = true })
        table.remove(state.bufs, M.indexOf(state.bufs, state.last_buf))
    else
        print("Flominal: Cannot close a tab if it's not open")
    end
end

function M.cleanup()
    if vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_close(state.win, true)
    end
    while 1 <= #state.bufs do
        vim.api.nvim_buf_delete(state.bufs[1], { force = true })
        table.remove(state.bufs, 1)
    end
    state.bufs = {}
    state.win = nil
    state.current_buf = nil
    state.last_buf = nil
end



-- Deep merge helper
local function merge_defaults(defaults, overrides)
    if not overrides then return defaults end
    for key, value in pairs(overrides) do
        if type(value) == "table" and type(defaults[key]) == "table" then
            merge_defaults(defaults[key], value)
        else
            defaults[key] = value
        end
    end
    return defaults
end


-- Setup function
function M.setup(user_options)
    M.options = merge_defaults(M.options, user_options)

    -- Define subcommands list for completion
    local subcommands = {
        "toggle",
        "new_tab",
        "next_tab",
        "prev_tab",
        "close_tab",
        "cleanup",
    }

    -- Main Flominal command with optional argument for subcommands
    vim.api.nvim_create_user_command('Flominal', function(opts)
        local subcmd = opts.args
        if subcmd == nil or subcmd == '' or subcmd == 'toggle' then
            M.toggle()
        elseif subcmd == 'new_tab' then
            M.new_tab()
        elseif subcmd == 'next_tab' then
            M.next_tab()
        elseif subcmd == 'prev_tab' then
            M.prev_tab()
        elseif subcmd == 'close_tab' then
            M.close_tab()
        elseif subcmd == 'cleanup' then
            M.cleanup()
        else
            print("Flominal: Unknown subcommand: " .. subcmd)
        end
    end, {
        nargs = '?',  -- zero or one argument
        complete = function(arg_lead)
            -- Simple completion: filter subcommands starting with arg_lead
            local result = {}
            for _, cmd in ipairs(subcommands) do
                if vim.startswith(cmd, arg_lead) then
                    table.insert(result, cmd)
                end
            end
            return result
        end,
    })

    -- Register keymaps (same as before)
    local km = M.options.keymaps
    for k, lhs in pairs(km) do
        if lhs and lhs ~= "" then
            local fn_name = k:sub(3)
            local fn = M[fn_name]
            if type(fn) == "function" then
                vim.keymap.set({"n", "t"}, lhs, fn, { noremap = true, silent = true, desc = "Flominal: " .. fn_name })
            end
        end
    end
end


return M
