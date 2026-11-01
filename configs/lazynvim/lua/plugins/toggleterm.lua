--[[
ToggleTerm Configuration
========================
Persistent terminals and floating terminal windows for Neovim.

Features:
  • Floating terminal for maki (AI agent) and lazygit
  • Numbered terminals (1-4) for quick access
  • Bracketed paste support for sending code to terminals
  • Smart <C-\> toggles the last-used terminal
  • Paste context into the maki agent: visual selection, current file
    path, or whole buffers picked from a list

Keybindings:
  <C-\>        Toggle last-used terminal (or terminal 1 if none used)
  <leader>lg   Toggle Lazygit (floating)
  <leader>ai   Toggle maki (floating)
  <leader>as   Paste visual selection into maki (visual mode)
  <leader>af   Paste current file path[:line] into maki
  <leader>ab   Pick buffers and paste their contents into maki
  <leader>t1-4 Toggle numbered terminals
--]]
return {
  "akinsho/toggleterm.nvim",
  version = "*",

  dependencies = {
    -- buffer picker for <leader>ab
    { "folke/snacks.nvim" },
  },

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
    --- @param rhs function|string Right-hand side
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
    -- PTY Send Helpers
    --------------------------------------------------------------------------------
    --- Send raw bytes directly to a terminal's PTY.
    --- Bypasses Terminal:send() which appends an unwanted newline via with_cr().
    --- @param term Terminal
    --- @param data string
    local function raw_send(term, data)
      if term and term.job_id then
        vim.api.nvim_chan_send(term.job_id, data)
      end
    end

    --- Send data in safe chunks to prevent PTY buffer overflow.
    --- Kernel PTY buffer is typically 4096 bytes; use conservative 1024-byte chunks.
    --- @param term Terminal
    --- @param data string
    local function send_chunked(term, data)
      if not term or not term.job_id then
        return
      end
      local CHUNK = 1024
      local i = 1
      while i <= #data do
        vim.api.nvim_chan_send(term.job_id, data:sub(i, i + CHUNK - 1))
        i = i + CHUNK
        if i <= #data then
          vim.wait(5)
        end
      end
    end

    --- Wrap text in a single bracketed-paste block and submit it.
    --- Pasting as one block keeps the TUI from treating each line as Enter.
    --- @param term Terminal
    --- @param text string
    local function paste(term, text)
      raw_send(term, BP_START)
      send_chunked(term, text)
      raw_send(term, BP_END .. "\n")
    end

    --- Ensure a terminal is open and track it as the last-used terminal.
    --- @param term Terminal
    --- @param toggle function
    local function ensure_open(term, toggle)
      last_terminal = toggle
      if not term:is_open() then
        term:open()
      end
    end

    --------------------------------------------------------------------------------
    -- Dedicated Terminal: maki (AI agent)
    --------------------------------------------------------------------------------
    local maki, maki_toggle = create_terminal({
      cmd = "maki",
      hidden = true,
      direction = "float",
    })

    --- Build a fenced code block with a path header, for pasting into the agent.
    --- @param path string Relative file path (header line)
    --- @param ft string Filetype for the fence ("" for none)
    --- @param lines string[] Lines to include
    local function fenced(path, ft, lines)
      local header = (#path > 0) and (path .. "\n") or ""
      return header .. "```" .. (ft or "") .. "\n" .. table.concat(lines, "\n") .. "\n```\n"
    end

    --- Paste visual selection into maki with file context
    local function maki_send_selection()
      local start_pos = vim.fn.getpos("v")
      local end_pos = vim.fn.getpos(".")

      local start_line = math.min(start_pos[2], end_pos[2])
      local end_line = math.max(start_pos[2], end_pos[2])
      local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

      if not lines or #lines == 0 then
        return
      end

      local rel_path = vim.fn.expand("%:.")
      local range = start_line == end_line and tostring(start_line) or string.format("%d-%d", start_line, end_line)

      ensure_open(maki, maki_toggle)

      -- Path + range header followed by the code, as one bracketed paste,
      -- then submitted.
      paste(maki, fenced(rel_path .. ":" .. range, vim.bo.filetype, lines))
    end

    --- Paste the current file path (with line) into maki so the agent can
    --- navigate to it with its own file tools.
    local function maki_send_file()
      local rel_path = vim.fn.expand("%:.")

      if not rel_path or #rel_path == 0 then
        return
      end

      ensure_open(maki, maki_toggle)

      paste(maki, rel_path .. ":" .. vim.fn.line("."))
    end

    --- Pick one or more buffers (snacks multi-select) and paste their contents
    --- into maki as fenced code blocks.
    local function maki_send_buffers()
      Snacks.picker({
        source = "buffers",
        multi = true,
        confirm = function(picker)
          -- fall back to the highlighted buffer when nothing is multi-selected
          local items = picker:selected({ fallback = true })
          picker:close()

          if not items or #items == 0 then
            return
          end

          local blocks = {}
          for _, item in ipairs(items) do
            local buf = item.buf
            if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
              local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
              local rel = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.:~")
              if rel == "" then
                rel = string.format("[Buffer %d]", buf)
              end
              table.insert(blocks, fenced(rel, vim.bo[buf].filetype, lines))
            end
          end

          if #blocks == 0 then
            return
          end

          ensure_open(maki, maki_toggle)
          paste(maki, table.concat(blocks, "\n"))
        end,
      })
    end

    -- maki keybindings
    map("n", "<leader>ai", maki_toggle, "Maki: toggle AI agent")
    map("v", "<leader>as", maki_send_selection, "Maki: send selection")
    map("n", "<leader>af", maki_send_file, "Maki: send file path")
    map("n", "<leader>ab", maki_send_buffers, "Maki: send buffers")

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
    -- Numbered Terminals (1-4)
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
