-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
--


-- ============================================================================
-- Reloads Neovim configuration by clearing cached Lua modules and re-sourcing init.lua
-- Useful for applying config changes without restarting Neovim
vim.api.nvim_create_user_command('ReloadConfig', function()
  -- Only clear YOUR custom modules, not LazyVim or plugin internals
  for name, _ in pairs(package.loaded) do
    if name:match('^config%.') or name:match('^plugins%.') then
      package.loaded[name] = nil
    end
  end
  dofile(vim.env.MYVIMRC)
  vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
end, {})


-- -- ============================================================================
-- -- Automatically remove trailing whitespace on save while preserving cursor position
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   group = vim.api.nvim_create_augroup("TrimWhitespace", { clear = true }),
--   pattern = "*",
--   callback = function()
--     -- Save cursor position
--     local save_cursor = vim.fn.getpos(".")
--     -- Remove trailing whitespace
--     vim.cmd([[%s/\s\+$//e]])
--     -- Restore cursor position
--     vim.fn.setpos(".", save_cursor)
--   end,
-- })


-- ============================================================================
-- CLANG-FORMAT STYLE AUTO-SWITCHER
-- ============================================================================
-- Purpose: Automatically detects and applies clang-format styles based on
--          file header comments before formatting occurs
--
-- How it works:
-- 1. Triggers when a C/C++/DTS file is opened (BufReadPost) or created (BufNewFile)
-- 2. Scans the first 10 lines of the file for a style directive comment
-- 3. Looks for pattern: "clang-format-style: <stylename>" in any comment type
--    Examples: // clang-format-style: kernel
--              /* clang-format-style: google */
--              * clang-format-style: llvm
-- 4. Extracts the style name (kernel, google, llvm, chromium, etc.)
-- 5. Locates the corresponding style file in ~/.config/nvim/clang-format-styles/
-- 6. Creates a symlink from ~/.clang-format → the selected style file
-- 7. Sets a buffer variable to mark this buffer for auto-formatting
-- 8. This symlink tells clang-format which style rules to use
-- 9. If no directive found, buffer is NOT marked for formatting
--
-- Style files location: ~/.config/nvim/clang-format-styles/
-- Active style symlink: ~/.clang-format
-- ============================================================================
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("ClangFormatStyleSwitcher", { clear = true }),
  pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.dts", "*.dtsi" },
  callback = function()
    -- Read first 10 lines of the buffer to search for style directive
    local lines = vim.api.nvim_buf_get_lines(0, 0, 10, false)

    -- Iterate through each line looking for the style pattern
    for _, line in ipairs(lines) do
      -- Pattern matches: "clang-format-style:" followed by whitespace and a word
      -- The %w+ captures alphanumeric style names (kernel, google, llvm, etc.)
      local style = line:match("clang%-format%-style:%s*(%w+)")

      if style then
        -- Build paths for source style file and target symlink
        local styles_dir = vim.fn.stdpath("config") .. "/clang-format-styles"
        local source = styles_dir .. "/" .. style  -- e.g., ~/.config/nvim/clang-format-styles/kernel
        local target = vim.fn.expand("~/.clang-format")  -- Home directory symlink

        -- Verify the style file exists before creating symlink
        if vim.fn.filereadable(source) == 1 then
          -- Create symbolic link (overwrites existing symlink if present)
          -- -s: create symbolic link, -f: force/overwrite existing
          vim.fn.system(string.format("ln -sf '%s' '%s'", source, target))

          -- Mark this buffer for auto-formatting by setting a buffer-local variable
          vim.b.clang_format_enabled = true

          vim.notify("Using '" .. style .. "' clang-format style", vim.log.levels.INFO)
        else
          vim.notify("Style file not found: " .. source, vim.log.levels.WARN)
        end
        -- Stop after first match - only one style directive per file
        break
      end
    end
  end,
})

