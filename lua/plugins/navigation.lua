return {
  {
    -- ========================================================================
    -- Plugin: harpoon2 (ThePrimeagen/harpoon, branch: harpoon2)
    -- Purpose: Fast file bookmarking and navigation via a named list of marks.
    --
    -- Keybindings:
    --   <leader>a       Add current file to the harpoon list
    --   <C-e>           Open Telescope picker; auto-selects the previously active
    --                   harpoon file so <CR> instantly jumps back to it
    --   <leader>h1-9    Jump directly to harpoon slot 1–9
    --
    -- Telescope Picker (insert mode, active while picker is open):
    --   <CR>            Open the selected file, by hitting Enter key.
    --   <C-d>           Delete selected mark; list re-renders immediately
    --   <C-p>           Move selected mark one position up
    --   <C-n>           Move selected mark one position down
    --   <Esc>           Close the picker
    --
    -- ========================================================================
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    config = function()
      -- Setup harpoon with defaults
      local harpoon = require("harpoon")
      harpoon:setup({})

      -- Build a telescope picker that pre-selects the previously active file and supports reorder/delete
      local conf = require("telescope.config").values
      local function toggle_telescope(harpoon_files)
        -- Resolve the previously active buffer path for default selection
        local current_file = vim.fn.fnamemodify(vim.fn.bufname("#"), ":.")
        local default_selection = 1

        -- Build a numbered finder: display = "1  path", value = raw path used by previewer/opener
        local function make_finder()
          local results = {}
          for i, item in ipairs(harpoon_files.items) do
            if item.value == current_file then default_selection = i end
            table.insert(results, { index = i, value = item.value })
          end
          return require("telescope.finders").new_table({
            results = results,
            entry_maker = function(entry)
              return {
                value   = entry.value,
                display = entry.index .. "  " .. entry.value,
                ordinal = entry.value,
                index   = entry.index,
              }
            end,
          })
        end

        -- Open picker with the previously active file pre-selected
        require("telescope.pickers")
          .new({}, {
            prompt_title = "Harpoon",
            finder = make_finder(),
            previewer = conf.file_previewer({}),
            sorter = conf.generic_sorter({}),
            default_selection_index = default_selection,
            attach_mappings = function(prompt_bufnr, map)
              -- Delete selected mark and immediately re-render with updated numbers
              map("i", "<C-d>", function()
                local state = require("telescope.actions.state")
                local selected_entry = state.get_selected_entry()
                local current_picker = state.get_current_picker(prompt_bufnr)
                table.remove(harpoon_files.items, selected_entry.index)
                current_picker:refresh(make_finder(), { reset_prompt = false })
              end)

              -- Rebuild finder and jump cursor to new_index after a reorder
              local function refresh_picker(current_picker, new_index)
                current_picker:refresh(
                  make_finder(),
                  { reset_prompt = false, new_prefix = current_picker:_get_prompt() }
                )
                current_picker:set_selection(new_index)
              end

              -- Move selected mark up in the list and re-render immediately
              map("i", "<C-p>", function()
                local state = require("telescope.actions.state")
                local selected_entry = state.get_selected_entry()
                local current_picker = state.get_current_picker(prompt_bufnr)
                local index = selected_entry.index
                if index > 1 then
                  harpoon_files.items[index], harpoon_files.items[index - 1] =
                    harpoon_files.items[index - 1], harpoon_files.items[index]
                  refresh_picker(current_picker, index - 1)
                end
              end)

              -- Move selected mark down in the list and re-render immediately
              map("i", "<C-n>", function()
                local state = require("telescope.actions.state")
                local selected_entry = state.get_selected_entry()
                local current_picker = state.get_current_picker(prompt_bufnr)
                local index = selected_entry.index
                if index < #harpoon_files.items then
                  harpoon_files.items[index], harpoon_files.items[index + 1] =
                    harpoon_files.items[index + 1], harpoon_files.items[index]
                  refresh_picker(current_picker, index + 1)
                end
              end)

              return true
            end,
          })
          :find()
      end

      -- Add current file to harpoon list
      vim.keymap.set("n", "<leader>a", function()
        harpoon:list():add()
      end, { desc = "Harpoon add file" })

      -- Open telescope picker (previous file pre-selected; press Enter to jump back)
      vim.keymap.set("n", "<C-e>", function()
        toggle_telescope(harpoon:list())
      end, { desc = "Open harpoon window" })

      -- Jump directly to harpoon slots 1–9
      for i = 1, 9 do
        vim.keymap.set("n", "<leader>h" .. i, function()
          harpoon:list():select(i)
        end, { desc = "Harpoon file " .. i })
      end
    end,
  },
}
