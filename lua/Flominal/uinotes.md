Helper notes markdown for ui.lua

What is expected?

- [ ] A separate tabcol buffer to show which tabs are open
- [ ] The terminal buffers and tabcol buffers will be split in a single window
- [ ] A dynamically calculated fixed row count to know how many tabs can be
    shown at any point.
- [ ] A dynamically calculated fixed column count to know how many characters
    of buffer names will be shown.
- [ ] Should the number be the bufnr of the buffers or a separate indexing sys?
    Should numbers even be shown? If yes how to handle the numbering system
    when a tab is closed (e.g. Open Tabs: 1, 5, 8, 9 etc.)
- [ ] When this is working without issues, we can think about adding mouse
    control support.

What is needed?

- [ ] We need to change how we open a floating window, since the backend
    handles it right now. ui.lua should handle it and it should open a
    floating window, then loading the terminal buffer in it, splitting the
    window, and loading the tabcol buffer into the split. This loading system
    should be easier to implement if the user wants to put the tabcol to the
    right side of the terminal buffer.
- [ ] We need functions to calculate the column and row counts. It should also
    use the user defined height and length data of the Flominal window.
- [ ] Max and min values should be added for height and length variables. It
    already has 0.0 and 1.0 as min and max respectively; however, basically
    putting 0.0 as a value creates a window with 0 length and height, 1.0 is
    the entire screen, too big for what Flominal is.
- [ ] A way to see which tab is the open one (reverse highlighting?).
