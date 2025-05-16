-- local config = require("Flominal.config")


local M = {}

local state = {
    tabs = {},
    bufs = {},
    win = nil,
    last_buf = nil,
}

function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end



local function create_floating_win(buf)
    buf = buf or {}

    -- local width = math.floor(vim.o.columns * options.terminal.width)
    -- local height = math.floor(vim.o.lines * options.terminal.height)

    local width = math.floor(vim.o.columns * 0.6)
    local height = math.floor(vim.o.lines * 0.6)

    -- Calculate the position to center the window
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    -- Create a buffer
    if type(buf) == "number" and buf >= 0 and vim.api.nvim_buf_is_valid(buf) then
        state.last_buf = buf
    else
        buf = vim.api.nvim_create_buf(false, false)
        state.last_buf = buf
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
        border = "rounded",
        -- border = options.terminal.border,
    }

    -- Create the floating window
    local win = vim.api.nvim_open_win(buf, true, M.win_config)
    state.win = win

    return { buf = buf, win = win }
end

function M.init_terminal(win, buf)
    if vim.api.nvim_win_is_valid(win) and vim.bo[buf].buftype ~= 'terminal' then
        vim.api.nvim_set_current_win(win)
        vim.cmd('terminal')
        vim.cmd('startinsert')
    elseif vim.bo[buf].buftype == 'terminal' then
        vim.api.nvim_set_current_win(win)
        vim.cmd('startinsert')
    end
end

function M.toggle()
    if #state.bufs ~= 0 then
        if vim.api.nvim_win_is_valid(state.win) then
            vim.api.nvim_win_close(state.win, true)
        else
            create_floating_win(state.last_buf)
            vim.api.nvim_set_current_win(state.win)
            M.init_terminal(state.win, state.last_buf)
        end
    else
        create_floating_win()
        vim.api.nvim_set_current_win(state.win)
        M.init_terminal(state.win, state.last_buf)
    end
end

function M.new_tab()
    if state.last_buf ~= nil then
        vim.api.nvim_win_close(state.win, true)
        create_floating_win()
        vim.api.nvim_set_current_win(state.win)
        M.init_terminal(state.win, state.last_buf)
    end
end

function M.switch_tab(buf_to_switch)
    if vim.api.nvim_buf_is_valid(buf_to_switch) then
        vim.api.nvim_win_close(state.win, true)
        create_floating_win(buf_to_switch)
        M.init_term(state.win, state.last_buf)
    else
        print("Flominal: Tab is not available")
    end
end


function M.next_tab()
    if #state.bufs <= 1 then
        print("Flominal: No next tab")
    elseif #state.bufs > 1 then
        local indexOf_next_tab = indexOf(state.bufs, state.last_buf) + 1
        local next_tab = state.bufs[indexOf_next_tab]
        if vim.api.nvim_buf_is_valid(next_tab) then
            M.switch_tab(next_tab)
        elseif indexOf(state.bufs, next_tab) == 1 and vim.api.nvim_buf_isValid(next_tab) then
            M.switch_tab(next_tab)
        else
            print("Flominal: No next tab")
        end
    end
end

function M.prev_tab()
    if #state.bufs <= 1 then
        print("Flominal: No previous tab")
    elseif #state.bufs > 1 then
        local indexOf_prev_tab = indexOf(state.bufs, state.last_buf) - 1
        local prev_tab = state.bufs[indexOf_prev_tab]
        if vim.api.nvim_buf_is_valid(prev_tab) then
            M.switch_tab(prev_tab)
        elseif indexOf(state.bufs, prev_tab) == 1 and vim.api.nvim_buf_isValid(prev_tab) then
            M.switch_tab(prev_tab)
        else
            print("Flominal: No previous tab")
        end
    end
end

function M.cleanup()
    local i = 1
    vim.api.nvim_win_close(state.win, true)
    while i <= #state.bufs do
        vim.api.nvim_buf_delete(state.bufs[i], { force = true })
        state.bufs.remove(indexOf(state.bufs[i]))
        i = i + 1
    end
    state.wins = {}
    state.bufs = {}
end

vim.keymap.set({ "n", "t" }, "<M-a>", M.toggle)
vim.keymap.set({ "n", "t" }, "<M-+>", M.new_tab)
vim.keymap.set({ "n", "t" }, "<M-o>", M.cleanup)
vim.keymap.set({ "n", "t" }, "<M-e>", M.next_tab)
vim.keymap.set({ "n", "t" }, "<M-u>", M.prev_tab)
