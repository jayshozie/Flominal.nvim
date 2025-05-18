-- core.lua

local M = {}

-- Defaults
M.options = {
    Flominal = {
        width = 0.6,
        height = 0.6,
        border = 'rounded',
        title = "Flominal",
        tab_name_length = 12,
    },
    commands = {
        toggle = "Flominal",
        new_tab = "new_tab",
        next_tab = "next_tab",
        prev_tab = "prev_tab",
        close_tab = "close_tab",
        cleanup = "cleanup",
        tabs = "tabs",
    },
    keymaps = {
        k_toggle = "<M-n>",
        k_new_tab = "<M-a>",
        k_next_tab = "<M-e>",
        k_prev_tab = "<M-u>",
        k_close_tab = "<M-o>",
        k_cleanup = "<M-c>",
        k_tabs = "<M-m>",
    },

}

-- Flominal's state
M.state = {
    wins = {
        terminal = nil,
        tabs = nil,
    },
    bufs = {
        all_term = {},
        term_current = nil, -- Can be used to show which tab is open, reverse highlighting
        last_term_buf = nil,
        tabs_buf = nil,
    },
}

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

function M.indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

local function open(term_buf, tabs_buf)
    term_buf = term_buf or nil
    tabs_buf = tabs_buf or nil

    -- Calculate the dimensions of the terminal window
    local term_width = math.floor(vim.o.columns * M.options.Flominal.width)
    local term_height = math.floor(vim.o.lines * M.options.Flominal.height)

    -- Calculate the position of the terminal window to center it
    local term_col = math.floor((vim.o.columns - term_width) / 2)
    local term_row = math.floor((vim.o.lines - term_height) / 2)

    -- Calculate the dimensions of the tabs window
    local tabs_width = term_width
    local tabs_height = 2

    -- Calculate the position of the tabs window relative to the terminal window
    local tabs_col = -term_col
    local tabs_row = 0

    -- Create a terminal buffer
    if type(term_buf) == "number" and term_buf >= 0 and vim.api.nvim_buf_is_valid(term_buf) then
        M.state.bufs.term_current = term_buf
    else
        term_buf = vim.api.nvim_create_buf(true, false)
        M.state.bufs.term_current = term_buf
        table.insert(M.state.bufs.all_term, term_buf)
    end

    -- Create a tab buffer if it doesn't exist
    if type(tabs_buf) == "number" and M.state.tabs_buf >= 0 and vim.api.nvim_buf_is_valid(M.state.tabs_buf) then
    else
        tabs_buf = vim.api.nvim_create_buf(true, false)
        M.state.bufs.tabs_buf = tabs_buf
    end

    -- Define window configuration
    M.term_win_config = {
        relative = "editor",
        width = term_width,
        height = term_height,
        col = term_col,
        row = term_row,
        style = "minimal",
        border = M.options.Flominal.border,
    }

    M.tabs_win_config = {
        relative = "win",
        win = M.state.wins.terminal,
        width = tabs_width,
        height = tabs_height,
        -- focusable = false,
        anchor = "NW",
        row = -5,
        col = -1,
        zindex = 51,
        style = "minimal",
        border = M.options.Flominal.border,
        title = "Flominal",
        title_pos = "center",
    }

    -- Create the terminal window
    local term_win = vim.api.nvim_open_win(term_buf, true, M.term_win_config)
    M.state.wins.terminal = term_win

    -- Create the tabs window
    local tabs_win = vim.api.nvim_open_win(M.state.bufs.tabs_buf, false, M.tabs_win_config)
    M.state.wins.tabs = tabs_win
    M.init_tabs(M.state.wins.tabs)

    return { term_buf = term_buf, term_win = term_win, tabs_buf = tabs_buf, tabs_win = tabs_win }
end

function M.init_tabs(win)
    if vim.api.nvim_win_is_valid(win) then
        if not M.state.tabs_buf then
            return
        end

        vim.api.nvim_buf_set_lines(M.state.tabs_buf, 0, -1, false, {})   -- Clear buffer
        local tab_line = ""

        for i, bufnr in ipairs(M.state.bufs.all_term) do
            local name = vim.api.nvim_buf_get_name(bufnr)
            local truncated_name = string.sub(name, 1, M.options.Flominal.tab_name_length)
            local separator = " | "
            if i == #M.state.bufs then
                separator = ""
            end

            local tab_text = truncated_name
            if bufnr == M.state.current_buf then
                tab_text = "%#FlominalTabActive#" .. tab_text .. "%*"
            end

            tab_line = tab_line .. tab_text .. separator
        end

        vim.api.nvim_buf_set_lines(M.state.tabs_buf, 0, 1, false, { tab_line }) -- Set single line
    end
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
        print("Flominal: Error while initiating the terminal.")
    end
end

