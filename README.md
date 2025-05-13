# Flominal

This plugin provides a somewhat customizable floating terminal.
Initially stolen from TJ DeVries. I'll work on it TJ, I promise :)

## Features

- Flominal is basically just a floating window working as a terminal.
- Buffer is saved, and also can be cleaned.

## Requirements

- Neovim >= 0.11.0 (didn't check for previous version, I'll update this)

## Installation

### Lazy.nvim

```
return {
    'jayshozie/Flominal.nvim',
    branch = 'main',
    opts  = {},
}
```

## Configuration

Flominal comes with the following defaults:

```
defaults = {
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
```

## Usage

Use either the command or the keymap to open the floating window.

# TO-DO

- [ ] Add tab support.
- [x] Add configuration options.
