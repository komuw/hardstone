-- This is a comment
-- docs: https://wezfurlong.org/wezterm/config/files.html

local wezterm = require 'wezterm';

return {
    -- Spawn a zsh shell in login mode
    default_prog = {"zsh", "-l"},

    -- How many lines of scrollback you want to retain per tab
    scrollback_lines = 3500,

    keys = {
        -- https://wezfurlong.org/wezterm/config/lua/keyassignment/CopyTo.html
        {key="c", mods="CTRL", action=wezterm.action{CopyTo="ClipboardAndPrimarySelection"}},
        {key="C", mods="CTRL", action=wezterm.action{CopyTo="ClipboardAndPrimarySelection"}},

        -- paste from the clipboard
        -- https://wezfurlong.org/wezterm/config/lua/keyassignment/PasteFrom.html
        {key="v", mods="CTRL", action=wezterm.action{PasteFrom="Clipboard"}},
        {key="V", mods="CTRL", action=wezterm.action{PasteFrom="Clipboard"}},
        -- paste from the primary selection
        {key="v", mods="CTRL", action=wezterm.action{PasteFrom="PrimarySelection"}},
        {key="V", mods="CTRL", action=wezterm.action{PasteFrom="PrimarySelection"}},

        -- Create a new tab in the same domain as the current pane. This is usually what you want.
        -- https://wezfurlong.org/wezterm/config/lua/keyassignment/SpawnTab.html
        {key="t", mods="CTRL", action=wezterm.action{SpawnTab="CurrentPaneDomain"}},
        {key="T", mods="CTRL", action=wezterm.action{SpawnTab="CurrentPaneDomain"}},

        -- closes the current tab, asks for confirmation.
        -- https://wezfurlong.org/wezterm/config/lua/keyassignment/CloseCurrentTab.html
        {key="w", mods="CTRL", action=wezterm.action{CloseCurrentTab={confirm=true}}},

    },
}
