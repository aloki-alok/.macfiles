-- Noir palette, lifted verbatim from the iTerm2 "Noir" profile so every
-- surface speaks the same color:
--   ~/Library/Application Support/iTerm2/DynamicProfiles/noir.json
-- The chrome is true black (#000000 base, #cccccc text). The accents are the
-- profile's "Noir Calm" ANSI 0-15 set: the Noir hues, desaturated so they stay
-- readable on black instead of glaring. Change a value here and the colorscheme,
-- lualine, telescope and the embedded :terminal all follow.

local M = {
  -- base chrome: true black, so the whole Noir system matches the pitch-black
  -- VS Code window. Separation comes from borders, not from lifted greys.
  bg        = "#000000", -- iTerm2 "Background Color"
  bg_dark   = "#000000",
  bg_alt    = "#000000", -- sidebars, floats, popups
  bg_hl     = "#1a1a1a", -- cursorline, subtle fills
  border    = "#1c1c1c", -- the divider VS Code uses for Noir chrome
  sel       = "#3b3b3b", -- iTerm2 "Selection Color"
  badge     = "#4d4d4d",

  -- text
  fg        = "#cccccc", -- iTerm2 "Foreground Color"
  fg_bright = "#e5e5e5", -- iTerm2 bold/white
  fg_dim    = "#828aa0", -- comments, matches the VS Code Noir Calm comments
  muted     = "#6b6b6b", -- inactive chrome

  -- ANSI normal (iTerm2 Ansi 0-7), "Noir Calm" set.
  black     = "#5a5f6b",
  red       = "#ff6e6e",
  green     = "#5fd6a8",
  yellow    = "#ffc777",
  blue      = "#6aa6ff",
  magenta   = "#d183f5",
  cyan      = "#5cc8f5",
  white     = "#c5c9d8",

  -- ANSI bright (iTerm2 Ansi 8-15)
  black_br  = "#828aa0",
  red_br    = "#ff8a8a",
  green_br  = "#7fe0bb",
  yellow_br = "#ffd79a",
  blue_br   = "#8bb9ff",
  magenta_br = "#dda0f8",
  cyan_br   = "#7fd6f8",
  white_br  = "#e8ebf2",

  link      = "#8bb9ff", -- iTerm2 "Link Color"
}

-- The 16 terminal colors, in ANSI order, for :terminal and TUI apps.
M.ansi = {
  M.black, M.red, M.green, M.yellow, M.blue, M.magenta, M.cyan, M.white,
  M.black_br, M.red_br, M.green_br, M.yellow_br, M.blue_br, M.magenta_br,
  M.cyan_br, M.white_br,
}

return M
