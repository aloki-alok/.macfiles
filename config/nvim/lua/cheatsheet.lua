-- Keybind cheat sheet sidebar.
-- A read-only panel on the right that lists standard Vim motions plus every
-- mapping your config actually defines (it reads nvim_get_keymap, the same
-- source as lua/tipbar.lua), so it can never drift from init.lua. Add a
-- map(..., { desc = "..." }) and it shows up here on the next open.
--
-- <leader>? toggles it. Inside the panel:
--   q / <Esc>  close        ]s / [s  next / previous section
--   <CR>       explain      y        yank the keys under the cursor
--   R          rebuild

local M = {}

local p = require("noir.palette")
local ns = vim.api.nvim_create_namespace("cheatsheet")

local WIDTH = 54
local KEYCOL = 22 -- width of the key column, descriptions start after it

local buf, win, origin
local rows = {} -- line number -> row record, used by <CR>

-- Standard Vim, trimmed to what you use in a day. Keys are plain text, so
-- they read the same whether or not a plugin re-binds anything.
local reference = {
  {
    title = "Move",
    items = {
      { "h j k l", "left, down, up, right" },
      { "w / b", "next / previous word" },
      { "W / B", "next / previous WORD" },
      { "e / ge", "end of word, forward / back" },
      { "0 / ^", "line start / first non-blank" },
      { "$", "end of line" },
      { "gg / G", "top / bottom of file" },
      { "H / M / L", "top / middle / bottom of screen" },
      { "{ / }", "previous / next paragraph" },
      { "( / )", "previous / next sentence" },
      { "<C-d> / <C-u>", "half page down / up" },
      { "<C-f> / <C-b>", "page down / up" },
      { "zz / zt / zb", "center / top / bottom this line" },
      { "%", "jump to matching bracket" },
      { "f<t> / t<t>", "jump to / just before char t" },
      { "; / ,", "repeat f or t forward / back" },
      { "/text  n  N", "search, next hit, previous hit" },
      { "* / #", "search word under cursor" },
      { "5j / 12-", "counts work on every motion" },
    },
  },
  {
    title = "Edit",
    items = {
      { "i / a", "insert before / after cursor" },
      { "I / A", "insert at line start / end" },
      { "o / O", "open line below / above" },
      { "x / s", "delete char / delete and type" },
      { "r / R", "replace char / replace mode" },
      { "d / c / y", "delete / change / yank" },
      { "p / P", "paste after / before" },
      { "u / <C-r>", "undo / redo" },
      { ".", "repeat last change" },
      { "J", "join line below" },
      { ">> / <<", "indent / outdent line" },
      { "gcc", "toggle comment on line" },
      { "g~ / gu / gU", "swap / lower / upper case" },
      { "viw", "select word under cursor" },
    },
  },
  {
    title = "Text objects",
    items = {
      { "iw / aw", "word / word plus space" },
      { 'i" / a"', "inside / around quotes" },
      { "i( / a(", "inside / around parentheses" },
      { "i{ / a{", "inside / around braces" },
      { "it / at", "inside / around HTML tag" },
      { "ip / ap", "inside / around paragraph" },
      { "ciw", "change word under cursor" },
      { "di(", "delete inside parentheses" },
      { "yap", "yank paragraph" },
    },
  },
  {
    title = "Jump & marks",
    items = {
      { "<C-o> / <C-i>", "jump back / forward" },
      { "'' / ``", "last jump, line / exact spot" },
      { "ma / 'a", "set mark a / jump to it" },
      { "g; / g,", "walk the change list" },
      { "5G / 42%", "line 5 / 42 percent into the file" },
      { "g_", "end of line, last non-blank" },
    },
  },
  {
    title = "Windows & tabs",
    items = {
      { "<C-w> h j k l", "move to window in that direction" },
      { "<C-w> s / v", "split / vertical split" },
      { "<C-w> =", "equalize split sizes" },
      { "<C-w> o", "close every other window" },
      { "<C-w> q", "close this window" },
      { "<C-w> T", "move window into its own tab" },
      { "gt / gT", "next / previous tab" },
      { ":tabnew file", "open a file in a new tab" },
    },
  },
  {
    title = "Macros & repeat",
    items = {
      { "qa", "record keystrokes into register a" },
      { "q", "stop recording" },
      { "@a", "play register a" },
      { "@@", "play the last macro again" },
      { "5@a", "play it five times" },
      { "qA", "append to macro a" },
      { ":%norm @a", "run the macro on every line" },
      { "&", "repeat the last :s on this line" },
    },
  },
  {
    title = "Registers",
    items = {
      { '"ayy', "yank line into register a" },
      { '"Ayy', "append the line to register a" },
      { '"ap', "paste register a" },
      { '"+y', "yank to the macOS clipboard" },
      { '"_d', "delete into the black hole (keeps yank)" },
      { '"0p', "paste the last yank" },
      { '"1p', "paste the last delete" },
      { ":reg", "show every register" },
    },
  },
  {
    title = "Search & replace",
    items = {
      { "*  cgn  .", "rename the word, dot repeats it" },
      { "gn / gN", "select next / previous match" },
      { ":s/a/b/g", "replace on this line" },
      { ":%s/a/b/g", "replace in the whole file" },
      { ":%s//b/g", "replace, reusing the last search" },
      { ":g/pat/d", "delete every matching line" },
      { ":v/pat/d", "delete every line that does not match" },
      { ":cdo s/a/b/g | update", "replace across quickfix files" },
    },
  },
  {
    title = "Insert mode",
    items = {
      { "<C-w>", "delete the word before the cursor" },
      { "<C-u>", "delete back to line start" },
      { "<C-o>", "run one normal command, stay insert" },
      { "<C-r>a", "paste register a" },
      { "<C-r><C-w>", "paste the word under the cursor" },
      { "<C-t> / <C-d>", "indent / outdent this line" },
      { "<C-a> / <C-x>", "number under cursor +1 / -1" },
    },
  },
  {
    title = "Visual & blocks",
    items = {
      { "<C-v>", "block select" },
      { "I / A", "insert at block start / end" },
      { "o", "jump to the other end of the selection" },
      { "gv", "reselect the last selection" },
      { "gJ", "join selected lines, no space" },
      { "> / <", "indent / outdent, stay selected" },
      { "J / K", "move the selection down / up" },
      { "p", "paste over the selection, keep yank" },
    },
  },
  {
    title = "Faster",
    items = {
      { "ci(", "change inside parentheses, from anywhere" },
      { "yyp", "duplicate the line" },
      { "ddp", "swap this line with the one below" },
      { "xp", "swap two characters" },
      { "guu / gUU", "whole line lower / upper case" },
      { "C-a / C-x", "bump the number under the cursor" },
      { ":earlier 5m", "time-travel undo, 5 minutes back" },
      { ":later 5m", "time-travel redo" },
    },
  },
  {
    title = "Surround (plugin)",
    items = {
      { 'ysiw"', "wrap the word in double quotes" },
      { "ysiw)", "wrap the word in parentheses" },
      { 'yss"', "wrap the whole line" },
      { "cs\"'", "change double quotes to single" },
      { "ds(", "delete surrounding parentheses" },
      { 'S"', "visual mode: wrap the selection" },
    },
  },
}

-- Named buckets for mappings whose desc starts with "LSP: ..." or "Git: ...".
local group_names = {
  LSP = "Language server",
  Git = "Git",
  Panel = "This panel",
}

local function set_highlights()
  local hl = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end
  hl("CheatTitle", { fg = p.fg_bright, bold = true })
  hl("CheatSection", { fg = p.blue_br, bold = true })
  hl("CheatCustom", { fg = p.green_br, bold = true })
  hl("CheatKey", { fg = p.cyan_br })
  hl("CheatDesc", { fg = p.fg_dim })
  hl("CheatRule", { fg = p.border })
  hl("CheatMuted", { fg = p.muted })
  hl("CheatTag", { fg = p.yellow })
end
set_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_highlights })

