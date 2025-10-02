---@type Wezterm
local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

config = {
	max_fps = 144,
	font = wezterm.font("Hack Nerd Font", { weight = "Regular" }),
	color_scheme = "Gruvbox dark, hard (base16)",
	hide_tab_bar_if_only_one_tab = true,
	window_close_confirmation = "NeverPrompt",
	font_size = 18,
	scrollback_lines = 5000,
	leader = { key = "a", mods = "CTRL" },
	keys = {
		{ key = "UpArrow", mods = "SHIFT", action = act.ScrollToPrompt(-1) },
		{ key = "DownArrow", mods = "SHIFT", action = act.ScrollToPrompt(1) },
		{ key = "LeftArrow", mods = "ALT", action = act.SendKey({ key = "b", mods = "ALT" }) },
		{ key = "RightArrow", mods = "ALT", action = act.SendKey({ key = "f", mods = "ALT" }) },
	},
	mouse_bindings = {
		{
			event = { Down = { streak = 3, button = "Left" } },
			action = act.SelectTextAtMouseCursor("SemanticZone"),
			mods = "NONE",
		},
	},

	key_tables = {
		copy_mode = {
			{ key = "s", mods = "ALT", action = act.CopyMode({ SetSelectionMode = "SemanticZone" }) },
			{ key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
			{ key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
			{ key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
			{ key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },
		},
		search_mode = {
			{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
		},
	},
	-- default_gui_startup_args = { "connect", "unix" },
}

local weztmux = wezterm.plugin.require("https://github.com/sei40kr/wez-tmux")
weztmux.apply_to_config(config, {})

local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
workspace_switcher.apply_to_config(config)
workspace_switcher.zoxide_path = "/opt/homebrew/bin/zoxide"

wezterm.on("window-config-reloaded", function(window, _)
	window:toast_notification("wezterm", "configuration reloaded!", nil, 3000)
end)

return config
