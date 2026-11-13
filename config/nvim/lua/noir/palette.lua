-- Shared palette, now Tokyo Night (night) from folke/tokyonight.nvim, so every
-- surface matches the iTerm2 profile:
--   ~/Library/Application Support/iTerm2/DynamicProfiles/noir.json
-- The colorscheme itself is tokyonight.nvim. These values paint the parts
-- init.lua styles by hand: telescope, bufferline and the embedded :terminal.
-- The module keeps its old name so those callers don't change.

local M = {
  -- base chrome
  bg        = "#0f0f14", -- darker than stock Tokyo Night (#1a1b26); matches the iTerm2 profile
  bg_dark   = "#0a0a0e",
  bg_alt    = "#0a0a0e", -- sidebars, floats, popups
  bg_hl     = "#292e42", -- cursorline, subtle fills
  border    = "#27a1b9",
  sel       = "#283457",
  badge     = "#3b4261",

  -- text
  fg        = "#c0caf5",
  fg_bright = "#c0caf5",
  fg_dim    = "#565f89", -- comments
  muted     = "#545c7e", -- inactive chrome

  -- ANSI normal 0-7. black is the gutter grey, so line numbers stay visible.
  black     = "#3b4261",
  red       = "#f7768e",
  green     = "#9ece6a",
  yellow    = "#e0af68",
  blue      = "#7aa2f7",
  magenta   = "#bb9af7",
  cyan      = "#7dcfff",
  white     = "#a9b1d6",

  -- ANSI bright 8-15
  black_br  = "#414868",
  red_br    = "#f7768e",
  green_br  = "#9ece6a",
  yellow_br = "#e0af68",
  blue_br   = "#7aa2f7",
  magenta_br = "#bb9af7",
  cyan_br   = "#7dcfff",
  white_br  = "#c0caf5",

  link      = "#7aa2f7",
}

-- The 16 terminal colors, in ANSI order, for :terminal and TUI apps.
-- Index 0 is the real terminal black, not the gutter grey above.
M.ansi = {
  "#15161e", M.red, M.green, M.yellow, M.blue, M.magenta, M.cyan, M.white,
  M.black_br, M.red_br, M.green_br, M.yellow_br, M.blue_br, M.magenta_br,
  M.cyan_br, M.white_br,
}

return M