-- ============================================================================
-- AUTO-FORMAT ON SAVE (CONDITIONAL)
-- ============================================================================
-- Purpose: Automatically formats C/C++/DTS files using clang-format when saved
--          ONLY if the file contains a clang-format-style directive comment
--
-- Execution flow:
-- 1. File save is initiated (user presses :w or saves via keybinding)
-- 2. BufWritePre event fires BEFORE the file is written to disk
-- 3. This autocmd checks if buffer variable 'clang_format_enabled' is set
-- 4. If NOT set (no style comment found), formatting is skipped entirely
-- 5. If set, calls conform.nvim's format() function with current buffer
-- 6. conform.nvim reads formatters_by_ft config (from lua/plugins/conform.lua)
-- 7. Identifies that C files should use 'clang_format' formatter
-- 8. Executes: clang-format --style=file <current-buffer-content>
-- 9. clang-format reads ~/.clang-format (the symlink created by first autocmd)
-- 10. Applies formatting rules from that style file
-- 11. conform.nvim replaces buffer content with formatted output
-- 12. Preserves cursor position during formatting
-- 13. File save continues with formatted content
-- 14. If formatting fails, timeout occurs after 3000ms and save proceeds
--
-- Requirements:
-- - File MUST contain "clang-format-style: <name>" comment in first 10 lines
-- - clang-format must be installed (apt install clang-format)
-- - conform.nvim must be configured in lua/plugins/conform.lua
-- - ~/.clang-format symlink must exist (created by first autocmd)
-- ============================================================================
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("ConformFormatOnSave", { clear = true }),
  pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.dts", "*.dtsi" },
  callback = function(args)
    -- Re-check if style directive exists on every save (in case user removed it)
    local lines = vim.api.nvim_buf_get_lines(0, 0, 10, false)
    local has_style_directive = false
    for _, line in ipairs(lines) do
      if line:match("clang%-format%-style:%s*(%w+)") then
        has_style_directive = true
        break
      end
    end
    -- Only format if the style directive comment is present
    if has_style_directive then
      require("conform").format({ bufnr = args.buf, timeout_ms = 3000 })
    end
  end,
})

-- ============================================================================
-- COMPLETE WORKFLOW EXAMPLE
-- ============================================================================
-- SCENARIO 1: File WITH clang-format-style comment
-- User action: nvim board.c
-- File content:
--   // clang-format-style: kernel
--   int main() {
--   int x=5;
--   }
--
-- Step 1: File opens
--   → BufReadPost event fires
--   → ClangFormatStyleSwitcher autocmd runs
--   → Reads file header: "// clang-format-style: kernel"
--   → Creates: ~/.clang-format → ~/.config/nvim/clang-format-styles/kernel
--   → Sets vim.b.clang_format_enabled = true
--   → Notification: "Using 'kernel' clang-format style"
--
-- Step 2: User edits code and saves (:w)
--   → BufWritePre event fires (before save)
--   → ConformFormatOnSave autocmd runs
--   → Checks vim.b.clang_format_enabled → TRUE
--   → Calls: require("conform").format()
--   → Code is formatted according to kernel style
--   → File saved with formatted content
--
-- SCENARIO 2: File WITHOUT clang-format-style comment
-- User action: nvim legacy.c
-- File content:
--   int main() {
--   int x=5;
--   }
--
-- Step 1: File opens
--   → BufReadPost event fires
--   → ClangFormatStyleSwitcher autocmd runs
--   → Scans first 10 lines: NO "clang-format-style:" found
--   → vim.b.clang_format_enabled NOT set (remains nil)
--   → No notification, no symlink created
--
-- Step 2: User edits code and saves (:w)
--   → BufWritePre event fires (before save)
--   → ConformFormatOnSave autocmd runs
--   → Checks vim.b.clang_format_enabled → NIL (false)
--   → Formatting SKIPPED
--   → File saved as-is without any formatting
--
-- Result: Only files with explicit style directive get auto-formatted
-- ============================================================================

