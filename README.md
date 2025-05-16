# Flominal

This plugin provides a somewhat customizable floating terminal.
Initially stolen from TJ DeVries. I'll work on it TJ, I promise :)

## Features

- Flominal is basically just a floating window working as a terminal.
- I recommend you to use the keymap whether it's the default or your own.
- Buffer is saved automatically and reused, and can be cleaned with the FlominalCleanup command or its keymap.
- When you open the window, either with the command or with the keymap, it automatically goes into terminal mode.

## Requirements

- Neovim >= 0.11.1 (didn't check for previous versions, I'll update this)

## Installation

### Lazy.nvim

```lua
return {
    'jayshozie/Flominal.nvim',
    branch = 'main',
    opts  = {},
}
```

## Configuration

Flominal comes with the following defaults:

```lua
{
    width = 0.6, -- 60% of the screen
    height = 0.6, -- 60% of the screen
    border = "rounded",
    command_name = "Flominal", -- Yes, you can change the name of the command.
    keymap = "<M-n>", -- Defaults to <M-n> (Alt+n)
    keymap_desc = "Toggle Flominal",
    cleanup_command_name = "FlominalClear", -- Yes, you can change the clear command, too.
    cleanup_keymap = "<M-c>",
    cleanup_keymap_desc = "<M-c> to cleanup Flominal",
}
```

## Usage

Use either the command or the keymap to toggle the floating window of Flominal.

## Contributions

This is more like a personal coding project for me.
So, mostly I'm trying to write it myself.
However, PRs are always welcome. 
If you would like to help me implement tab support, please let me know so that we can brainstorm about it.

# TO-DO

- [ ] Check required minimum Neovim version.
- [ ] Add tab support.
- [x] Add configuration options.
