-- Noir colorscheme for Neovim. A direct port of the iTerm2 "Noir" profile:
-- neutral #191919 chrome, #cccccc text, and the profile's saturated ANSI
-- accents driving syntax. Palette lives in lua/noir/palette.lua.
--
-- Usage:  :colorscheme noir

local p = require("noir.palette")

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end
vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "noir"

local hl = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Hand the 16 ANSI colors to :terminal and embedders, so tmux/htop/lazygit
-- inside Neovim match the surrounding iTerm2 window.
for i, color in ipairs(p.ansi) do
  vim.g["terminal_color_" .. (i - 1)] = color
end

-- ---------------------------------------------------------------------------
-- Editor chrome
-- ---------------------------------------------------------------------------
hl("Normal", { fg = p.fg, bg = p.bg })
hl("NormalNC", { fg = p.fg, bg = p.bg })
hl("NormalFloat", { fg = p.fg, bg = p.bg_alt })
hl("FloatBorder", { fg = p.border, bg = p.bg_alt })
hl("FloatTitle", { fg = p.fg_bright, bg = p.bg_alt, bold = true })
hl("FloatFooter", { fg = p.muted, bg = p.bg_alt })

hl("Cursor", { fg = p.bg, bg = p.white })
hl("lCursor", { fg = p.bg, bg = p.white })
hl("CursorIM", { fg = p.bg, bg = p.white })
hl("TermCursor", { fg = p.bg, bg = p.white })
hl("TermCursorNC", { fg = p.bg, bg = p.muted })

hl("CursorLine", { bg = p.bg_hl })
hl("CursorColumn", { bg = p.bg_hl })
hl("ColorColumn", { bg = p.bg_hl })
hl("LineNr", { fg = p.black })
hl("LineNrAbove", { fg = p.black })
hl("LineNrBelow", { fg = p.black })
hl("CursorLineNr", { fg = p.fg_bright, bold = true })
hl("CursorLineSign", { bg = p.bg_hl })
hl("CursorLineFold", { bg = p.bg_hl })

hl("SignColumn", { fg = p.black, bg = p.bg })
hl("FoldColumn", { fg = p.black, bg = p.bg })
hl("Folded", { fg = p.fg_dim, bg = p.bg_alt })

hl("WinSeparator", { fg = p.border, bg = p.bg })
hl("VertSplit", { link = "WinSeparator" })

hl("StatusLine", { fg = p.fg, bg = p.bg_alt })
hl("StatusLineNC", { fg = p.muted, bg = p.bg })

hl("TabLine", { fg = p.muted, bg = p.bg })
hl("TabLineFill", { fg = p.muted, bg = p.bg })
hl("TabLineSel", { fg = p.fg_bright, bg = p.bg, bold = true })

hl("Pmenu", { fg = p.fg, bg = p.bg_alt })
hl("PmenuSel", { fg = p.fg_bright, bg = p.sel })
hl("PmenuKind", { fg = p.blue_br, bg = p.bg_alt })
hl("PmenuKindSel", { fg = p.blue_br, bg = p.sel })
hl("PmenuExtra", { fg = p.muted, bg = p.bg_alt })
hl("PmenuExtraSel", { fg = p.fg_dim, bg = p.sel })
hl("PmenuSbar", { bg = p.bg_hl })
hl("PmenuThumb", { bg = p.black })

hl("Visual", { bg = p.sel })
hl("VisualNOS", { bg = p.sel })

hl("Search", { fg = p.yellow_br, bg = p.badge })
hl("IncSearch", { fg = p.bg, bg = p.yellow })
hl("CurSearch", { fg = p.bg, bg = p.yellow, bold = true })
hl("Substitute", { fg = p.bg, bg = p.magenta })

hl("MatchParen", { fg = p.cyan_br, bold = true, underline = true })
hl("NonText", { fg = "#3b3b3b" })
hl("Whitespace", { fg = "#3b3b3b" })
hl("SpecialKey", { fg = p.black })
hl("EndOfBuffer", { fg = p.bg })
hl("Conceal", { fg = p.fg_dim })
hl("Directory", { fg = p.blue_br })
hl("Title", { fg = p.green_br, bold = true })
hl("Question", { fg = p.green })
hl("MoreMsg", { fg = p.green })
hl("WarningMsg", { fg = p.yellow })
hl("ErrorMsg", { fg = p.red })
hl("ModeMsg", { fg = p.fg })
hl("WildMenu", { fg = p.fg_bright, bg = p.sel })
hl("QuickFixLine", { bg = p.bg_hl })
hl("MsgArea", { fg = p.fg, bg = p.bg })
hl("MsgSeparator", { fg = p.border, bg = p.bg_alt })

