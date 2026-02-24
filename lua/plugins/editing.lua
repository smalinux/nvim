-- Editing Utilities
return {
  -- -- Treesitter (better syntax highlighting)
  -- {
  --     'nvim-treesitter/nvim-treesitter',
  --     build = ':TSUpdate',
  --     event = { 'BufReadPost', 'BufNewFile' },
  --     config = function()
  --         require('nvim-treesitter.configs').setup({
  --             ensure_installed = {
  --                 'c', 'cpp', 'python', 'lua', 'vim', 'vimdoc', 'bash',
  --                 'json', 'yaml', 'toml', 'markdown', 'html', 'css',
  --                 'javascript', 'typescript', 'cmake', 'make',
  --             },
  --             highlight = {
  --                 enable = true,
  --                 additional_vim_regex_highlighting = false,
  --             },
  --             indent = {
  --                 enable = true,
  --             },
  --             incremental_selection = {
  --                 enable = true,
  --                 keymaps = {
  --                     init_selection = '<C-space>',
  --                     node_incremental = '<C-space>',
  --                     scope_incremental = '<C-s>',
  --                     node_decremental = '<M-space>',
  --                 },
  --             },
  --         })
  --     end,
  -- },

  -- -- Comment.nvim (better commenting)
  -- {
  --     'numToStr/Comment.nvim',
  --     keys = {
  --         { 'gcc', mode = 'n', desc = 'Comment toggle current line' },
  --         { 'gc', mode = { 'n', 'o' }, desc = 'Comment toggle linewise' },
  --         { 'gc', mode = 'x', desc = 'Comment toggle linewise (visual)' },
  --         { 'gbc', mode = 'n', desc = 'Comment toggle current block' },
  --         { 'gb', mode = { 'n', 'o' }, desc = 'Comment toggle blockwise' },
  --         { 'gb', mode = 'x', desc = 'Comment toggle blockwise (visual)' },
  --     },
  --     config = function()
  --         require('Comment').setup()
  --     end,
  -- },

  -- -- Surround text objects
  -- {
  --     'kylechui/nvim-surround',
  --     event = 'VeryLazy',
  --     config = function()
  --         require('nvim-surround').setup({})
  --     end,
  -- },

  -- -- Exchange text (vim-exchange replacement)
  -- {
  --     'tommcdo/vim-exchange',
  --     keys = {
  --         { 'cx', mode = { 'n', 'x' } },
  --         { 'cxx', mode = 'n' },
  --         { 'cxc', mode = 'n' },
  --     },
  -- },

  -- -- Visual star search
  -- {
  --     'bronson/vim-visual-star-search',
  --     keys = {
  --         { '*', mode = 'v' },
  --         { '#', mode = 'v' },
  --     },
  -- },

  -- -- Alignment (Tabular replacement)
  -- {
  --     'junegunn/vim-easy-align',
  --     keys = {
  --         { 'ga', '<Plug>(EasyAlign)', mode = { 'n', 'x' }, desc = 'Easy Align' },
  --     },
  -- },

  -- -- Spell checking (spelunker replacement)
  -- {
  --     'lewis6991/spellsitter.nvim',
  --     config = function()
  --         require('spellsitter').setup({
  --             enable = false, -- disabled by default like in original config
  --         })
  --     end,
  -- },

  -- -- Session management
  -- {
  --     'rmagatti/auto-session',
  --     config = function()
  --         require('auto-session').setup({
  --             log_level = 'error',
  --             auto_session_enable_last_session = false,
  --             auto_session_root_dir = vim.fn.stdpath('data') .. '/sessions/',
  --             auto_session_enabled = true,
  --             auto_save_enabled = true,
  --             auto_restore_enabled = false,
  --             auto_session_suppress_dirs = { '~/', '~/Downloads', '/' },
  --         })

  --         -- Keymaps
  --         vim.keymap.set('n', '<leader>so', '<cmd>SessionSearch<cr>', { desc = 'Open Session' })
  --         vim.keymap.set('n', '<leader>ss', '<cmd>SessionSave<cr>', { desc = 'Save Session' })
  --         vim.keymap.set('n', '<leader>sd', '<cmd>SessionDelete<cr>', { desc = 'Delete Session' })
  --     end,
  -- },

  -- -- Vimux replacement (tmux integration)
  -- {
  --     'preservim/vimux',
  --     keys = {
  --         { '<leader>rp', '<cmd>VimuxPromptCommand<cr>', desc = 'Vimux Prompt' },
  --         { '<leader>rl', '<cmd>VimuxRunLastCommand<cr>', desc = 'Vimux Run Last' },
  --         { '<leader>ri', '<cmd>VimuxInterruptRunner<cr>', desc = 'Vimux Interrupt' },
  --     },
  --     config = function()
  --         vim.g.VimuxUseNearestPane = 1
  --     end,
  -- },

  -- -- Rainbow CSV
  -- {
  --     'mechatroner/rainbow_csv',
  --     ft = { 'csv', 'tsv' },
  -- },

  -- -- Jupyter notebooks
  -- {
  --     'goerz/jupytext.vim',
  --     ft = { 'ipynb' },
  -- },

  -- -- Emoji support
  -- {
  --     'allaman/emoji.nvim',
  --     ft = { 'markdown', 'text' },
  --     config = function()
  --         require('emoji').setup({
  --             enable_cmp_integration = true,
  --         })
  --     end,
  -- },

  -- Handle trailing whitespace
  {
    "nvim-mini/mini.trailspace",
    version = false,
    config = function()
      require("mini.trailspace").setup()
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function()
          -- require("mini.trailspace").trim()
        end,
      })
    end,
  },

  -- NOTE: For fancy comments
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      keywords = {
        ME = { icon = " ", color = "me", alt = { "SMA", "SMALINUX" } },
      },
      colors = {
        me = { "DiagnosticError", "ErrorMsg", "#6A0DAD" },
      },
    },
  },

  -- ~/.config/nvim/lua/plugins/quickfix.lua
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    dependencies = {
      {
        "junegunn/fzf",
        build = function()
          vim.fn["fzf#install"]()
        end,
      },
    },
    opts = {
      auto_enable = true,
      preview = {
        win_height = 999,
        win_vheight = 999,
        delay_syntax = 0,
        border = "rounded",
        show_title = true,
      },
      func_map = {
        vsplit = "",
        ptogglemode = "z,",
        stoggleup = "",
      },
    },
  },

  -- Tabularize
  "godlygeek/tabular",
  cmd = { "Tabularize" },
}
