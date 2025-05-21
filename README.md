# Flominal.nvim

This plugin provides a somewhat customizable, absolutely over-engineered
floating window terminal.
Initially yanked from [TJ DeVries](https://github.com/tjdevries)'s
[video](https://www.youtube.com/watch?v=5PIiKDES_wc).
I'll work on it TJ, I promise :)

## About Legacy Version

If you don't like the tab functionality, and the things come with it, you can
use the [legacy](https://github.com/jayshozie/Flominal.nvim/tree/legacy)
version of the plugin. However, it is not maintained anymore. Well it's not
a big deal, since the legacy version is just a single file and incredibly
simple.

## Features

- Flominal is basically just a floating window working as a terminal.
- You can toggle Flominal with `:Flominal`, `:Flominal toggle` command or
    its keymap.
- You can create new tabs using `:Flominal new_tab` command or its keymap.
- It has a separate window for a tab bar, which is placed on the top of the
    terminal.
- On the tab bar, you can see the name of the tabs, and you can rename them via
    the `:Flominal rename_tab` command or its keymap.
- You can switch between tabs using `:Flominal switch_tab` and just writing
    the name of the tab you want to switch to. (This may be problematic if
    there are multiple tabs with the same name.)
- You can also switch between tabs using `:Flominal prev_tab` and
    `:Flominal next_tab` commands or their keymaps. Their default keymaps are
    `<M-u>` and `<M-e>` respectively, because dvorak.
- You can close the current terminal tab using `:Flominal close_tab` command
    or its keymap.
- Buffers are saved automatically and reused, and can be cleaned with
    `:Flominal cleanup` command or its keymap.
- When you open the window, either with the command or with the keymap, it
    automatically goes into terminal mode.
- I recommend you to use the keymaps whether they are the defaults or your own.

## Requirements

- Neovim >= 0.7.0 (I may be wrong.)
- [lazy.nvim](https://github.com/folke/lazy.nvim) (or any other plugin manager)
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

Flominal comes with the following defaults, please check the documentation
for more details:

```lua
-- Flominal/core.lua
{
    Flominal = {
        width = 0.6,
        height = 0.6,
        border = 'rounded',
        title = "Flominal",
        -- Yes you can change this too, if you want to.
        tab_name_length = 20,
        -- This is how many characters before tabline truncates it.
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
```

## Usage

Use either the corresponding command or the keymap to use the functionalities
of Flominal.

## License

Every file in this repository is licensed under the MIT License.
Check the [LICENSE](LICENSE) file for more details.

## Contributions

This is more like a personal coding project for me. So, mostly I'm trying to do
everything myself; however, PRs are, and always will be, welcome. 

# TO-DO

- [ ] Make the switch_tab command accept relative tab numbers, instead of
    bufnrs. Also this would be a good time to implement a way to see the tab
    numbers.
- [ ] Add mouse support (maybe).
- [ ] Add a way to scroll the tab bar.
- [x] Add documentation.
- [x] Check minimum required Neovim version.
- [x] Add tab support.
- [x] Add configuration options.
