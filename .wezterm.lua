-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = "Tokyo Night Storm"

-- Follow the Omarchy theme: ~/.local/state/omarchy/current/theme/wezterm.lua is
-- generated on every theme change from ~/.config/omarchy/themed/wezterm.lua.tpl.
-- color_scheme above stays as the fallback for a missing or broken file.
local theme_ok, theme = pcall(dofile, os.getenv("HOME") .. "/.local/state/omarchy/current/theme/wezterm.lua")
if theme_ok and type(theme) == "table" and theme.colors then
	config.colors = theme.colors
end

-- config.use_ime = false
-- config.window_background_opacity = 0.95

-- This is where you actually apply your config choices.
local is_macos = wezterm.target_triple:find("darwin") ~= nil

-- Platform differences live here; everything else stays shared.
local platform = is_macos and {
	-- 1. 首选英文字体/编程字体
	-- 2. 备选 CJK 字体，显示中文、日文、韩文
	--    'Sarasa Gothic SC' 是更纱黑体的简体中文版本名，包含完整 CJK 字符。
	fonts = { "JetBrainsMono Nerd Font", "Sarasa Gothic SC" },
	font_size = 13,
} or {
	fonts = { "JetBrainsMono Nerd Font", "Sarasa Gothic SC" },
	font_size = 11,
}

config.font = wezterm.font_with_fallback(platform.fonts)
config.font_size = platform.font_size
-- config.enable_tab_bar = false
-- Linux (Omarchy/Hyprland) tiles windows itself, so no decorations are needed.
-- macOS loses its resize borders with "NONE", so keep "RESIZE" there.
config.window_decorations = is_macos and "RESIZE" or "NONE"

-- key binding
config.keys = {
	-- Omarchy's universal clipboard (SUPER+C / SUPER+V) sends CTRL+Insert /
	-- SHIFT+Insert into the focused terminal. WezTerm's defaults route those to
	-- the primary selection; route them to the clipboard like foot does.
	{
		key = "Insert",
		mods = "CTRL",
		action = wezterm.action.CopyTo("Clipboard"),
	},
	{
		key = "Insert",
		mods = "SHIFT",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
	-- Turn off the default CMD-m Hide action, allowing CMD-m to
	-- be potentially recognized and handled by the tab
	{
		key = "[",
		mods = "CMD",
		action = wezterm.action({ ActivateTabRelative = -1 }),
	},
	{
		key = "]",
		mods = "CMD",
		action = wezterm.action({ ActivateTabRelative = 1 }),
	},
	{
		key = "\\",
		mods = "CMD",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "0",
		mods = "CMD",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "x",
		mods = "CMD",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "h",
		mods = "CMD",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "l",
		mods = "CMD",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		key = "j",
		mods = "CMD",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "CMD",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "LeftArrow",
		mods = "CMD",
		action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
	},
	{
		key = "RightArrow",
		mods = "CMD",
		action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
	},
	{
		key = "UpArrow",
		mods = "CMD",
		action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
	},
	{
		key = "DownArrow",
		mods = "CMD",
		action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
	},
}

-- config tab
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- Finally, return the configuration to wezterm:
return config
