-- lualine theme "noir". Selected with options.theme = "noir" (lualine resolves
-- strings to lualine.themes.<name>). Built from lua/noir/palette.lua so it can
-- never drift from the colorscheme.
local p = require("noir.palette")

local function mode(accent)
  return {
    a = { fg = p.bg, bg = accent, gui = "bold" },
    b = { fg = p.fg, bg = p.bg_alt },
    c = { fg = p.fg_dim, bg = p.bg },
  }
end

return {
  normal = mode(p.fg_bright),
  insert = mode(p.green),
  visual = mode(p.magenta),
  replace = mode(p.red),
  command = mode(p.yellow),
  terminal = mode(p.cyan),
  inactive = {
    a = { fg = p.muted, bg = p.bg_alt },
    b = { fg = p.muted, bg = p.bg_alt },
    c = { fg = p.muted, bg = p.bg },
  },
}
