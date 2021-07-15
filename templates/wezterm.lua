-- This is a comment
-- docs: https://wezfurlong.org/wezterm/config/files.html

-- To debug this config file;
-- (a) add this config to the required location, /home/$MY_NAME/.config/wezterm/wezterm.lua
-- (b) add `debug_key_events = true,` to the config
-- (c) Start wezterm without backgrounding it. ie `wezterm`
-- (d) Any errors will be displayed in either the terminal(eg gnome-terminal) where wezterm is started,
--     or in a new(2nd) wezterm terminal that will start.

local wezterm = require 'wezterm';

return {
    -- Spawn a zsh shell in login mode
    default_prog = {"zsh", "-l"},

    -- How many lines of scrollback you want to retain per tab
    scrollback_lines = 3500,

    -- 0.0 (meaning completely translucent/transparent) through to 1.0 (meaning completely opaque).
    -- Setting this to a value other than the default 1.0 may impact render performance.
    -- https://wezfurlong.org/wezterm/config/appearance.html
    window_background_opacity = 0.92,

    -- max width that a tab can have in the tab bar. Defaults to 16 glyphs in width.
    -- https://wezfurlong.org/wezterm/config/lua/config/tab_max_width.html
    tab_max_width = 22,

    keys = {
        -- https://wezfurlong.org/wezterm/config/lua/keyassignment/CopyTo.html
        -- There's a bug where if you map `ctrl + c` to copy
        -- then you are not able to send sigints `^C` to commands.
        -- see: https://github.com/wez/wezterm/issues/944
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

    -- https://wezfurlong.org/wezterm/config/appearance.html#tab-bar-appearance--colors
    colors = {
        tab_bar = {

          -- The color of the strip that goes along the top of the window
          background = "#0b0022",

          -- The active tab is the one that has focus in the window
          active_tab = {
            -- The color of the background area for the tab
            bg_color = "#09e609", --green

            -- The color of the text for the tab
            fg_color = "#ed0909", --red

            -- Specify whether you want "Half", "Normal" or "Bold" intensity for the label shown for this tab. The default is "Normal"
            intensity = "Bold",

            -- Specify whether you want "None", "Single" or "Double" underline for label shown for this tab. The default is "None"
            underline = "None",

            -- Specify whether you want the text to be italic (true) or not (false) for this tab.  The default is false.
            italic = false,

            -- Specify whether you want the text to be rendered with strikethrough (true) or not for this tab.  The default is false.
            strikethrough = false,
          },

          -- Inactive tabs are the tabs that do not have focus
          inactive_tab = {
            bg_color = "#e3ddf0", -- light-purple
            fg_color = "#808080",

            -- The same options that were listed under the `active_tab` section above
            -- can also be used for `inactive_tab`.
          },

          -- You can configure some alternate styling when the mouse pointer moves over inactive tabs
          -- inactive_tab_hover = {},
        }
      },
}
