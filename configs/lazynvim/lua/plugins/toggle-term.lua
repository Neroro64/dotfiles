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
    -- These are global defaults applied to all terminals unless overridden
    require("toggleterm").setup({
      -- Note: <C-\> is handled manually below to toggle the last-used terminal
      direction = "horizontal", -- "horizontal" | "vertical" | "float" | "tab"
      size = 15, -- Height (horizontal) or width (vertical) in lines/columns
      float_opts = {
        border = "curved", -- "single" | "double" | "curved" | "shadow" | etc.
      },
    })

    --------------------------------------------------------------------------------
    -- Module Imports
    --------------------------------------------------------------------------------
    local Terminal = require("toggleterm.terminal").Terminal

    --------------------------------------------------------------------------------
    -- Last Terminal Tracker
    --------------------------------------------------------------------------------
    -- Tracks the most recently used terminal so <C-\> can toggle it
    -- Stores a function that toggles the appropriate terminal
    local last_terminal = nil

    --------------------------------------------------------------------------------
    -- Terminal Keymaps
    --------------------------------------------------------------------------------
    -- Called when a terminal opens; sets buffer-local mappings that only apply
    -- while that terminal is focused. This avoids polluting global mappings.
    --
    -- @param term Terminal The terminal object
    -- @param escape_passthrough boolean If true, <Esc> passes through (for TUI apps)
    local function set_terminal_keymaps(term, escape_passthrough)
      local opts = { buffer = term.bufnr, noremap = true, silent = true }

      -- Close terminal window with <C-\> instead of toggling
      -- Prevents accidental toggle when we want to close
      vim.keymap.set("t", "<C-\\>", "<cmd>close<CR>", vim.tbl_extend("force", opts, { desc = "Close terminal" }))

      -- Enter Normal mode with <C-Esc> for scrolling/copying text
      -- This works for all terminals, including TUI apps
      vim.keymap.set("t", "<C-Esc>", "<C-\\><C-n>", vim.tbl_extend("force", opts, { desc = "Terminal normal mode" }))

      -- For non-TUI terminals, <Esc> enters normal mode for easier scrolling
      -- TUI apps need <Esc> to pass through (e.g., for navigation, quitting)
      if not escape_passthrough then
        vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", vim.tbl_extend("force", opts, { desc = "Terminal normal mode" }))
      end

      -- App-specific: 'q' closes lazygit (its native binding)
      if term.cmd == "lazygit" then
        vim.keymap.set("t", "q", "<cmd>close<CR>", vim.tbl_extend("force", opts, { desc = "Close lazygit" }))
      end
    end

    --------------------------------------------------------------------------------
    -- Bracketed Paste Constants
    --------------------------------------------------------------------------------
    -- Bracketed paste mode allows terminals to distinguish between typed input
    -- and pasted content. Many TUI apps provide special handling for pastes.
    -- See: https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h2-Bracketed-Paste-Mode
    local BP_START = "\27[200~" -- ESC[200~
    local BP_END = "\27[201~" -- ESC[201~

    --------------------------------------------------------------------------------
    -- Dedicated Terminal: oh-my-pi
    --------------------------------------------------------------------------------
    -- A floating terminal for oh-my-pi interactions
    local omp = Terminal:new({
      cmd = "omp",
      hidden = true, -- Excludes from :ToggleTerm list
      direction = "float",
      on_open = function(term)
        set_terminal_keymaps(term, true) -- true = <Esc> passes through for TUI
      end,
    })

    --- Toggle the oh-my-pi terminal
    function _G.__omp_toggle()
      last_terminal = function()
        omp:toggle()
      end
      omp:toggle()
    end

    --- Send visual selection to oh-my-pi with file context
    --- Context format: @relative/path/to/file:startline[-endline]
    function _G.__omp_send_selection()
      -- Get visual selection boundaries
      local start_pos = vim.fn.getpos("v") -- Start of visual selection
      local end_pos = vim.fn.getpos(".") -- Current cursor position

      -- Extract the selected text (getregion handles linewise/charwise/blockwise)
      local lines = vim.fn.getregion(start_pos, end_pos)
      local text = table.concat(lines, "\n")

      if not text or #text == 0 then
        return
      end

      -- Build context string with relative path and line range
      local rel_path = vim.fn.expand("%:.") -- % = current file, :. = relative to cwd
      local start_line = start_pos[2]
      local end_line = end_pos[2]

      -- Single line: "10" | Multi-line: "10-25"
      local range = start_line == end_line and tostring(start_line) or string.format("%d-%d", start_line, end_line)

      local context = string.format("@%s:%s", rel_path, range)

      -- Track this terminal and ensure it's visible before sending
      last_terminal = function()
        omp:toggle()
      end
      if not omp:is_open() then
        omp:open()
      end

      -- Send context as typed input (appears on command line)
      omp:send(context)

      -- Send selection as bracketed paste (simulates clipboard paste)
      -- This allows oh-my-pi to handle it with any special paste logic
      omp:send(BP_START .. text .. BP_END)
    end

    --- Send current file path to oh-my-pi
    function _G.__omp_send_file()
      local rel_path = vim.fn.expand("%:.")

      if not rel_path or #rel_path == 0 then
        return
      end

      -- Track this terminal and ensure it's visible before sending
      last_terminal = function()
        omp:toggle()
      end
      if not omp:is_open() then
        omp:open()
      end

      omp:send(rel_path)
    end

    --------------------------------------------------------------------------------
    -- oh-my-pi Keybindings
    --------------------------------------------------------------------------------
    vim.keymap.set("n", "<leader>ai", "<cmd>lua _G.__omp_toggle()<CR>", {
      noremap = true,
      silent = true,
      desc = "[A]rtificial [I]ntelligence - Toggle oh-my-pi",
    })
    vim.keymap.set("v", "<leader>as", "<cmd>lua _G.__omp_send_selection()<CR>", {
      noremap = true,
      silent = true,
      desc = "[A]rtificial intelligence [S]end selection to oh-my-pi",
    })
    vim.keymap.set("n", "<leader>af", "<cmd>lua _G.__omp_send_file()<CR>", {
      noremap = true,
      silent = true,
      desc = "[A]rtificial intelligence send [F]ile to oh-my-pi",
    })

    --------------------------------------------------------------------------------
    -- Dedicated Terminal: Lazygit
    --------------------------------------------------------------------------------
    local lazygit = Terminal:new({
      cmd = "lazygit",
      hidden = true,
      direction = "float",
      on_open = function(term)
        set_terminal_keymaps(term, true) -- true = <Esc> passes through for TUI
      end,
    })

    --- Toggle the Lazygit terminal
    function _G.__lazygit_toggle()
      last_terminal = function()
        lazygit:toggle()
      end
      lazygit:toggle()
    end

    vim.keymap.set("n", "<leader>lg", "<cmd>lua _G.__lazygit_toggle()<CR>", {
      noremap = true,
      silent = true,
      desc = "Toggle [L]azy[G]it",
    })

    --------------------------------------------------------------------------------
    -- Numbered Terminals (1, 2, 3)
    --------------------------------------------------------------------------------
    -- Quick-access horizontal terminals for general shell work
    -- Each number corresponds to a distinct terminal instance

    --- Helper to create tracked terminal toggle for numbered terminals
    ---@param num integer Terminal number (1-3)
    ---@return function
    local function tracked_term_toggle(num)
      return function()
        last_terminal = function()
          vim.cmd(string.format("%dToggleTerm direction=horizontal", num))
        end
        vim.cmd(string.format("%dToggleTerm direction=horizontal", num))
      end
    end

    vim.keymap.set("n", "<leader>t1", tracked_term_toggle(1), {
      noremap = true,
      silent = true,
      desc = "Toggle terminal [1]",
    })
    vim.keymap.set("n", "<leader>t2", tracked_term_toggle(2), {
      noremap = true,
      silent = true,
      desc = "Toggle terminal [2]",
    })
    vim.keymap.set("n", "<leader>t3", tracked_term_toggle(3), {
      noremap = true,
      silent = true,
      desc = "Toggle terminal [3]",
    })

    --------------------------------------------------------------------------------
    -- Smart Terminal Toggle (<C-\>)
    --------------------------------------------------------------------------------
    -- Toggles the most recently used terminal, or terminal 1 if none used yet
    vim.keymap.set("n", "<C-\\>", function()
      if last_terminal then
        last_terminal()
      else
        -- No terminal used yet, default to terminal 1
        last_terminal = function()
          vim.cmd("1ToggleTerm direction=horizontal")
        end
        last_terminal()
      end
    end, {
      noremap = true,
      silent = true,
      desc = "Toggle last used terminal",
    })
  end,
}
