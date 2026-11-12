-- alok's neovim config: lean, fast, VSCode-ish shortcuts, Noir theme.
-- Theme palette: lua/noir/palette.lua (ported from iTerm2 "Noir").
-- Colorscheme:   colors/noir.lua
-- Goes in ~/.config/nvim/init.lua

-- ============ options ============
vim.g.mapleader = " "          -- Space is the leader key
vim.g.maplocalleader = " "
vim.o.number = true            -- Line numbers
vim.o.relativenumber = true    -- Relative numbers
vim.o.mouse = "a"              -- Mouse works everywhere
vim.o.clipboard = "unnamedplus" -- Yank/paste uses macOS clipboard
vim.o.ignorecase = true        -- Case-insensitive search...
vim.o.smartcase = true         -- ...unless you type a capital
vim.o.undofile = true          -- Undo history survives restarts
vim.o.swapfile = false
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.scrolloff = 8            -- Keep 8 lines visible around cursor
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.termguicolors = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300         -- How fast the bottom bar (which-key) pops up
vim.o.wrap = false             -- Code reads better unwrapped...
vim.o.completeopt = "menu,menuone,noselect"
vim.o.pumheight = 12
vim.o.winborder = "rounded"    -- Rounded floats to match the Noir chrome
vim.o.confirm = true           -- Ask to save instead of failing :q on dirty buffers
-- GUI font, for Neovide / VimR. Terminal Neovim inherits iTerm2's Hack Nerd
-- Font Mono 16, so this only bites in a GUI.
vim.o.guifont = "Hack Nerd Font Mono:h16"

-- Prose still wraps.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit", "asciidoc" },
  callback = function()
    vim.wo.wrap = true
    vim.wo.linebreak = true
  end,
})

-- ============ theme ============
-- Loads colors/noir.lua. Kept before plugins so nothing flashes the default.
vim.cmd.colorscheme("noir")

-- ============ keymaps ============
local map = vim.keymap.set

-- VSCode muscle memory
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- jk to escape insert mode (faster than reaching for Esc)
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Esc clears search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- quick save / quit
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

-- move between split windows with Ctrl + h/j/k/l
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- cycle buffers (open files) with Shift+H / Shift+L
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Close buffer" })

-- move selected lines up/down with J/K in visual mode
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- stay in visual mode when indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- ============ lazy.nvim bootstrap ============
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ============ LSP plumbing ============
-- Diagnostics: rounded floats, sorted by severity, virtual text on the line end.
vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  virtual_text = { spacing = 4, prefix = "●", source = "if_many" },
  float = { border = "rounded", source = true, header = "" },
})

