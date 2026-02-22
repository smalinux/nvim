--
-- Neovim Configuration (converted from .vimrc)
--
-- Leader key must be set before (require("config.lazy")) lazy.nvim
vim.g.mapleader = ','
vim.g.maplocalleader = ','

--
-- include "lazy.nvim" file, LazyVim and your plugins
require("config.lazy")

-- To prevent Neovim from creating swap files, add this to your init.lua:
vim.opt.swapfile = false

vim.opt.list = true
vim.opt.listchars = {
  tab = "→ ",       -- Arrow for tabs
  trail = "·",      -- Dot for trailing spaces
  space = "·",      -- Dot for each space
  eol = "↲",     -- End of line
  nbsp = "␣",    -- Non-breaking space
  extends = "»", -- Line continues beyond screen
  precedes = "«",-- Line starts before screen
}

-- Basic Settings
local opt = vim.opt

-- UI Settings
-- ============================================================================
-- Show absolute line numbers in the gutter
opt.number = true
-- Show line numbers relative to cursor position for easier navigation
opt.relativenumber = true
-- Highlight the line where cursor is located
opt.cursorline = true
-- Show search matches as you type
opt.incsearch = true
-- Display vertical line at column 80 for code width reference
opt.colorcolumn = "80"
-- Open horizontal splits below current window
opt.splitbelow = true
-- Open vertical splits to the right of current window
opt.splitright = true
-- Always show sign column to prevent text shifting when signs appear
opt.signcolumn = "yes"
-- Always show status line at the bottom
opt.laststatus = 2
-- Hide mode indicator (INSERT, NORMAL) since it's shown in statusline
opt.showmode = false

-- History and Search
-- ============================================================================
-- Keep 1000 lines of command history
opt.history = 10000
-- Ignore case in search patterns
opt.ignorecase = true
-- Override ignorecase if search contains uppercase letters
opt.smartcase = true
-- Highlight all search matches
opt.hlsearch = true

-- Files and Backup
-- ============================================================================
-- Save undo history to file for persistent undo across sessions
opt.undofile = true
opt.undolevels = 10000  -- Maximum number of changes that can be undone
opt.undoreload = 10000  -- Maximum number lines to save for undo on buffer reload
-- Directory where undo files are stored
opt.undodir = vim.fn.expand("~/.vim/undodir")
-- Don't create backup files
opt.backup = false
-- Don't create backup before overwriting a file
opt.writebackup = false
-- Don't create swap files
opt.swapfile = false
-- Automatically reload files changed outside of Neovim
opt.autoread = true

-- Indentation
-- ============================================================================
-- Convert tabs to spaces
opt.expandtab = false
-- Number of spaces a tab character represents
opt.tabstop = 4  -- SMA: DO NOT CHANGE this -- it is just virtual in vim, not real.
-- Number of spaces inserted when pressing Tab key
opt.softtabstop = 2
-- Number of spaces used for each indentation level
opt.shiftwidth = 4
-- Automatically indent new lines based on context
opt.smartindent = true
-- Copy indent from current line when starting a new line
opt.autoindent = true
-- Copy the structure of existing indentation
opt.copyindent = true
-- Smart tab behavior at beginning of line
opt.smarttab = true
-- Disable auto-formatting on save
vim.g.autoformat = false

opt.cindent = true
-- Wrap long lines at word boundaries instead of mid-word
opt.linebreak = true

-- Wrap text at 80 characters when using gq
opt.textwidth = 80
-- Use built-in gq formatter instead of LazyVim's LSP formatters
opt.formatexpr = ""

-- Mouse and Misc
-- Enable mouse support only in normal mode
opt.mouse = "n"
-- Faster completion and swap file writing (milliseconds)
opt.updatetime = 300
-- Set default encoding to UTF-8
opt.encoding = "utf-8"

vim.opt.guicursor = {
  "n-v-c:block-blinkwait700-blinkoff400-blinkon250",
  "i-ci-ve:ver25-blinkwait700-blinkoff400-blinkon250",
  "r-cr:hor20-blinkwait700-blinkoff400-blinkon250",
}