-- keytrans turns a raw lhs into a readable string. The leader is a space, so
-- a leading <Space> is shown as <leader>, matching what you actually type.
local function display_lhs(raw)
  local lhs = vim.fn.keytrans(raw)
  lhs = lhs:gsub("<lt>", "<")
  if vim.g.mapleader == " " then
    lhs = lhs:gsub("^<Space>", "<leader>")
  end
  return lhs
end

local function mode_tag(mode)
  if mode == "n" or mode == "" then
    return nil
  end
  if mode == "x" then
    return "v"
  end
  return mode
end

-- Group a mapping by its desc prefix ("LSP: ...") or drop it in Custom.
local function bucket(desc)
  local prefix = desc:match("^(%u[%u%s]-):%s")
  if prefix then
    return group_names[prefix] or prefix
  end
  return "Custom"
end

-- Neovim's own LSP defaults describe themselves as "vim.lsp.buf.rename()".
-- Rewrite those so they read like our maps and land in the LSP group.
local function clean_desc(desc)
  local fn = desc:match("^vim%.lsp%.[%w_%.]+%(%)$")
  if fn then
    local name = fn:gsub("%(%)$", ""):gsub("^vim%.lsp%.buf%.", ""):gsub("^vim%.lsp%.", ""):gsub("[_%.]", " ")
    return "LSP: " .. name
  end
  return desc