-- local augroup = vim.api.nvim_create_augroup
-- local autocmd = vim.api.nvim_create_autocmd
--
-- -- Strip trailing whitespace on save
-- augroup('StripTrailingWhitespace', { clear = true })
-- autocmd('BufWritePre', {
--     group = 'StripTrailingWhitespace',
--     pattern = '*',
--     callback = function()
--         local save = vim.fn.winsaveview()
--         vim.cmd([[keeppatterns %s/\s\+$//e]])
--         vim.fn.winrestview(save)
--     end,
-- })
--
-- -- Remember last cursor position
-- augroup('RestoreCursor', { clear = true })
-- autocmd('BufReadPost', {
--     group = 'RestoreCursor',
--     pattern = '*',
--     callback = function()
--         local mark = vim.api.nvim_buf_get_mark(0, '"')
--         local line_count = vim.api.nvim_buf_line_count(0)
--         if mark[1] > 0 and mark[1] <= line_count then
--              vim.api.nvim_win_set_cursor(0, mark)
--         end
--     end,
-- })
--
-- -- Auto enter insert mode in terminal
-- augroup('TerminalSettings', { clear = true })
-- autocmd('WinEnter', {
--     group = 'TerminalSettings',
--     pattern = '*',
--     callback = function()
--         if vim.bo.buftype == 'terminal' then
--             vim.cmd('startinsert')
--         end
--     end,
-- })
--
-- -- Auto resize splits when vim is resized
-- augroup('AutoResize', { clear = true })
-- autocmd('VimResized', {
--     group = 'AutoResize',
--     pattern = '*',
--     command = 'wincmd =',
-- })
--

-- :Rg - Ripgrep and open in Telescope picker
-- Example:
--		:Rg xxx | rg yyy | rg zzz
--		:Rg 'device.*tree'
vim.api.nvim_create_user_command('Rg', function(opts)
  local cmd = "rg " .. opts.args .. " | cut -d: -f1 | sort -u"
  local results = vim.fn.systemlist(cmd)

  if #results > 0 then
    require('telescope.pickers').new({}, {
      prompt_title = 'Rg Results (' .. #results .. ' files)',
      finder = require('telescope.finders').new_table({
        results = results,
      }),
      sorter = require('telescope.config').values.generic_sorter({}),
      previewer = require('telescope.config').values.file_previewer({}),
    }):find()
  else
    vim.notify('No matches found', vim.log.levels.WARN)
  end
end, { nargs = '+' })

-- :Rg - Ripgrep and open all matches directly
-- Examples
--		:Rgg xxx | rg yyy | rg zzz
--		:Rgg 'device.*tree'
--
vim.api.nvim_create_user_command('Rgg', function(opts)
  local cmd = "rg " .. opts.args .. " | cut -d: -f1 | sort -u"
  local results = vim.fn.systemlist(cmd)
  if #results > 0 then
    vim.cmd("args " .. table.concat(results, " "))
    vim.notify(#results .. " files loaded", vim.log.levels.INFO)
  else
    vim.notify("No matches found", vim.log.levels.WARN)
  end
end, { nargs = '+' })

-- keybind for :Rg
vim.keymap.set('n', '<leader>rg', ':Rg ', { desc = 'Rg with prompt' })


-- :F - Ripgrep alike :Rg but for files
vim.api.nvim_create_user_command('F', function(opts)
  local cmd = "rg --files | rg " .. opts.args
  local results = vim.fn.systemlist(cmd)

  if #results > 0 then
    require('telescope.pickers').new({}, {
      prompt_title = 'Rg Results (' .. #results .. ' files)',
      finder = require('telescope.finders').new_table({
        results = results,
      }),
      sorter = require('telescope.config').values.generic_sorter({}),
      previewer = require('telescope.config').values.file_previewer({}),
    }):find()
  else
    vim.notify('No matches found', vim.log.levels.WARN)
  end
end, { nargs = '+' })

-- keybind for :F
vim.keymap.set('n', '<leader>rf', ':F ', { desc = 'rg --files' })
