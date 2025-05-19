# Flominal Legacy

This plugin provides a somewhat customizable floating terminal.
Initially yanked from [TJ DeVries](https://github.com/tjdevries)'s 
[video](https://www.youtube.com/watch?v=5PIiKDES_wc).
I'll work on it TJ, I promise :)

## About Legacy Version

This is the legacy version of Flominal, which does NOT support tabbing.
If you want tab functionality take a look at the
[main branch](https://github.com/jayshozie/Flominal.nvim/tree/main).
This version should be faster but is not maintained anymore. Well it's not like
it needs maintenance.
If you find a bug, please do open an issue. I'll look into it.

## Features

- Flominal is basically just a floating window working as a terminal.
- I recommend you to use the keymap whether it's the default or your own.
- You can toggle Flominal with `:Flominal` or with the keymap.
- Buffer is saved automatically and reused, and can be cleaned with the
    `:FlominalCleanup` command or its keymap.
- When you open the window, either with the command or with the keymap, it
    automatically goes into terminal mode.

## Requirements

- Neovim >= 0.7.0 (I'm not sure.)
- [lazy.nvim](https://github.com/folke/lazy.nvim) (or any other plugin manager)

## Installation

### Lazy.nvim

```lua
return {
    'jayshozie/Flominal.nvim',
    branch = 'legacy',
    opts  = {},
}
```

## Configuration

Flominal, version legacy, comes with the following defaults.

```lua
{
    width = 0.6, -- 60% of the screen
    height = 0.6, -- 60% of the screen
    border = "rounded", -- "single", "double", "shadow", "rounded", "solid", or "none"
    command_name = "Flominal", -- Yes, you can change the name of the command.
    keymap = "<M-n>",
    keymap_desc = "Toggle Flominal",
    cleanup_command_name = "FlominalClear", -- Yes, you can change the clear command, too.
    cleanup_keymap = "<M-c>",
    cleanup_keymap_desc = "<M-c> to cleanup Flominal",
}
```

## Usage

Use either the command or the keymap to toggle the floating window of Flominal.

## License

Every file in this repository is licensed under the MIT license. Check the
[LICENSE](LICENSE) file for more details.

## Contributions

This is more like a personal coding project for me.
So, mostly I'm trying to write it myself.
However, PRs are always welcome. 

# TO-DO

- [ ] Add documentation. Not that it needs it, but it would be nice to have.
- [x] Check required minimum Neovim version.
- [x] Add tab support. Check out the
    [main branch](https://github.com/jayshozie/Flominal.nvim/tree/main).
- [x] Add configuration options.