-- ---------------------------------------------------------------------------
-- Diffs
-- ---------------------------------------------------------------------------
hl("DiffAdd", { fg = p.green_br, bg = "#16241d" })
hl("DiffChange", { fg = p.yellow_br, bg = "#262415" })
hl("DiffDelete", { fg = p.red_br, bg = "#2a1717" })
hl("DiffText", { fg = p.bg, bg = p.green })
hl("Added", { fg = p.green_br })
hl("Changed", { fg = p.yellow_br })
hl("Removed", { fg = p.red_br })

-- ---------------------------------------------------------------------------
-- Classic syntax groups
-- ---------------------------------------------------------------------------
hl("Comment", { fg = p.fg_dim, italic = true })
hl("Constant", { fg = p.yellow })
hl("String", { fg = p.green })
hl("Character", { fg = p.green })
hl("Number", { fg = p.yellow })
hl("Boolean", { fg = p.yellow })
hl("Float", { fg = p.yellow })
hl("Identifier", { fg = p.fg })
hl("Function", { fg = p.blue_br })
hl("Statement", { fg = p.magenta })
hl("Conditional", { fg = p.magenta })
hl("Repeat", { fg = p.magenta })
hl("Label", { fg = p.cyan_br })
hl("Operator", { fg = "#c8c8c8" })
hl("Keyword", { fg = p.magenta })
hl("Exception", { fg = p.magenta })
hl("PreProc", { fg = p.magenta_br })
hl("Include", { fg = p.magenta })
hl("Define", { fg = p.magenta_br })
hl("Macro", { fg = p.cyan_br })
hl("PreCondit", { fg = p.magenta })
hl("Type", { fg = p.cyan })
hl("StorageClass", { fg = p.cyan })
hl("Structure", { fg = p.cyan })
hl("Typedef", { fg = p.cyan })
hl("Special", { fg = p.cyan_br })
hl("SpecialChar", { fg = p.cyan_br })
hl("Tag", { fg = p.magenta })
hl("Delimiter", { fg = p.fg_dim })
hl("SpecialComment", { fg = p.fg_dim, italic = true })
hl("Debug", { fg = p.red_br })
hl("Underlined", { underline = true })
hl("Ignore", { fg = p.bg })
hl("Error", { fg = p.red })
hl("Todo", { fg = p.bg, bg = p.yellow, bold = true })

-- ---------------------------------------------------------------------------
-- Treesitter (@-groups)
-- ---------------------------------------------------------------------------
-- keywords / control flow -> magenta
hl("@keyword", { fg = p.magenta })
hl("@keyword.function", { fg = p.magenta })
hl("@keyword.operator", { fg = p.magenta_br })
hl("@keyword.return", { fg = p.magenta })
hl("@keyword.import", { fg = p.magenta })
hl("@keyword.exception", { fg = p.magenta })
hl("@keyword.conditional", { fg = p.magenta })
hl("@keyword.repeat", { fg = p.magenta })
hl("@conditional", { fg = p.magenta })
hl("@repeat", { fg = p.magenta })
hl("@exception", { fg = p.magenta })

-- types / storage / namespaces -> cyan
hl("@type", { fg = p.cyan })
hl("@type.builtin", { fg = p.cyan_br })
hl("@type.qualifier", { fg = p.cyan })
hl("@type.definition", { fg = p.cyan })
hl("@storageclass", { fg = p.cyan })
hl("@namespace", { fg = p.cyan })
hl("@constructor", { fg = p.cyan_br })

-- functions -> blue, builtins a touch brighter
hl("@function", { fg = p.blue_br })
hl("@function.call", { fg = p.blue_br })
hl("@function.builtin", { fg = p.blue })
hl("@function.method", { fg = p.blue_br })
hl("@function.method.call", { fg = p.blue_br })
hl("@function.macro", { fg = p.cyan_br })

-- variables stay neutral so structure carries the color
hl("@variable", { fg = p.fg })
hl("@variable.builtin", { fg = p.magenta_br })
hl("@variable.parameter", { fg = "#d4d4d4" })
hl("@variable.parameter.builtin", { fg = p.magenta_br })
hl("@variable.member", { fg = "#e0e0e0" })
hl("@field", { fg = "#e0e0e0" })
hl("@property", { fg = "#e0e0e0" })

-- literals
hl("@constant", { fg = p.yellow })
hl("@constant.builtin", { fg = p.yellow })
hl("@constant.macro", { fg = p.cyan_br })
hl("@number", { fg = p.yellow })
hl("@boolean", { fg = p.yellow })
hl("@float", { fg = p.yellow })
hl("@string", { fg = p.green })
hl("@string.escape", { fg = p.cyan_br })
hl("@string.special", { fg = p.cyan_br })
hl("@string.regexp", { fg = p.red_br })
hl("@string.special.url", { fg = p.link, underline = true })
hl("@character", { fg = p.green })
hl("@character.special", { fg = p.cyan_br })

