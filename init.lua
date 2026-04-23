-- ============================================================================
-- [[ Neuralink IDE — Neovim Config ]]
-- ============================================================================
-- Catppuccin Mocha · Snacks · LSP · Treesitter
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
if vim.env.SSH_TTY then
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    vim.g.clipboard = {
      name  = "OSC 52",
      copy  = { ["+"] = osc52.copy("+"),  ["*"] = osc52.copy("*") },
      paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
    }
  end
end
vim.opt.breakindent = true
vim.opt.showmode = false
vim.opt.autoread = true

-- ============================================================================
-- [[ Bootstrap Lazy.nvim ]]
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
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
        telescope = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- --------------------------------------------------------------------------
  -- Telescope — Fuzzy finder
  -- --------------------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end,
      },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          sorting_strategy = "ascending",
          layout_config = { prompt_position = "top" },
        },
      })
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- --------------------------------------------------------------------------
  -- LazyGit — Git TUI
  -- --------------------------------------------------------------------------
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- --------------------------------------------------------------------------
  -- Indent guides
  -- --------------------------------------------------------------------------
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {},
  },

  -- --------------------------------------------------------------------------
  -- Blink.cmp — Completion engine
  -- --------------------------------------------------------------------------
  {
    'saghen/blink.cmp',
    version = '*',
    opts = {
      keymap = { preset = 'super-tab' },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
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
          "lua", "bash", "markdown", "markdown_inline", "vim", "vimdoc",
        },
        auto_install = false,
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
      format_on_save = function(_)
        if vim.g.disable_autoformat then return end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
      notify_on_error = false,
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
  ensure_installed = {},
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

-- Picker (Telescope)
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "LSP symbols" })

-- Git
map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Lazygit" })
map("n", "<leader>gb", function() require("gitsigns").blame_line() end, { desc = "Git blame line" })

-- ============================================================================
-- [[ Autocommands ]]
-- ============================================================================

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("AutoRead", { clear = true }),
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
