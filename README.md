# Flominal

This plugin provides a somewhat customizable floating terminal.
Initially yanked from TJ DeVries. I'll work on it TJ, I promise :)

## Features

- Flominal is basically just a floating window working as a terminal.
- You can create new tabs using `:Flominal new_tab` command or its keymap.
- It has a separate window for a tab bar, which is placed on the top of the terminal.
- On the tab bar, you can see the name of the tabs, and you can rename them via
    the `:Flominal rename_tab` command or its keymap.
- You can switch between tabs using `:Flominal switch_tab` and just writing
    the name of the tab you want to switch to. (This is problematic if there
    are multiple tabs with the same name.)
- You can also switch between tabs using `:Flominal next_tab` and
    `:Flominal prev_tab` commands or their keymaps. Their default keymaps are
    `<M-l>` and `<M-r>` respectively, because Dvorak.
- You can close the current terminal tab using `:Flominal close_tab` command or its keymap.
- Buffers are saved automatically and reused, and can be cleaned with `:Flominal cleanup` command or its keymap.
- When you open the window, either with the command or with the keymap, it automatically goes into terminal mode.
- I recommend you to use the keymaps whether they are the defaults or your own.

## Requirements

- Neovim >= 0.7.0 (I may have missed some features, but I will try to keep it compatible with older versions)
- Lazy.nvim (or any other plugin manager)
- No other dependencies, I do not like dependencies.

## Installation

### Lazy.nvim

```lua
-- Flominal.nvim
return {
    'jayshozie/Flominal.nvim',
    branch = 'main',
    opts  = {
        -- This is where you can set the configuration options.
        -- See the Configuration section below for more details.
    },
}
```

## Configuration

Flominal comes with the following defaults:

```lua
-- Flominal/core.lua
{
    Flominal = {
        width = 0.6, -- This should be in the range (0.0, 1.0)
        height = 0.6, -- This should be in the range (0.0, 1.0)
        border = 'rounded',
        -- Border options are, 'none', 'single', 'double', 'rounded', 'solid', 'shadow'
        -- These are the default options for floating windows in Neovim.
        title = "Flominal",
        -- Yes you can change this too, if you want to.
        tab_name_length = 20, -- In characters
        -- This is the maximum length of the tab name, so that you can see all
        -- the tabs in the tab bar. If you plan to use a lot of tabs, you
        -- can decrease this value. I have not implemented a way for the tab
        -- bar to scroll, so if you have a lot of tabs, you will not be able to
        -- see all of them. I will implement this in the future.
    },
    commands = {
        -- These are the commands that you can use to open Flominal.
        -- I do not recommend you to use new_tab for toggling the window, since
        -- it checks whether the window is open or not, and if it isn't then
        -- it doesn't do anything.
        -- You can toggle with :Flominal, then you can add whichever command
        -- you want from the command list to execute.
        -- Example: :Flominal new_tab
        toggle = "Flominal",
        new_tab = "new_tab",
        rename_tab = "rename_tab",
        switch_tab = "switch_tab", -- This is the command to switch between tabs.
        next_tab = "next_tab", -- Yes this also circles back to the first tab.
        prev_tab = "prev_tab", -- Yes this also circles back to the last tab.
        close_tab = "close_tab", -- Only works if a tab is open/on the screen.
        cleanup = "cleanup",
    },
    keymaps = {
        -- These are the keymaps that you can use to interact with Flominal.
        -- I do not recommend you to use the commands for that, because it
        -- is not as convenient as using the keymaps, sorry couldn't think of
        -- a better/shorter name for the plugin.
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
```

## Usage

Use either the corresponding command or the keymap to toggle the floating window of Flominal.

## License

Every file in this repository is licensed under the MIT License. Check the [LICENSE](LICENSE) file for more details.

## Contributions

This is more like a personal coding project for me.
So, mostly I'm trying to write it myself.
However, PRs are always welcome. 

# TO-DO

- [ ] Write documentation.
- [ ] Make the switch_tab command accept relative tab numbers, instead of bufnrs.
    Also this would be a good time to implement a way to see the tab numbers.
- [ ] Add mouse support (maybe).
- [ ] Add a way to scroll the tab bar.
- [x] Check minimum required Neovim version.
- [x] Add tab support.
- [x] Add configuration options.
