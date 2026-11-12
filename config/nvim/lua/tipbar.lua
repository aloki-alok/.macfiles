-- Auto-rotating keybind tip bar.
-- Reads your real keymaps (global + current buffer) and cycles one tip at a
-- time in the statusline, so every mapping with a `desc` teaches itself with
-- zero manual upkeep. Add a new map(..., { desc = "..." }) and it joins the
-- rotation. Buffer-local maps (like the LSP binds set on LspAttach) only show
-- up while you are in a buffer that has them, giving a light context-aware feel.

local M = {}

-- Defaults, overridable via M.start(opts).
local config = {
  interval = 4000,            -- ms between tips
  shuffle = true,             -- random order vs a fixed loop
  modes = { "n", "v", "i" },  -- which modes' maps to teach
  icon = "💡",
  max_desc = 60,              -- trim long descriptions
  ignore = {                  -- lhs (as displayed) to skip as noise
    ["jk"] = true,
    ["<Esc>"] = true,
  },
}

local pool = {}   -- list of { lhs = "...", desc = "..." }
local order = {}  -- indices into pool, possibly shuffled
local pos = 0     -- current position in order
local current = ""

-- Turn a raw lhs from get_keymap into something readable. keytrans handles the
-- special keys (<S-l>, <C-p>, ...). It escapes a literal "<" to "<lt>" so the
-- string round-trips; for display we undo that. The leader is a space, which
-- keytrans renders as <Space>, so we relabel a leading one as <leader>.
local function display_lhs(raw)
  local lhs = vim.fn.keytrans(raw)
  lhs = lhs:gsub("<lt>", "<")
  if vim.g.mapleader == " " then
    lhs = lhs:gsub("^<Space>", "<leader>")
  end
  return lhs
end

-- Build the tip pool from global + current-buffer keymaps.
local function collect()
  local seen = {}
  local result = {}

  local function add(maps)
    for _, m in ipairs(maps) do
      local desc = m.desc
      -- Skip empty descs, <Plug> internals, which-key's hide marker, and the
      -- low-signal Neovim defaults whose desc is just ":help X-default".
      if desc and desc ~= "" and desc ~= "which_key_ignore"
        and m.lhs and m.lhs ~= "" and not desc:match("^<Plug>")
        and not desc:match("^:help .*%-default$") then
        local lhs = display_lhs(m.lhs)
        if not config.ignore[lhs] then
          local key = lhs .. "\0" .. desc
          if not seen[key] then
            seen[key] = true
            if vim.fn.strchars(desc) > config.max_desc then
              desc = vim.fn.strcharpart(desc, 0, config.max_desc - 1) .. "…"
            end
            result[#result + 1] = { lhs = lhs, desc = desc }
          end
        end
      end
    end
  end

  for _, mode in ipairs(config.modes) do
    add(vim.api.nvim_get_keymap(mode))
    add(vim.api.nvim_buf_get_keymap(0, mode))
  end

  return result
end

-- Rebuild the pool and recompute the visiting order.
local function rebuild()
  pool = collect()
  order = {}
  for i = 1, #pool do
    order[i] = i
  end
  if config.shuffle then
    for i = #order, 2, -1 do
      local j = math.random(i)
      order[i], order[j] = order[j], order[i]
    end
  end
  pos = 0
end

-- Advance to the next tip. Rebuilds when the loop wraps so newly-attached
-- buffer-local maps and any config edits enter rotation without a restart.
local function advance()
  if pos >= #order or #order == 0 then
    rebuild()
  end
  if #pool == 0 then
    current = ""
    return
  end
  pos = pos + 1
  local tip = pool[order[pos]]
  current = string.format("%s %s → %s", config.icon, tip.lhs, tip.desc)
end

-- The string lualine renders. Cheap: returns the cached current tip.
function M.current()
  return current
end

-- Expose the pool for headless verification.
function M._pool()
  if #pool == 0 then
    rebuild()
  end
  return pool
end

function M.start(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  math.randomseed(os.time())
  advance() -- show one immediately instead of a blank slot
  vim.fn.timer_start(config.interval, function()
    advance()
    local ok, lualine = pcall(require, "lualine")
    if ok then
      lualine.refresh()
    end
  end, { ["repeat"] = -1 })
end

return M
