-- ============================================================================
-- [[ Neuralink IDE — 2026 Agentic Neovim Config ]]
-- ============================================================================
-- Catppuccin Mocha · Snacks · LSP · Treesitter · Agent Integration
-- Leader: Space | Terminal: Ghostty | Multiplexer: Tmux
-- ============================================================================

-- [[ Leader Key ]]
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================================
-- [[ Vim Options ]]
-- ============================================================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.undofile = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.showmode = false
vim.opt.autoread = true

-- ============================================================================
-- [[ Bootstrap Lazy.nvim ]]
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- [[ Plugin Setup ]]
-- ============================================================================
require("lazy").setup({

  -- --------------------------------------------------------------------------
  -- Colorscheme: Catppuccin Mocha
  -- --------------------------------------------------------------------------
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = false,
      integrations = {
        gitsigns = true,
        mason = true,
        treesitter = true,
        which_key = true,
        snacks = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- --------------------------------------------------------------------------
  -- Snacks.nvim — UI toolkit
  -- --------------------------------------------------------------------------
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      dashboard = { enabled = true },
      picker = { enabled = true },
      notifier = { enabled = true },
      indent = { enabled = true },
      lazygit = { enabled = true },
      terminal = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },

  -- --------------------------------------------------------------------------
  -- 1. THE FRONTEND: OpenCode.nvim (PRESERVED — do not modify)
  -- --------------------------------------------------------------------------
	{
	  "sudo-tee/opencode.nvim",
	  version = "*",
	  dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
	  opts = {
	    keymap_prefix = "<leader>o",
	    -- We set this to 'vim_complete' so the plugin doesn't try to auto-inject its broken setup
	    preferred_completion = "vim_complete",
	  },
	},

  -- --------------------------------------------------------------------------
  -- 2. THE ENGINE: Blink.cmp (PRESERVED — do not modify)
  -- --------------------------------------------------------------------------
	{
	  'saghen/blink.cmp',
	  version = '*',
	  opts = {
	    keymap = { preset = 'super-tab' },
	    sources = {
	      -- REMOVED 'agentic' to fix your module error.
	      -- Added 'opencode' which is the stable completion for your agent.
	      default = { 'lsp', 'path', 'snippets', 'buffer', 'opencode' },
	      providers = {
		opencode = {
		  name = 'OpenCode',
		  module = 'opencode.ui.completion.engines.blink_cmp',
		  score_offset = 100,
		},
	      },
	    },
	  },
	},

  -- --------------------------------------------------------------------------
  -- LSP: nvim-lspconfig + Mason
  -- --------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },

  -- --------------------------------------------------------------------------
  -- Treesitter
  -- --------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "python", "javascript", "typescript", "tsx",
          "go", "rust", "bash", "json", "yaml", "toml",
          "html", "css", "markdown", "markdown_inline",
          "vim", "vimdoc", "regex", "c", "cpp",
        },
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = "<C-cr>",
            node_decremental = "<bs>",
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]c"] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[c"] = "@class.outer",
            },
          },
        },
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- Which-Key
  -- --------------------------------------------------------------------------
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>b", group = "buffer" },
        { "<leader>r", group = "refactor" },
        { "<leader>c", group = "code" },
        { "<leader>o", group = "opencode" },
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- Git Signs
  -- --------------------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- Mini: Pairs & Surround
  -- --------------------------------------------------------------------------
  { "echasnovski/mini.pairs", event = "InsertEnter", opts = {} },
  { "echasnovski/mini.surround", event = "VeryLazy", opts = {} },

  -- --------------------------------------------------------------------------
  -- Conform: Formatting
  -- --------------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black", "isort" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        go = { "gofmt" },
        rust = { "rustfmt" },
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_format = "fallback",
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- Trouble: Diagnostics list
  -- --------------------------------------------------------------------------
  { "folke/trouble.nvim", cmd = "Trouble", opts = {} },

})

-- ============================================================================
-- [[ LSP Configuration ]]
-- ============================================================================

-- LSP on_attach: sets keymaps when a language server attaches to a buffer
local function on_attach(_, bufnr)
  local map = function(keys, func, desc)
    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
  end

  map("gd", vim.lsp.buf.definition, "Goto Definition")
  map("gr", vim.lsp.buf.references, "References")
  map("gI", vim.lsp.buf.implementation, "Goto Implementation")
  map("K", vim.lsp.buf.hover, "Hover Documentation")
  map("<leader>rn", vim.lsp.buf.rename, "Rename")
  map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
  map("<leader>D", vim.lsp.buf.type_definition, "Type Definition")

  -- Enable inlay hints if supported
  if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "pyright",
    "ts_ls",
    "gopls",
    "rust_analyzer",
    "bashls",
    "jsonls",
    "yamlls",
  },
  handlers = {
    function(server_name)
      require("lspconfig")[server_name].setup({
        on_attach = on_attach,
      })
    end,
  },
})

-- ============================================================================
-- [[ Keymaps ]]
-- ============================================================================

local map = vim.keymap.set

-- General
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Diagnostics
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map("n", "<leader>q", "<cmd>Trouble toggle diagnostics<cr>", { desc = "Trouble diagnostics" })

-- Picker (Snacks)
map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find files" })
map("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Live grep" })
map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
map("n", "<leader>fh", function() Snacks.picker.help() end, { desc = "Help tags" })
map("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent files" })
map("n", "<leader>fs", function() Snacks.picker.lsp_symbols() end, { desc = "LSP symbols" })

-- Git
map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit" })
map("n", "<leader>gb", function() Snacks.git.blame_line() end, { desc = "Git blame line" })

-- ============================================================================
-- [[ Live Refresh — Debounced FS Watcher (LibUV) ]]
-- ============================================================================
-- Watches the working directory for file changes made by agents or external
-- tools, then triggers checktime to reload modified buffers.

local function setup_fs_watcher()
  local watcher = vim.uv.new_fs_event()
  local timer = vim.uv.new_timer()
  local path = vim.fn.getcwd()
  local debounce_ms = 200

  -- Patterns to ignore
  local ignore_patterns = {
    "%.git/",
    "%.swp$",
    "~$",
    "%.o$",
    "node_modules/",
    "__pycache__/",
    "%.pyc$",
  }

  local function should_ignore(fname)
    if not fname then return true end
    for _, pattern in ipairs(ignore_patterns) do
      if fname:match(pattern) then return true end
    end
    return false
  end

  local scheduled_check = vim.schedule_wrap(function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end)

  watcher:start(path, { recursive = true }, function(err, fname, _)
    if err then return end
    if should_ignore(fname) then return end

    -- Debounce: restart timer on each event, only fire after quiet period
    timer:stop()
    timer:start(debounce_ms, 0, scheduled_check)
  end)
end

setup_fs_watcher()

-- ============================================================================
-- [[ Autocommands ]]
-- ============================================================================

-- Fallback: Standard autoread on focus/cursor events
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("AgenticRefresh", { clear = true }),
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- [[ Agent Notification Hook ]] (PRESERVED — do not modify)
vim.api.nvim_create_autocmd("User", {
  pattern = "OpencodeTaskDone", -- Hook provided by opencode.nvim
  callback = function()
    require("snacks").notifier.show({
      msg = "OpenCode: Task Completed!",
      level = "info",
      title = "Agent Status",
      icon = "🤖",
    })
    -- Force a final refresh just in case
    vim.cmd('checktime')
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