-- ============ plugins ============
require("lazy").setup({
  -- fuzzy finder (VSCode Ctrl+P)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<C-p>",      "<cmd>Telescope find_files<cr>", desc = "Find files (VSCode Ctrl+P)" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Grep in project" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Open buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",   desc = "Recent files" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Project diagnostics" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Outline (document symbols)" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "Help" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>",    desc = "Find Keymaps (Cheat Sheet)" },
    },
    config = function()
      local p = require("noir.palette")
      require("telescope").setup({ defaults = { borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" } } })
      -- Paint Telescope in Noir. Telescope sets its groups on load, so this
      -- has to run after setup, not from the colorscheme.
      local hl = function(group, opts) vim.api.nvim_set_hl(0, group, opts) end
      hl("TelescopeNormal", { fg = p.fg, bg = p.bg_alt })
      hl("TelescopeBorder", { fg = p.border, bg = p.bg_alt })
      hl("TelescopeTitle", { fg = p.fg_bright, bg = p.bg_alt, bold = true })
      hl("TelescopePromptNormal", { fg = p.fg, bg = p.bg_alt })
      hl("TelescopePromptBorder", { fg = p.border, bg = p.bg_alt })
      hl("TelescopePromptTitle", { fg = p.bg, bg = p.blue_br, bold = true })
      hl("TelescopePromptPrefix", { fg = p.blue_br, bg = p.bg_alt })
      hl("TelescopePromptCounter", { fg = p.muted, bg = p.bg_alt })
      hl("TelescopeResultsNormal", { fg = p.fg, bg = p.bg })
      hl("TelescopeResultsBorder", { fg = p.border, bg = p.bg })
      hl("TelescopeResultsTitle", { fg = p.border, bg = p.bg })
      hl("TelescopePreviewNormal", { fg = p.fg, bg = p.bg_alt })
      hl("TelescopePreviewBorder", { fg = p.border, bg = p.bg_alt })
      hl("TelescopePreviewTitle", { fg = p.bg, bg = p.green, bold = true })
      hl("TelescopeSelection", { fg = p.fg_bright, bg = p.sel })
      hl("TelescopeSelectionCaret", { fg = p.green_br, bg = p.sel })
      hl("TelescopeMultiSelection", { fg = p.yellow, bg = p.bg_alt })
      hl("TelescopeMultiIcon", { fg = p.yellow })
      hl("TelescopeMatching", { fg = p.cyan_br, bold = true })
      hl("TelescopeResultsComment", { fg = p.fg_dim })
      hl("TelescopeResultsIdentifier", { fg = p.blue_br })
      hl("TelescopeResultsNumber", { fg = p.yellow })
      hl("TelescopeResultsFunction", { fg = p.blue_br })
    end,
  },

  -- better syntax highlighting (nvim-treesitter "main" rewrite, Neovim 0.12+)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local parsers = {
        "lua", "luadoc", "vim", "vimdoc", "query", "printf",
        "python", "javascript", "typescript", "tsx", "jsdoc",
        "json", "yaml", "toml", "ini", "xml",
        "bash", "dockerfile", "make", "cmake", "diff", "gitignore",
        "markdown", "markdown_inline", "html", "css", "scss",
        "regex", "sql", "graphql", "hcl", "terraform",
      }
      require("nvim-treesitter").setup({})
      require("nvim-treesitter").install(parsers)

      -- The new plugin does not switch highlighting on by itself. Turn on
      -- treesitter where a parser exists, and use its indent queries.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- file browser: press "-" to see the current file's folder, edit it like a buffer
  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup({ view_options = { show_hidden = true } })
      map("n", "-", "<cmd>Oil<cr>", { desc = "Browse files" })
    end,
  },

  -- LSP Setup (VSCode like intelligence)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp", -- connects autocompletion to LSP
    },
    config = function()
      -- Completion capabilities must be read after lazy loads cmp-nvim-lsp.
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("mason").setup()
      -- ensure_installed installs what is missing. automatic_enable is off so a
      -- formatter CLI on PATH (stylua, prettier) cannot register itself as an
      -- LSP; the list below is the only thing that gets enabled.
      require("mason-lspconfig").setup({
        automatic_enable = false,
        ensure_installed = {
          "lua_ls", "ts_ls", "pyright", "ruff",         -- lua / TS / Python
          "html", "cssls", "emmet_language_server",      -- web
          "tailwindcss",                                 -- tailwind class intel
          "jsonls", "yamlls", "taplo", "dockerls",       -- config
          "bashls", "marksman",                          -- shell / markdown
        },
      })

      vim.lsp.enable({
        "lua_ls", "ts_ls", "pyright", "ruff",
        "html", "cssls", "emmet_language_server", "tailwindcss",
        "jsonls", "yamlls", "taplo", "dockerls",
        "bashls", "marksman",
      })

      -- Defaults for every server.
      vim.lsp.config("*", { capabilities = capabilities })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            hint = { enable = true, arrayIndex = "Disable" },
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      -- Python: pyright for types, ruff for lint/imports. Mirrors VS Code.
      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
              autoImportCompletions = true,
              inlayHints = {
                variableTypes = true,
                functionReturnTypes = true,
                callArgumentNames = false,
              },
            },
          },
        },
      })

      vim.lsp.config("ruff", {
        init_options = {
          settings = {
            organizeImports = true,
            fixAll = true,
            lineLength = 88,
            lint = { select = { "E", "F", "I", "UP", "B", "SIM" } },
          },
        },
      })

      vim.lsp.config("ts_ls", {
        single_file_support = true,
        settings = {
          typescript = {
            inlayHints = {
              parameterNames = { enabled = "literals" },
              variableTypes = true,
              functionLikeReturnTypes = true,
              enumMemberValues = { enabled = true },
            },
            preferences = { importModuleSpecifier = "non-relative" },
            updateImportsOnFileMove = { enabled = "always" },
          },
          javascript = {
            preferences = { importModuleSpecifier = "non-relative" },
            updateImportsOnFileMove = { enabled = "always" },
          },
        },
      })

      vim.lsp.config("tailwindcss", {
        settings = { tailwindCSS = { classAttributes = { "class", "className", "class:list" } } },
      })

      vim.lsp.config("emmet_language_server", {
        filetypes = { "css", "html", "javascriptreact", "typescriptreact", "svelte", "vue" },
      })

      -- LSP Keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map_lsp = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map_lsp("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
          map_lsp("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
          map_lsp("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
          map_lsp("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
          map_lsp("gy", vim.lsp.buf.type_definition, "[G]oto T[y]pe definition")
          map_lsp("K", vim.lsp.buf.hover, "Hover Documentation")
          map_lsp("gl", vim.diagnostic.open_float, "Line Diagnostics")
          map_lsp("gs", vim.lsp.buf.signature_help, "Signature Help")
          map_lsp("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
          map_lsp("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
          map_lsp("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous diagnostic")
          map_lsp("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")

          -- Toggle type/value hints on the current buffer.
          map_lsp("<leader>th", function()
            local on = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
            vim.lsp.inlay_hint.enable(not on, { bufnr = event.buf })
          end, "[T]oggle Inlay [H]ints")
        end,
      })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          -- Tab jumps through a snippet once expanded, else accepts a completion.
          ["<Tab>"] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            elseif cmp.visible() then
              cmp.confirm({ select = false })
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- Let a confirmed completion trigger the matching autopair.
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Autoformatting on save. Runners are installed by mason-tool-installer below.
  -- Python mirrors VS Code: ruff owns formatting, safe fixes and import order.
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      notify_on_error = false,
      format_on_save = {
        timeout_ms = 1000,
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_organize_imports", "ruff_fix", "ruff_format" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        vue = { "prettierd", "prettier", stop_after_first = true },
        svelte = { "prettierd", "prettier", stop_after_first = true },
        astro = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
        less = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        jsonc = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        graphql = { "prettierd", "prettier", stop_after_first = true },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        toml = { "taplo" },
      },
      formatters = {
        stylua = { prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" } },
        shfmt = { prepend_args = { "-i", "2", "-ci" } },
      },
    },
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
  },

  -- Installs the format runners and any extra tools Mason does not manage for us.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      run_on_start = true,
      ensure_installed = { "stylua", "prettier", "prettierd", "ruff", "shfmt", "taplo" },
    },
  },

  -- statusline in Noir, with an auto-rotating keybind cheat sheet.
  -- The tip segment reads your real keymaps (see lua/tipbar.lua) and cycles one
  -- at a time, so it teaches everything with a `desc` and never needs hand-editing.
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local p = require("noir.palette")
      require("lualine").setup({
        options = { theme = "noir" },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            { "filename", path = 1, symbols = { modified = " ●", readonly = " ro", unnamed = "[No Name]" } },
            {
              require("tipbar").current,
              color = { fg = p.cyan_br }, -- Noir cyan, matches the tip accent
            },
          },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
      require("tipbar").start()
    end,
  },

  -- bufferline: a tab strip across the top showing every open buffer, active
  -- one highlighted. Makes <S-h>/<S-l> cycling and <leader>x closing visible.
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Pick buffer (press its letter)" },
      { "<leader>1", "<cmd>BufferLineGoToBuffer 1<cr>", desc = "Go to buffer 1" },
      { "<leader>2", "<cmd>BufferLineGoToBuffer 2<cr>", desc = "Go to buffer 2" },
      { "<leader>3", "<cmd>BufferLineGoToBuffer 3<cr>", desc = "Go to buffer 3" },
      { "<leader>4", "<cmd>BufferLineGoToBuffer 4<cr>", desc = "Go to buffer 4" },
      { "<leader>5", "<cmd>BufferLineGoToBuffer 5<cr>", desc = "Go to buffer 5" },
      { "<leader>6", "<cmd>BufferLineGoToBuffer 6<cr>", desc = "Go to buffer 6" },
      { "<leader>7", "<cmd>BufferLineGoToBuffer 7<cr>", desc = "Go to buffer 7" },
      { "<leader>8", "<cmd>BufferLineGoToBuffer 8<cr>", desc = "Go to buffer 8" },
      { "<leader>9", "<cmd>BufferLineGoToBuffer -1<cr>", desc = "Go to last buffer" },
    },
    config = function(_, opts)
      local p = require("noir.palette")
      -- Noir palette for the tab strip.
      opts.options = opts.options or {}
      opts.options.highlights = {
        fill = { bg = p.bg },
        background = { fg = p.muted, bg = p.bg },
        buffer_visible = { fg = p.fg_dim, bg = p.bg },
        buffer_selected = { fg = p.fg_bright, bg = p.bg, bold = true },
        close_button = { fg = p.muted, bg = p.bg },
        close_button_visible = { fg = p.muted, bg = p.bg },
        close_button_selected = { fg = p.fg_bright, bg = p.bg },
        separator = { fg = p.border, bg = p.bg },
        separator_visible = { fg = p.border, bg = p.bg },
        separator_selected = { fg = p.border, bg = p.bg },
        indicator_visible = { fg = p.bg, bg = p.bg },
        indicator_selected = { fg = p.green_br, bg = p.bg },
        modified = { fg = p.yellow, bg = p.bg },
        modified_visible = { fg = p.yellow, bg = p.bg },
        modified_selected = { fg = p.yellow, bg = p.bg },
        duplicate = { fg = p.black_br, bg = p.bg },
        duplicate_visible = { fg = p.black_br, bg = p.bg },
        duplicate_selected = { fg = p.fg_dim, bg = p.bg },
        error = { fg = p.red, bg = p.bg },
        error_visible = { fg = p.red, bg = p.bg },
        error_selected = { fg = p.red, bg = p.bg },
        warning = { fg = p.yellow, bg = p.bg },
        warning_visible = { fg = p.yellow, bg = p.bg },
        warning_selected = { fg = p.yellow, bg = p.bg },
        info = { fg = p.blue, bg = p.bg },
        info_visible = { fg = p.blue, bg = p.bg },
        info_selected = { fg = p.blue, bg = p.bg },
        hint = { fg = p.cyan, bg = p.bg },
        hint_visible = { fg = p.cyan, bg = p.bg },
        hint_selected = { fg = p.cyan, bg = p.bg },
        tab = { fg = p.muted, bg = p.bg },
        tab_selected = { fg = p.fg_bright, bg = p.bg, bold = true },
        tab_separator = { fg = p.border, bg = p.bg },
        tab_separator_selected = { fg = p.border, bg = p.bg },
      }
      require("bufferline").setup(opts)
    end,
    opts = {
      options = {
        diagnostics = "nvim_lsp",       -- show LSP errors/warnings per buffer
        separator_style = "thin",
        show_buffer_close_icons = false,
        offsets = { { filetype = "oil", text = "Files", highlight = "Directory" } },
      },
    },
  },

  -- git change markers in the gutter
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      current_line_blame = false,
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function nmap(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "Git: " .. desc })
        end
        nmap("]c", function() gs.nav_hunk("next") end, "Next hunk")
        nmap("[c", function() gs.nav_hunk("prev") end, "Previous hunk")
        nmap("<leader>gp", gs.preview_hunk, "Preview hunk")
        nmap("<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        nmap("<leader>gs", gs.stage_hunk, "Stage hunk")
        nmap("<leader>gr", gs.reset_hunk, "Reset hunk")
      end,
    },
  },

  -- shows available keybindings when you pause after pressing <space>
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

  -- auto-close brackets/quotes
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true, -- use treesitter so quotes/brackets inside strings behave
      fast_wrap = {},
    },
  },

  -- auto-close and rename JSX / HTML tags
  { "windwp/nvim-ts-autotag", event = "InsertEnter", opts = {} },

  -- gc / gcc to toggle comments
  { "numToStr/Comment.nvim", event = { "BufReadPre", "BufNewFile" }, opts = {} },

  -- a diagnostics / references / symbols panel (VSCode "Problems")
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics (Trouble)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP defs / refs (Trouble)" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix (Trouble)" },
    },
    opts = { focus = true, auto_close = true, use_diagnostic_signs = true },
  },

  -- actively teaches you better in-depth keybinds as you use neovim!
  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    opts = {
      disable_mouse = false,
      hint = true,
    },
  },
})
