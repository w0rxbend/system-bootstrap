-- Pull in the wezterm API
local wezterm = require("wezterm")

local act = wezterm.action

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

config.window_decorations = "NONE"
config.integrated_title_button_style = "Gnome"
config.integrated_title_buttons = { "Hide", "Maximize", "Close" }
-- This is where you actually apply your config choices

config.color_scheme = "Catppuccin Mocha"

config.window_frame = {
    inactive_titlebar_bg = "#353535",
    active_titlebar_bg = "#2b2042",
    inactive_titlebar_fg = "#cccccc",
    active_titlebar_fg = "#ffffff",
    inactive_titlebar_border_bottom = "#2b2042",
    active_titlebar_border_bottom = "#2b2042",
    button_fg = "#cccccc",
    button_bg = "#2b2042",
    button_hover_fg = "#ffffff",
    button_hover_bg = "#3b3052",
    font = require("wezterm").font("Roboto"),
    font_size = 14,
}

config.window_frame = {
    border_left_width = "0.10cell",
    border_right_width = "0.10cell",
    border_bottom_height = "0.05cell",
    border_top_height = "0.05cell",
    border_left_color = "red",
    border_right_color = "red",
    border_bottom_color = "red",
    border_top_color = "red",
}

config.colors = {
    tab_bar = {
        -- The color of the inactive tab bar edge/divider
        inactive_tab_edge = "#575757",
    },
}

config.window_background_opacity = 0.7
config.text_background_opacity = 1

config.mouse_wheel_scrolls_tabs = true
config.mouse_bindings = {
    {
        event = { Down = { streak = 1, button = { WheelUp = 1 } } },
        mods = "CTRL",
        action = act.IncreaseFontSize,
    },

    {
        event = { Down = { streak = 1, button = { WheelDown = 1 } } },
        mods = "CTRL",
        action = act.DecreaseFontSize,
    },

    {
        event = { Down = { streak = 1, button = "Middle" } },
        mods = "CTRL",
        action = act.ResetFontSize,
    },
}

config.keys = {
    { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
}

-- For example, changing the color scheme:
config.font = wezterm.font("VictorMono Nerd Font")
-- config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.set_environment_variables = {
    -- This changes the default prompt for cmd.exe to report the
    -- current directory using OSC 7, show the current time and
    -- the current directory colored in the prompt.
    WITH_TMUX = "true",
}

-- Spawn a fish shell in login mode
-- config.default_prog = { 'zellij' }

config.use_fancy_tab_bar = true

-- and finally, return the configuration to wezterm
return config