-- operators / punctuation
hl("@operator", { fg = "#c8c8c8" })
hl("@punctuation.delimiter", { fg = "#909090" })
hl("@punctuation.bracket", { fg = "#a0a0a0" })
hl("@punctuation.special", { fg = p.cyan_br })

-- markup / html
hl("@tag", { fg = p.magenta })
hl("@tag.builtin", { fg = p.magenta })
hl("@tag.attribute", { fg = p.blue_br })
hl("@tag.delimiter", { fg = "#808080" })
hl("@attribute", { fg = p.cyan_br, italic = true })
hl("@label", { fg = p.cyan_br })
hl("@annotation", { fg = p.cyan_br })
hl("@module", { fg = p.cyan })
hl("@module.builtin", { fg = p.cyan_br })

-- comments
hl("@comment", { fg = p.fg_dim, italic = true })
hl("@comment.documentation", { fg = p.fg_dim })
hl("@comment.error", { fg = p.bg, bg = p.red, bold = true })
hl("@comment.warning", { fg = p.bg, bg = p.yellow, bold = true })
hl("@comment.todo", { fg = p.bg, bg = p.cyan, bold = true })
hl("@comment.note", { fg = p.bg, bg = p.blue, bold = true })

-- markup text
hl("@markup.heading", { fg = p.green_br, bold = true })
hl("@markup.heading.1", { fg = p.green_br, bold = true })
hl("@markup.heading.2", { fg = p.cyan_br, bold = true })
hl("@markup.heading.3", { fg = p.blue_br, bold = true })
hl("@markup.strong", { fg = p.fg_bright, bold = true })
hl("@markup.italic", { fg = p.fg_bright, italic = true })
hl("@markup.strikethrough", { fg = p.muted, strikethrough = true })
hl("@markup.underline", { underline = true })
hl("@markup.quote", { fg = p.fg_dim, italic = true })
hl("@markup.raw", { fg = p.green })
hl("@markup.raw.block", { fg = p.green })
hl("@markup.link", { fg = p.link })
hl("@markup.link.label", { fg = p.blue_br })
hl("@markup.link.url", { fg = p.link, underline = true })
hl("@markup.list", { fg = p.cyan_br })
hl("@markup.list.checked", { fg = p.green_br })
hl("@markup.list.unchecked", { fg = p.muted })
hl("@diff.plus", { fg = p.green_br })
hl("@diff.minus", { fg = p.red_br })
hl("@diff.delta", { fg = p.yellow_br })
hl("@text.title", { fg = p.green_br, bold = true })
hl("@text.literal", { fg = p.green })
hl("@text.reference", { fg = p.blue_br })
hl("@text.uri", { fg = p.link, underline = true })
hl("@text.emphasis", { italic = true })
hl("@text.strong", { bold = true })
hl("@error", { fg = p.red })

-- ---------------------------------------------------------------------------
-- LSP
-- ---------------------------------------------------------------------------
hl("DiagnosticError", { fg = p.red })
hl("DiagnosticWarn", { fg = p.yellow })
hl("DiagnosticInfo", { fg = p.blue })
hl("DiagnosticHint", { fg = p.cyan })
hl("DiagnosticOk", { fg = p.green })

hl("DiagnosticVirtualTextError", { fg = p.red, bg = "#2a1717" })
hl("DiagnosticVirtualTextWarn", { fg = p.yellow, bg = "#262415" })
hl("DiagnosticVirtualTextInfo", { fg = p.blue, bg = "#152030" })
hl("DiagnosticVirtualTextHint", { fg = p.cyan, bg = "#15262a" })

hl("DiagnosticUnderlineError", { sp = p.red, undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = p.yellow, undercurl = true })
hl("DiagnosticUnderlineInfo", { sp = p.blue, undercurl = true })
hl("DiagnosticUnderlineHint", { sp = p.cyan, undercurl = true })
hl("DiagnosticUnderlineOk", { sp = p.green, undercurl = true })

hl("DiagnosticFloatingError", { fg = p.red, bg = p.bg_alt })
hl("DiagnosticFloatingWarn", { fg = p.yellow, bg = p.bg_alt })
hl("DiagnosticFloatingInfo", { fg = p.blue, bg = p.bg_alt })
hl("DiagnosticFloatingHint", { fg = p.cyan, bg = p.bg_alt })

hl("DiagnosticSignError", { fg = p.red, bg = p.bg })
hl("DiagnosticSignWarn", { fg = p.yellow, bg = p.bg })
hl("DiagnosticSignInfo", { fg = p.blue, bg = p.bg })
hl("DiagnosticSignHint", { fg = p.cyan, bg = p.bg })

hl("DiagnosticDeprecated", { sp = p.red, strikethrough = true })
hl("DiagnosticUnnecessary", { fg = p.black_br })

