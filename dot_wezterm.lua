local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- ============================================================================
-- Tokyo Night Color Scheme (matching tmux-dotbar)
-- ============================================================================

config.colors = {
  -- Background and foreground
  foreground = '#a9b1d6',
  background = '#1a1b26',

  -- Cursor colors
  cursor_bg = '#7aa2f7',
  cursor_fg = '#1a1b26',
  cursor_border = '#7aa2f7',

  -- Selection colors
  selection_fg = '#1a1b26',
  selection_bg = '#7aa2f7',

  -- Scrollbar colors
  scrollbar_thumb = '#3b4261',

  -- Split line color
  split = '#3b4261',

  -- Tab bar colors (matching tmux-dotbar style)
  tab_bar = {
    background = '#1a1b26',

    -- Active tab (matching tmux-dotbar current window)
    active_tab = {
      bg_color = '#7aa2f7',  -- Tokyo Night blue
      fg_color = '#1a1b26',
      intensity = 'Bold',
    },

    -- Inactive tabs (matching tmux-dotbar inactive windows)
    inactive_tab = {
      bg_color = '#1a1b26',
      fg_color = '#a9b1d6',
    },

    -- Inactive tab with hover
    inactive_tab_hover = {
      bg_color = '#3b4261',
      fg_color = '#a9b1d6',
    },

    -- New tab button
    new_tab = {
      bg_color = '#1a1b26',
      fg_color = '#a9b1d6',
    },

    new_tab_hover = {
      bg_color = '#3b4261',
      fg_color = '#7aa2f7',
    },
  },

  -- Terminal ANSI colors (Tokyo Night palette)
  ansi = {
    '#15161e', -- black
    '#f7768e', -- red
    '#9ece6a', -- green
    '#e0af68', -- yellow
    '#7aa2f7', -- blue
    '#bb9af7', -- magenta/purple
    '#7dcfff', -- cyan
    '#a9b1d6', -- white
  },

  brights = {
    '#414868', -- bright black
    '#f7768e', -- bright red
    '#9ece6a', -- bright green
    '#e0af68', -- bright yellow
    '#7aa2f7', -- bright blue
    '#bb9af7', -- bright magenta
    '#7dcfff', -- bright cyan
    '#c0caf5', -- bright white
  },
}

-- ============================================================================
-- Font Configuration
-- ============================================================================

config.font = wezterm.font('FiraCode Nerd Font Mono')
config.font_size = 14.0
config.line_height = 1.2

-- ============================================================================
-- Tab Bar Configuration
-- ============================================================================

-- Enable tab bar at bottom for visual session organization
config.enable_tab_bar = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false

-- Custom tab title: show tmux session name or process name
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local title = tab.active_pane.title
  local process = tab.active_pane.foreground_process_name

  -- Extract process name from path
  if process then
    process = process:match("([^/]+)$")
  end

  -- If we're in tmux, the title will be the session name (set by set-titles-string)
  -- tmux sets title via OSC 0 or OSC 2 escape sequences
  if title and title ~= "" then
    -- If title looks like a session name (simple alphanumeric), use it
    -- This catches tmux session names like "wadus3", "dotfiles", "work-api"
    if title:match("^[%w_-]+$") then
      return "  " .. title .. "  "
    end
  end

  -- Otherwise show process name
  if process then
    return "  " .. process .. "  "
  end

  return "  tab  "
end)

-- ============================================================================
-- Window Title Configuration (shows process, tabs, panes)
-- ============================================================================

-- Custom window title formatting
-- Shows: process name · tab count · pane count in macOS title bar
wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  local title = tab.active_pane.title
  local process = tab.active_pane.foreground_process_name

  -- Extract just the process name (remove path)
  if process then
    process = process:match("([^/]+)$")
  else
    process = title
  end

  -- Get pane and tab counts
  local pane_count = #tab.panes
  local tab_count = #tabs

  -- Build minimal title: process · tabs · panes
  return string.format('%s · %d · %d', process, tab_count, pane_count)
end)

-- ============================================================================
-- Window Configuration
-- ============================================================================

-- Start maximized
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

config.window_background_opacity = 1.0
config.enable_scroll_bar = false
config.scrollback_lines = 10000

-- ============================================================================
-- Other Settings
-- ============================================================================

config.automatically_reload_config = true
config.check_for_updates = false

-- Cursor style
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 700

-- Visual bell
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 150,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 150,
}
config.audible_bell = 'Disabled'

-- ============================================================================
-- Key Bindings
-- ============================================================================

config.keys = {
  { mods = "SHIFT", key = "Enter", action = act.SendString "\\\n" },
}

return config
