-- MIT License
-- Copyright (c) 2025 Emir Baha Yıldırım
-- See LICENSE file for details.

-- core.lua

local M = {}

-- Defaults
M.options = {
    Flominal = {
        width = 0.6,
        height = 0.6,
        border = 'rounded',
        title = "Flominal",
        tab_name_length = 20,
    },
    commands = {
        toggle = "Flominal",
        new_tab = "new_tab",
        rename_tab = "rename_tab",
        switch_tab = "switch_tab",
        next_tab = "next_tab",
        prev_tab = "prev_tab",
        close_tab = "close_tab",
        cleanup = "cleanup",
    },
    keymaps = {
        k_toggle = "<M-n>",
        k_new_tab = "<M-N>",
        k_rename_tab = "<M-r>",
        k_switch_tab = "<M-g>",
        k_next_tab = "<M-u>",
        k_prev_tab = "<M-e>",
        k_close_tab = "<M-c>",
        k_cleanup = "<M-C>",
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
        term_current = nil,
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
    local tabs_height = 1

    -- Create a terminal buffer
    if type(term_buf) == "number" and term_buf >= 0 and vim.api.nvim_buf_is_valid(term_buf) then
        M.state.bufs.term_current = term_buf
    else
        term_buf = vim.api.nvim_create_buf(true, false)
        M.state.bufs.term_current = term_buf
        table.insert(M.state.bufs.all_term, term_buf)
    end

    -- Create a tab buffer if it doesn't exist
    if type(tabs_buf) == "number" and M.state.bufs.tabs_buf >= 0 and vim.api.nvim_buf_is_valid(M.state.bufs.tabs_buf) then
    else
        tabs_buf = vim.api.nvim_create_buf(true, true)
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

    -- Create the terminal window
    local term_win = vim.api.nvim_open_win(term_buf, true, M.term_win_config)
    M.state.wins.terminal = term_win

    M.tabs_win_config = {
        relative = "win",
        win = M.state.wins.terminal,
        width = tabs_width,
        height = tabs_height,
        -- focusable = false,
        anchor = "NW",
        row = -4,
        col = -1,
        zindex = 51,
        style = "minimal",
        border = M.options.Flominal.border,
        title = "Flominal",
        title_pos = "center",
    }


    -- Create the tabs window
    local tabs_win = vim.api.nvim_open_win(tabs_buf, false, M.tabs_win_config)
    M.state.wins.tabs = tabs_win
    M.init_tabs(M.state.wins.tabs)

    return { term_buf = term_buf, term_win = term_win, tabs_buf = tabs_buf, tabs_win = tabs_win }
end

function M.init_tabs(win)
    if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_buf_set_lines(M.state.bufs.tabs_buf, 0, -1, false, {}) -- Clear buffer

        local tab_line = ""

        for i, bufnr in ipairs(M.state.bufs.all_term) do
            local name = vim.api.nvim_buf_get_name(bufnr)
            local display_name = name
            local last_slash = string.find(name, "/[^/]*$")
            if last_slash then
                display_name = string.sub(name, last_slash + 1)
            end
            local truncated_name = string.sub(display_name, 1, M.options.Flominal.tab_name_length)
            local separator = " | "
            if i == #M.state.bufs.all_term then
                separator = ""
            end

            local tab_text = truncated_name
            -- Reverse highlight for current using theme
            if bufnr == M.state.bufs.term_current then
                tab_text = " < " .. tab_text .. " > "
            end

            tab_line = tab_line .. tab_text .. separator
        end

        vim.api.nvim_buf_set_lines(M.state.bufs.tabs_buf, 0, 1, false, { tab_line }) -- Set single line
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

function M.rename_tab(buf_to_rename)
    buf_to_rename = buf_to_rename or M.state.bufs.term_current
    if type(buf_to_rename) == "string" and buf_to_rename ~= nil and buf_to_rename ~= '' then
        for i, bufnr in ipairs(M.state.bufs.all_term) do
            local name = vim.api.nvim_buf_get_name(bufnr)
            local display_name = name
            local last_slash = string.find(name, "/[^/]*$")
            if last_slash then
                display_name = string.sub(name, last_slash + 1)
            end
            if buf_to_rename == display_name then
                buf_to_rename = bufnr
                break
            end
        end
    end
    if buf_to_rename ~= nil and buf_to_rename ~= '' and vim.api.nvim_buf_is_valid(buf_to_rename) then
        local old_buf_name = vim.api.nvim_buf_get_name(buf_to_rename)
        local new_buf_name = vim.fn.input(old_buf_name .. " -> ")
        vim.api.nvim_buf_set_name(buf_to_rename, new_buf_name)
        M.init_tabs(M.state.wins.tabs)
    else
        print("Flominal: Error while renaming the tab.")
    end
end

function M.toggle()
    if M.state.bufs.term_current ~= nil and M.state.bufs.tabs_buf ~= nil then
        if vim.api.nvim_win_is_valid(M.state.wins.terminal) and vim.api.nvim_win_is_valid(M.state.wins.tabs) then
            vim.api.nvim_win_hide(M.state.wins.terminal)
            vim.api.nvim_win_hide(M.state.wins.tabs)
        elseif not vim.api.nvim_win_is_valid(M.state.wins.terminal) and vim.api.nvim_win_is_valid(M.state.wins.tabs) then
            vim.api.nvim_win_hide(M.state.wins.tabs)
        elseif vim.api.nvim_win_is_valid(M.state.wins.terminal) and not vim.api.nvim_win_is_valid(M.state.wins.tabs) then
            vim.api.nvim_win_hide(M.state.wins.terminal)
        else
            open(M.state.bufs.term_current, M.state.bufs.tabs_buf)
            vim.api.nvim_set_current_win(M.state.wins.terminal)
            M.init_terminal(M.state.wins.terminal, M.state.bufs.term_current)
            M.init_tabs(M.state.wins.tabs)
        end
    else
        open()
        vim.api.nvim_set_current_win(M.state.wins.terminal)
        M.init_terminal(M.state.wins.terminal, M.state.bufs.term_current)
        M.init_tabs(M.state.wins.tabs)
    end
end

function M.new_tab()
    if vim.api.nvim_win_is_valid(M.state.wins.terminal) and vim.api.nvim_win_is_valid(M.state.wins.tabs) then
        local new_buf = vim.api.nvim_create_buf(true, false)
        table.insert(M.state.bufs.all_term, new_buf)
        M.state.bufs.term_current = new_buf
        vim.api.nvim_win_hide(M.state.wins.terminal)
        vim.api.nvim_win_hide(M.state.wins.tabs)
        open(new_buf, M.state.bufs.tabs_buf)
        vim.api.nvim_set_current_win(M.state.wins.terminal)
        M.init_terminal(M.state.wins.terminal, M.state.bufs.term_current)
        M.init_tabs(M.state.wins.tabs)
    else
        print("Flominal: Error while creating a new tab.")
    end
end

function M.switch_tab(buf_name_to_switch)
    buf_name_to_switch = buf_name_to_switch or nil

    local buf_to_switch = nil
    local is_valid = false

    if type(buf_name_to_switch) == "number" and vim.api.nvim_buf_is_valid(buf_name_to_switch) then
        buf_to_switch = buf_name_to_switch
    elseif type(buf_name_to_switch) == "number" and not vim.api.nvim_buf_is_valid(buf_name_to_switch) then
        print("Flominal: Tab not found, buffer number is invalid")
    elseif buf_name_to_switch == nil or buf_to_switch == '' then
        buf_to_switch = vim.fn.input("Enter the name of the tab: ")
    end

    if type(buf_to_switch) == "number" and buf_to_switch ~= nil and buf_to_switch ~= '' then
        if vim.api.nvim_buf_is_valid(buf_to_switch) then
            is_valid = true
        else
            is_valid = false
            print("Flominal: Tab not found, buffer number is invalid")
        end
    elseif buf_to_switch ~= nil and buf_to_switch ~= '' and type(buf_to_switch) == "string" then
        print("Flominal: Searching for tab: " .. buf_to_switch)
        vim.wait(2000)
        print("Flominal: Searching tab in all buffers: " .. vim.inspect(M.state.bufs.all_term))
        vim.wait(2000)
        for _, bufnr in ipairs(M.state.bufs.all_term) do
            print("Flominal: Checking buffer: " .. bufnr)
            vim.wait(2000)
            local name = vim.api.nvim_buf_get_name(bufnr)
            local display_name = name
            local last_slash = string.find(name, "/[^/]*$")
            if last_slash then
                display_name = string.sub(name, last_slash + 1)
            end
            print("Flominal: Checking buffer name: " .. display_name)
            vim.wait(2000)
            if buf_name_to_switch == display_name then
                buf_to_switch = bufnr
                break
            end
        end

        if type(buf_to_switch) == "number" and buf_to_switch ~= nil and buf_to_switch ~= '' then
            if vim.api.nvim_buf_is_valid(buf_to_switch) then
                is_valid = true
            else
                is_valid = false
                print("Flominal: Tab not found, buffer could not be found.")
            end
        else
            is_valid = false
            print("Flominal: Tab not found, something went wrong.")
        end
    else
        is_valid = false
        print("Flominal: Tab not found, buffer name is invalid.")
    end

    if is_valid then
        if vim.api.nvim_win_is_valid(M.state.wins.terminal) and vim.api.nvim_win_is_valid(M.state.wins.tabs) then
            vim.api.nvim_win_hide(M.state.wins.terminal)
            vim.api.nvim_win_hide(M.state.wins.tabs)
            M.state.bufs.last_term_buf = M.state.bufs.term_current
            M.state.bufs.term_current = buf_to_switch
            open(M.state.bufs.term_current, M.state.bufs.tabs_buf)
            M.init_terminal(M.state.wins.terminal, M.state.bufs.term_current)
            M.init_tabs(M.state.wins.tabs)
        elseif vim.api.nvim_buf_is_valid(M.state.bufs.term_current) and vim.api.nvim_buf_is_valid(M.state.bufs.tabs_buf) and
            not vim.api.nvim_win_is_valid(M.state.wins.terminal) and not vim.api.nvim_win_is_valid(M.state.wins.tabs) then

            M.state.bufs.last_term_buf = M.state.bufs.term_current
            M.state.bufs.term_current = buf_to_switch
            open(M.state.bufs.term_current, M.state.bufs.tabs_buf)
            M.init_terminal(M.state.wins.terminal, M.state.bufs.term_current)
            M.init_tabs(M.state.wins.tabs)
        else
            print("Flominal: Error while switching the tab.")
        end
    else
        print("Flominal: Tab not found, something went wrong.")
    end
end

function M.next_tab()
    if #M.state.bufs.all_term <= 1 then
        print("Flominal: No next tab")
    else
        local indexOf_next_buf = M.indexOf(M.state.bufs.all_term, M.state.bufs.term_current) + 1
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
        local indexOf_prev_buf = M.indexOf(M.state.bufs.all_term, M.state.bufs.term_current) - 1
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
    if vim.api.nvim_win_is_valid(M.state.wins.terminal) then
        if #M.state.bufs.all_term < 1 then
            print("Flominal: No tab available.")
        elseif #M.state.bufs.all_term >= 1 then
            local last_buf = M.state.bufs.term_current
            M.next_tab()
            M.state.bufs.last_term_buf = last_buf
            vim.api.nvim_buf_delete(M.state.bufs.last_term_buf, { force = true })
            table.remove(M.state.bufs.all_term, M.indexOf(M.state.bufs.all_term, M.state.bufs.last_term_buf))
            M.init_tabs(M.state.wins.tabs)
        else
            M.cleanup()
        end
    else
        print("Flominal: Cannot close a tab if it's not open")
    end
end

function M.cleanup()
    if vim.api.nvim_win_is_valid(M.state.wins.terminal) and vim.api.nvim_win_is_valid(M.state.wins.tabs) then
        vim.api.nvim_win_close(M.state.wins.terminal, true)
        vim.api.nvim_win_close(M.state.wins.tabs, true)
        vim.api.nvim_buf_delete(M.state.bufs.tabs_buf, { force = true })
    end
    while 1 <= #M.state.bufs.all_term do
        vim.api.nvim_buf_delete(M.state.bufs.all_term[1], { force = true })
        table.remove(M.state.bufs.all_term, 1)
    end
    M.state.bufs.all_term = {}
    M.state.bufs.tabs_buf = nil
    M.state.wins.terminal = nil
    M.state.wins.tabs = nil
    M.state.bufs.term_current = nil
    M.state.bufs.last_term_buf = nil
end

-- Define subcommands list for completion
local subcommands = {
    "toggle",
    "new_tab",
    "rename_tab",
    "switch_tab",
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
    elseif subcmd == 'rename_tab' then
        M.rename_tab(M.state.bufs.term_current)
    elseif subcmd == 'switch_tab' then
        M.switch_tab()
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
