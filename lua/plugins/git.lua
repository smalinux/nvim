-- Git and Version Control
--
-- Gitsigns Keybindings Cheatsheet:
--   <leader>gb     : Blame line (full)
--   <leader>gp     : Preview hunk (floating popup)
--   <leader>gx     : Toggle deleted hunks
--
--   ]h / [h        : Next / Prev hunk
--   ]H / [H        : Last / First hunk
--
--   ih             : [text-obj] select hunk (visual/operator)
	--   vih   → visually select the current hunk
	--   dih   → delete the hunk
	--   yih   → yank the hunk
	--   cih   → change the hunk
--
-- Extra features:
--   <leader>gP     : Preview hunk inline (in buffer)
--   <leader>gd     : Diff this (vs index)
--   <leader>gD     : Diff this (vs HEAD~)
--
return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      --word_diff = true,
      diff_opts = {
        algorithm = "patience",
        internal = true,
        indent_heuristic = true,
        linematch = 60,
      },
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      preview_config = {
        -- Floating window options
        border = "rounded",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")

        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")

        map("n", "]H", function()
          gs.nav_hunk("last")
        end, "Last Hunk")
        map("n", "[H", function()
          gs.nav_hunk("first")
        end, "First Hunk")

        -- Preview (the star of the show)
        map("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")
        --map("n", "<leader>gP", gs.preview_hunk_inline, "Preview Hunk Inline")

        ---- Stage / reset
        --map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        --map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        --map("n", "<leader>gS", gs.stage_buffer, "Stage Buffer")
        --map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
        --map("n", "<leader>gu", gs.undo_stage_hunk, "Undo Stage Hunk")

        -- Diff views
        map("n", "<leader>gd", gs.diffthis, "Diff This")
        map("n", "<leader>gD", function()
          gs.diffthis("~")
        end, "Diff This ~")

        -- Blame
        map("n", "<leader>gb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")

        -- Toggle signs
        map("n", "<leader>gx", gs.toggle_deleted, "Toggle Deleted")

        -- Text object — select the hunk as a motion target
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select Hunk")
      end,
    },
    config = function(_, opts)
      require("gitsigns").setup(opts)
      -- Vivid word-level diff highlights in preview popup
      vim.api.nvim_set_hl(0, "GitSignsAddWord", { bg = "#2e5c2e", bold = true })
      vim.api.nvim_set_hl(0, "GitSignsDeleteWord", { bg = "#5c2e2e", bold = true })
      vim.api.nvim_set_hl(0, "GitSignsAddLn", { bg = "#1e3a1e" })
      vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { bg = "#3a1e1e" })
    end,
  },
}