hl("LspReferenceText", { bg = "#2d2d2d" })
hl("LspReferenceRead", { bg = "#2d2d2d" })
hl("LspReferenceWrite", { bg = "#33303b" })
hl("LspSignatureActiveParameter", { fg = p.cyan_br, bold = true })
hl("LspCodeLens", { fg = p.muted })
hl("LspCodeLensSeparator", { fg = p.border })
hl("LspInlayHint", { fg = p.black_br, bg = p.bg_hl })

-- ---------------------------------------------------------------------------
-- Git signs
-- ---------------------------------------------------------------------------
hl("GitSignsAdd", { fg = p.green, bg = p.bg })
hl("GitSignsChange", { fg = p.yellow, bg = p.bg })
hl("GitSignsDelete", { fg = p.red, bg = p.bg })
hl("GitSignsAddNr", { fg = p.green_br, bg = p.bg })
hl("GitSignsChangeNr", { fg = p.yellow_br, bg = p.bg })
hl("GitSignsDeleteNr", { fg = p.red_br, bg = p.bg })
hl("GitSignsAddLn", { bg = "#16241d" })
hl("GitSignsChangeLn", { bg = "#262415" })
hl("GitSignsDeleteLn", { bg = "#2a1717" })
hl("GitSignsCurrentLineBlame", { fg = p.black_br })

-- ---------------------------------------------------------------------------
-- Plugins
-- ---------------------------------------------------------------------------
hl("CmpItemAbbr", { fg = p.fg })
hl("CmpItemAbbrDeprecated", { fg = p.black_br, strikethrough = true })
hl("CmpItemAbbrMatch", { fg = p.cyan_br, bold = true })
hl("CmpItemAbbrMatchFuzzy", { fg = p.cyan_br })
hl("CmpItemMenu", { fg = p.muted })
hl("CmpItemKind", { fg = p.blue_br })
hl("CmpItemKindFunction", { fg = p.blue_br })
hl("CmpItemKindMethod", { fg = p.blue_br })
hl("CmpItemKindVariable", { fg = p.fg })
hl("CmpItemKindClass", { fg = p.cyan })
hl("CmpItemKindModule", { fg = p.cyan })
hl("CmpItemKindKeyword", { fg = p.magenta })
hl("CmpItemKindSnippet", { fg = p.magenta })
hl("CmpItemKindText", { fg = p.fg })
hl("CmpItemKindConstant", { fg = p.yellow })

hl("TroubleNormal", { fg = p.fg, bg = p.bg })
hl("TroubleNormalNC", { fg = p.fg, bg = p.bg })
hl("TroubleText", { fg = p.fg_dim })
hl("TroubleSource", { fg = p.muted })
hl("TroubleFile", { fg = p.blue_br })
hl("TroubleDirectory", { fg = p.blue_br })

hl("OilDir", { fg = p.blue_br })
hl("OilDirIcon", { fg = p.blue_br })
hl("OilFile", { fg = p.fg })
hl("OilLink", { fg = p.link })
hl("OilHidden", { fg = p.muted })
hl("OilTrashIcon", { fg = p.red })
hl("OilCreate", { fg = p.green })
hl("OilDelete", { fg = p.red })
hl("OilMove", { fg = p.yellow })
hl("OilCopy", { fg = p.cyan })
hl("OilChange", { fg = p.magenta })
hl("OilPermissionRead", { fg = p.cyan })
hl("OilPermissionWrite", { fg = p.yellow })
hl("OilPermissionExecute", { fg = p.red })
hl("OilSocket", { fg = p.magenta })
hl("OilPurple", { fg = p.magenta_br })

hl("WhichKey", { fg = p.blue_br })
hl("WhichKeyGroup", { fg = p.magenta })
hl("WhichKeyDesc", { fg = p.fg_dim })
hl("WhichKeySeparator", { fg = p.border })
hl("WhichKeyFloat", { bg = p.bg_alt })
hl("WhichKeyBorder", { fg = p.border, bg = p.bg_alt })
hl("WhichKeyValue", { fg = p.muted })

hl("IlluminatedWordText", { bg = "#2d2d2d" })
hl("IlluminatedWordRead", { bg = "#2d2d2d" })
hl("IlluminatedWordWrite", { bg = "#33303b" })

hl("MiniIconsAzure", { fg = p.cyan_br })
hl("MiniIconsBlue", { fg = p.blue_br })
hl("MiniIconsGreen", { fg = p.green_br })
hl("MiniIconsGrey", { fg = p.fg })
hl("MiniIconsOrange", { fg = p.yellow_br })
hl("MiniIconsPurple", { fg = p.magenta_br })
hl("MiniIconsRed", { fg = p.red_br })
hl("MiniIconsYellow", { fg = p.yellow_br })
