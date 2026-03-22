--[[
ToggleTerm Configuration
========================
Provides persistent terminals and floating terminal windows for Neovim.

Features:
  • Floating terminals for dedicated apps (lazygit, oh-my-pi)
  • Numbered terminals (1-3) for quick access
  • Bracketed paste support for sending code to terminals
  • Smart <C-\> toggles the last-used terminal

Keybindings:
  <C-\>        Toggle last-used terminal (or terminal 1 if none used)
  <leader>lg   Toggle Lazygit (floating)
  <leader>ai   Toggle oh-my-pi (floating)
  <leader>as   Send visual selection to oh-my-pi (visual mode)
  <leader>af   Send current file path to oh-my-pi
  <leader>t1-3 Toggle numbered terminals
--]]
return {
  "akinsho/toggleterm.nvim",
  version = "*",

  config = function()
    --------------------------------------------------------------------------------
    -- Plugin Setup
    --------------------------------------------------------------------------------
    require("toggleterm").setup({
      direction = "horizontal",
      size = 20,
      float_opts = {
        border = "curved",
      },
    })

    --------------------------------------------------------------------------------
    -- Module Imports
    --------------------------------------------------------------------------------
    local Terminal = require("toggleterm.terminal").Terminal

    --------------------------------------------------------------------------------
    -- State
    --------------------------------------------------------------------------------
    --- Tracks the most recently used terminal so <C-\> can toggle it
    local last_terminal = nil

    --------------------------------------------------------------------------------
    -- Terminal Keymaps
    --------------------------------------------------------------------------------
    --- Sets buffer-local mappings for a terminal.
    --- @param term Terminal The terminal object
    --- @param escape_passthrough boolean If true, <Esc> passes through (for TUI apps)
    local function set_terminal_keymaps(term, escape_passthrough)
      local opts = { buffer = term.bufnr, noremap = true, silent = true }

      vim.keymap.set("t", "<C-\\>", "<cmd>close<CR>", vim.tbl_extend("force", opts, { desc = "Close terminal" }))
      vim.keymap.set("t", "<C-Esc>", "<C-\\><C-n>", vim.tbl_extend("force", opts, { desc = "Terminal normal mode" }))

      if not escape_passthrough then
        vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", vim.tbl_extend("force", opts, { desc = "Terminal normal mode" }))
      end

      if term.cmd == "lazygit" then
        vim.keymap.set("t", "q", "<cmd>close<CR>", vim.tbl_extend("force", opts, { desc = "Close lazygit" }))
      end
    end

    --------------------------------------------------------------------------------
    -- Terminal Factory
    --------------------------------------------------------------------------------
    --- Creates a terminal with automatic last_terminal tracking.
    --- @param opts table Terminal options (cmd, direction, hidden, etc.)
    --- @return table terminal, function toggle_fn
    local function create_terminal(opts)
      opts = opts or {}
      opts.on_open = opts.on_open or function(term)
        set_terminal_keymaps(term, true)
      end

      local terminal = Terminal:new(opts)

      local function toggle()
        last_terminal = toggle
        terminal:toggle()
      end

      return terminal, toggle
    end

    --------------------------------------------------------------------------------
    -- Keymap Helper
    --------------------------------------------------------------------------------
    --- Creates a keymap with consistent defaults.
    --- @param mode string Keymap mode
    --- @param lhs string Key sequence
    --- @param rhs function|string Right-hand side (function for callback, string for desc)
    --- @param desc_or_opts string|table Description or full opts table
    local function map(mode, lhs, rhs, desc_or_opts)
      local opts = type(desc_or_opts) == "string" and { desc = desc_or_opts } or desc_or_opts
      opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts)
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    --------------------------------------------------------------------------------
    -- Bracketed Paste Constants
    --------------------------------------------------------------------------------
    local BP_START = "\27[200~"
    local BP_END = "\27[201~"

    --------------------------------------------------------------------------------
    -- Dedicated Terminal: oh-my-pi
    --------------------------------------------------------------------------------
    local omp, omp_toggle = create_terminal({
      cmd = "omp",
      hidden = true,
      direction = "float",
    })

    --- Send visual selection to oh-my-pi with file context
    local function omp_send_selection()
      local start_pos = vim.fn.getpos("v")
      local end_pos = vim.fn.getpos(".")

      local lines = vim.fn.getregion(start_pos, end_pos)
      local text = table.concat(lines, "\n")

      if not text or #text == 0 then
        return
      end

      local rel_path = vim.fn.expand("%:.")
      local start_line = start_pos[2]
      local end_line = end_pos[2]
      local range = start_line == end_line and tostring(start_line) or string.format("%d-%d", start_line, end_line)
      local context = string.format("@%s:%s", rel_path, range)

      last_terminal = omp_toggle
      if not omp:is_open() then
        omp:open()
      end

      omp:send(context)
      omp:send(BP_START .. text .. BP_END)
    end

    --- Send current file path to oh-my-pi
    local function omp_send_file()
      local rel_path = vim.fn.expand("%:.")

      if not rel_path or #rel_path == 0 then
        return
      end

      last_terminal = omp_toggle
      if not omp:is_open() then
        omp:open()
      end

      omp:send(rel_path)
    end

    -- oh-my-pi keybindings
    map("n", "<leader>ai", omp_toggle, "[A]rtificial [I]ntelligence - Toggle oh-my-pi")
    map("v", "<leader>as", omp_send_selection, "[A]rtificial intelligence [S]end selection to oh-my-pi")
    map("n", "<leader>af", omp_send_file, "[A]rtificial intelligence send [F]ile to oh-my-pi")

    --------------------------------------------------------------------------------
    -- Dedicated Terminal: Lazygit
    --------------------------------------------------------------------------------
    local _, lazygit_toggle = create_terminal({
      cmd = "lazygit",
      hidden = true,
      direction = "float",
    })

    map("n", "<leader>lg", lazygit_toggle, "Toggle [L]azy[G]it")

    --------------------------------------------------------------------------------
    -- Numbered Terminals (1, 2, 3)
    --------------------------------------------------------------------------------
    local numbered_toggles = {}

    for i = 1, 4 do
      local _, toggle = create_terminal({ direction = "horizontal" })
      numbered_toggles[i] = toggle
      map("n", string.format("<leader>t%d", i), toggle, string.format("Toggle terminal [%d]", i))
    end

    --------------------------------------------------------------------------------
    -- Smart Terminal Toggle (<C-\>)
    --------------------------------------------------------------------------------
    map("n", "<C-\\>", function()
      if last_terminal then
        last_terminal()
      else
        -- Default to terminal 1 if none used yet
        last_terminal = numbered_toggles[1]
        last_terminal()
      end
    end, "Toggle last used terminal")
  end,
}