end

-- Noise: plugin internals, Neovim defaults that are just an ex command, and
-- autopairs' one-row-per-bracket maps. None of them teach anything.
local function noisy(desc, lhs)
  return desc:match("^autopairs") ~= nil
    or desc:match("^vim%.") ~= nil
    or desc:match("^:") ~= nil
    or desc:match("^<Plug>") ~= nil
    or desc:match("^[Oo]pens filepath") ~= nil
    or lhs:match("^<C%-W><C%-") ~= nil
end

-- "n,i,v" becomes no tag; insert-only becomes "i"; visual-only becomes "v".
local mode_letter = { x = "v" }
local function mode_tag(set)
  if set["n"] then
    return nil
  end
  local list = {}
  for m in pairs(set) do
    list[#list + 1] = mode_letter[m] or m
  end
  table.sort(list)
  return table.concat(list, ",")
end

-- Read global keymaps plus the ones local to `bufnr` (LSP binds, gitsigns).
-- The same lhs and desc from several modes collapses into one row with a tag.
local function collect(bufnr)
  local records, keys, seen = {}, {}, {}
  local noise = { ["jk"] = true, ["<Esc>"] = true }

  local function add(maps)
    for _, m in ipairs(maps) do
      local raw = m.desc
      if raw and raw ~= "" and raw ~= "which_key_ignore" and m.lhs and m.lhs ~= "" then
        local lhs = display_lhs(m.lhs)
        local desc = clean_desc(raw)
        if not noise[lhs] and not seen[lhs .. "\0" .. raw] and m.lhs:sub(1, 6) ~= "<Plug>"
          and not desc:match("^<Plug>") and not desc:match("^:help .*%-default$")
          and not noisy(desc, lhs) then
          seen[lhs .. "\0" .. raw] = true
          local key = lhs .. "\0" .. desc
          local rec = records[key]
          if rec then
            rec.mode_set[m.mode] = true
            rec.rhs = rec.rhs or (type(m.rhs) == "string" and m.rhs or nil)
          else
            records[key] = {
              key = lhs,
              desc = desc,
              mode_set = { [m.mode] = true },
              rhs = type(m.rhs) == "string" and m.rhs or nil,
            }
            keys[#keys + 1] = key
          end
        end
      end
    end
  end

  for _, mode in ipairs({ "n", "x", "i" }) do
    add(vim.api.nvim_get_keymap(mode))
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      add(vim.api.nvim_buf_get_keymap(bufnr, mode))
    end
  end

  local buckets, order = {}, {}
  for _, key in ipairs(keys) do
    local rec = records[key]
    local name = bucket(rec.desc)
    if not buckets[name] then
      buckets[name] = {}
      order[#order + 1] = name
    end
    table.insert(buckets[name], { key = rec.key, desc = rec.desc, tag = mode_tag(rec.mode_set), rhs = rec.rhs })
  end

  local preferred = { Custom = 1, ["Language server"] = 2, Git = 3, ["This panel"] = 4 }
  table.sort(order, function(a, b)
    local pa, pb = preferred[a] or 50, preferred[b] or 50
    if pa ~= pb then
      return pa < pb
    end
    return a < b
  end)
  for _, name in ipairs(order) do
    table.sort(buckets[name], function(a, b)
      return a.key < b.key
    end)
  end
  return order, buckets
end

-- Build the buffer contents and paint them.
local function rebuild()
  local texts, marks = {}, {}
  rows = {}

  local function push(text, row_marks)
    texts[#texts + 1] = text
    marks[#marks + 1] = row_marks or {}
  end

  local function header(title, group)
    local rule = string.rep("─", math.max(0, WIDTH - 2 - vim.fn.strchars(title)))
    push(" " .. title .. " " .. rule, { { 0, 1, "CheatRule" }, { 1, 1 + #title, group }, { 1 + #title, WIDTH, "CheatRule" } })
  end

  local function item(key, desc, tag)
    local line = "  " .. string.format("%-" .. (KEYCOL - 2) .. "s", key) .. desc
    if tag then
      line = line .. "  " .. tag
    end
    local m = { { 2, 2 + #key, "CheatKey" }, { KEYCOL, KEYCOL + #desc, "CheatDesc" } }
    if tag then
      m[#m + 1] = { KEYCOL + #desc + 2, KEYCOL + #desc + 2 + #tag, "CheatTag" }
    end
    push(line, m)
    rows[#texts] = { key = key, desc = desc, tag = tag }
  end

  -- title block
  push("  KEYBINDS", { { 2, 10, "CheatTitle" } })
  local lead = vim.g.mapleader == " " and "<Space>" or display_lhs(vim.g.mapleader)
  push("  leader " .. lead, { { 2, 8, "CheatMuted" }, { 9, 9 + #lead, "CheatKey" } })
  local hint = "  q close  <CR> explain  y copy  ]s next"
  push(hint, { { 2, #hint, "CheatMuted" } })
  push("", {})

  for _, section in ipairs(reference) do
    header(section.title, "CheatSection")
    for _, kv in ipairs(section.items) do
      item(kv[1], kv[2])
    end
    push("", {})
  end

  local order, buckets = collect(origin and vim.api.nvim_win_get_buf(origin) or 0)
  if #order > 0 then
    header("YOUR SHORTCUTS", "CheatCustom")
    for _, name in ipairs(order) do
      if name ~= "Custom" then
        push("  " .. name, { { 2, 2 + #name, "CheatSection" } })
      end
      for _, m in ipairs(buckets[name]) do
        item(m.key, m.desc, m.tag)
      end
      push("", {})
    end
  end

  buf = buf or vim.api.nvim_create_buf(false, true)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, texts)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for i, line_marks in ipairs(marks) do
    for _, m in ipairs(line_marks) do
      local end_col = math.min(m[2], #texts[i])
      if end_col > m[1] then
        vim.api.nvim_buf_set_extmark(buf, ns, i - 1, m[1], { end_col = end_col, hl_group = m[3], priority = 100 })
      end
    end
  end
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false
end

-- A small float that explains the row under the cursor.
local function explain()
  local row = rows[vim.api.nvim_win_get_cursor(win)[1]]
  if not row then
    return
  end
  local lines = {
    row.key .. (row.tag and ("   [" .. row.tag .. "]") or ""),
    "",
    row.desc,
  }
  if row.rhs and row.rhs ~= "" and not row.rhs:match("^<Cmd>") and not row.rhs:match("^function") then
    lines[#lines + 1] = "runs: " .. row.rhs
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "press y in the panel to copy the keys"
  local w = math.min(math.max(vim.fn.strchars(lines[1]) + 6, 40), WIDTH)
  local float = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
    relative = "cursor",
    row = 1,
    col = 2,
    width = w,
    height = #lines,
    style = "minimal",
    border = "rounded",
    title = " explain ",
    title_pos = "left",
  })
  local fb = vim.api.nvim_win_get_buf(float)
  vim.bo[fb].modifiable = true
  vim.api.nvim_buf_set_lines(fb, 0, -1, false, lines)
  vim.bo[fb].modifiable = false
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = fb })
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = fb })
end

local function panel_keymaps()
  local opts = { buffer = buf, nowait = true }
  vim.keymap.set("n", "q", M.close, vim.tbl_extend("force", opts, { desc = "Panel: close" }))
  vim.keymap.set("n", "<Esc>", M.close, vim.tbl_extend("force", opts, { desc = "Panel: close" }))
  vim.keymap.set("n", "<CR>", explain, vim.tbl_extend("force", opts, { desc = "Panel: explain key" }))
  vim.keymap.set("n", "R", function()
    rebuild()
    vim.notify("Keybinds refreshed", vim.log.levels.INFO)
  end, vim.tbl_extend("force", opts, { desc = "Panel: rebuild list" }))
  vim.keymap.set("n", "y", function()
    local row = rows[vim.api.nvim_win_get_cursor(win)[1]]
    if row then
      vim.fn.setreg("+", row.key)
      vim.notify("Copied " .. row.key, vim.log.levels.INFO)
    end
  end, vim.tbl_extend("force", opts, { desc = "Panel: copy keys" }))
  vim.keymap.set("n", "]s", function()
    vim.fn.search("^ \\u", "W")
  end, vim.tbl_extend("force", opts, { desc = "Panel: next section" }))
  vim.keymap.set("n", "[s", function()
    vim.fn.search("^ \\u", "bW")
  end, vim.tbl_extend("force", opts, { desc = "Panel: previous section" }))
end

local function configure_win()
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].foldcolumn = "0"
  vim.wo[win].cursorline = true
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].winfixwidth = true
  vim.wo[win].list = false
  vim.wo[win].spell = false
  vim.wo[win].winhighlight = "CursorLine:Visual"
end

function M.close()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  win = nil
  if origin and vim.api.nvim_win_is_valid(origin) then
    vim.api.nvim_set_current_win(origin)
  end
  origin = nil
end

function M.open()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_set_current_win(win)
    return
  end
  origin = vim.api.nvim_get_current_win()
  local ok = pcall(vim.cmd, "botright " .. WIDTH .. "vsplit")
  if not ok then
    origin = nil
    vim.notify("Could not open the keybind sidebar here", vim.log.levels.WARN)
    return
  end
  win = vim.api.nvim_get_current_win()

  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].filetype = "cheatsheet"
  end
  vim.api.nvim_win_set_buf(win, buf)
  configure_win()
  rebuild()
  if not vim.b[buf].mapped then
    panel_keymaps()
    vim.b[buf].mapped = true
  end
  vim.api.nvim_win_set_cursor(win, { 1, 0 })
end

function M.toggle()
  if win and vim.api.nvim_win_is_valid(win) then
    M.close()
  else
    M.open()
  end
end

-- Keep `win` honest when the panel is closed some other way (:q, :only, tab close).
vim.api.nvim_create_autocmd("WinClosed", {
  callback = function(args)
    if win and tonumber(args.match) == win then
      win = nil
    end
  end,
})

return M