function M.toggle()
    if M.state.bufs.term_current ~= nil then
        if vim.api.nvim_win_is_valid(M.state.wins.terminal) then
            vim.api.nvim_win_hide(M.state.wins.terminal)
            vim.api.nvim_win_hide(M.state.wins.tabs)
        else
            open(M.state.bufs.term_current)
            vim.api.nvim_set_current_win(M.state.wins.terminal)
            M.init_terminal(M.state.wins.terminal, M.state.bufs.term_current)
        end
    else
        open()
        vim.api.nvim_set_current_win(M.state.wins.terminal)
        M.init_terminal(M.state.wins.terminal, M.state.bufs.term_current)
    end
end

function M.new_tab()
    if M.state.bufs.term_current ~= nil then
        M.state.last_term_buf = M.state.bufs.term_current
        M.state.bufs.term_current = nil
        vim.api.nvim_win_hide(M.state.wins.parent)
        open()
        vim.api.nvim_set_current_win(M.state.wins.parent)
        M.init_terminal(M.state.wins.parent, M.state.bufs.term_current)
    end
end

function M.switch_tab(buf_to_switch)
    if vim.api.nvim_buf_is_valid(buf_to_switch) then
        vim.api.nvim_win_hide(M.state.wins.parent)
        M.state.last_term_buf = M.state.bufs.term_current
        M.state.bufs.term_current = buf_to_switch
        open(M.state.bufs.term_current)
        M.init_terminal(M.state.wins.parent, M.state.bufs.term_current)
    else
        print("Flominal: Tab is not available")
    end
end

function M.next_tab()
    if #M.state.bufs.all_term <= 1 then
        print("Flominal: No next tab")
    else
        local indexOf_next_buf = M.indexOf(M.state.bufs.all_term, M.state.buf.term_current) + 1
        if indexOf_next_buf > #M.state.bufs.all_term then
            indexOf_next_buf = 1
        end
        local next_buf = M.state.bufs.all_term[indexOf_next_buf]
        if M.indexOf(M.state.bufs.all_term, next_buf) ~= 1 and vim.api.nvim_buf_is_valid(next_buf) then
            M.switch_tab(next_buf)
        elseif M.indexOf(M.state.bufs.all_term, next_buf) == 1 and vim.api.nvim_buf_is_valid(next_buf) then
            M.switch_tab(next_buf)
        else
            print("Flominal: No next tab")
        end
    end
end

function M.prev_tab()
    if #M.state.bufs.all_term <= 1 then
        print("Flominal: No previous tab")
    else
        local indexOf_prev_buf = M.indexOf(M.state.bufs.all_term, M.state.buf.term_current) - 1
        if indexOf_prev_buf == 0 then
            indexOf_prev_buf = #M.state.bufs.all_term
        end
        local prev_buf = M.state.bufs.all_term[indexOf_prev_buf]
        if M.indexOf(M.state.bufs.all_term, prev_buf) ~= #M.state.bufs and vim.api.nvim_buf_is_valid(prev_buf) then
            M.switch_tab(prev_buf)
        elseif M.indexOf(M.state.bufs.all_term, prev_buf) == #M.state.bufs and vim.api.nvim_buf_is_valid(prev_buf) then
            M.switch_tab(prev_buf)
        else
            print("Flominal: No previous tab")
        end
    end
end

function M.close_tab()
    if vim.api.nvim_win_is_valid(M.state.wins.parent) then
        M.state.last_term_buf = M.state.bufs.term_current
        if #M.state.bufs.all_term < 1 then
            print("Flominal: No other tab available.")
        else
            M.next_tab()
        end
        vim.api.nvim_buf_delete(M.state.last_term_buf, { force = true })
        table.remove(M.state.bufs.all_term, M.indexOf(M.state.bufs, M.state.last_term_buf))
    else
        print("Flominal: Cannot close a tab if it's not open")
    end
end

function M.cleanup()
    if vim.api.nvim_win_is_valid(M.state.wins.parent) then
        vim.api.nvim_win_close(M.state.wins.parent, true)
    end
    while 1 <= #M.state.bufs.all_term do
        vim.api.nvim_buf_delete(M.state.bufs.all_term[1], { force = true })
        table.remove(M.state.bufs.all_term, 1)
    end
    M.state.bufs.all_term = {}
    M.state.wins.parent = nil
    M.state.bufs.term_current = nil
    M.state.last_term_buf = nil
end

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
    nargs = '?', -- zero or one argument
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

-- Setup function
function M.setup(user_options)
    M.options = merge_defaults(M.options, user_options)


    -- Register keymaps (same as before)
    local km = M.options.keymaps
    for k, lhs in pairs(km) do
        if lhs and lhs ~= "" then
            local fn_name = k:sub(3)
            local fn = M[fn_name]
            if type(fn) == "function" then
                vim.keymap.set({ "n", "t" }, lhs, fn, { noremap = true, silent = true, desc = "Flominal: " .. fn_name })
            end
        end
    end
end

return M
