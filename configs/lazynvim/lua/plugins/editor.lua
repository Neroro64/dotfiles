-- Editor tooling: org-mode, notebook-style evaluation (magma).

-- Org-mode, configured for a LogSeq-shaped workflow:
--   * journal.org  - one datetree page per day (like LogSeq's daily journal)
--   * notes.org    - permanent facts/learnings, tagged, looked up via agenda tag search
--   * inbox.org    - quick-capture landing zone for anything you haven't filed yet
--
-- Everything under ~/org is picked up by org_agenda_files, so <leader>oa (agenda),
-- and its "m" (match tags) / "t" (todo list) / "s" (search) sub-views search across
-- all three files at once - that's your LogSeq-style "lookup by tag" and "all todos".
return {
  -- Jupyter-kernel code evaluation (Python, and any kernel via Magma).
  -- Lazy-loaded: the Python remote-plugin host only starts on first use,
  -- keeping startup snappy.
  {
    "dccsillag/magma-nvim",
    build = ":UpdateRemotePlugins",
    cmd = {
      "MagmaInit",
      "MagmaDeinit",
      "MagmaEvaluateArgument",
      "MagmaEvaluateLine",
      "MagmaEvaluateVisual",
      "MagmaEvaluateOperator",
      "MagmaReevaluateCell",
      "MagmaDelete",
      "MagmaShowOutput",
      "MagmaEnterOutput",
      "MagmaInterrupt",
      "MagmaRestart",
      "MagmaSave",
      "MagmaLoad",
    },
    keys = {
      -- MagmaEvaluateOperator must use expr = true: the command returns "g@" which
      -- is then fed back as a normal-mode command to enter operator-pending mode.
      {
        "<leader>jo",
        function()
          return vim.api.nvim_exec2("MagmaEvaluateOperator", { output = true }).output
        end,
        expr = true,
        silent = true,
        desc = "Magma: evaluate operator",
      },
      -- <C-u> clears the '<,'> range visual mode inserts before the command
      { "<leader>j", ":<C-u>MagmaEvaluateVisual<CR>", mode = "x", silent = true, desc = "Magma: evaluate visual" },
      { "<leader>jl", "<cmd>MagmaEvaluateLine<CR>", silent = true, desc = "Magma: evaluate line" },
      { "<leader>jc", "<cmd>MagmaReevaluateCell<CR>", silent = true, desc = "Magma: reevaluate cell" },
      { "<leader>jd", "<cmd>MagmaDelete<CR>", silent = true, desc = "Magma: delete cell" },
      { "<leader>js", "<cmd>MagmaShowOutput<CR>", silent = true, desc = "Magma: show output" },
      -- noautocmd suppresses BufEnter/WinEnter that would immediately close the float
      { "<leader>je", "<cmd>noautocmd MagmaEnterOutput<CR>", silent = true, desc = "Magma: enter output" },
      { "<leader>ji", "<cmd>MagmaInit<CR>", silent = true, desc = "Magma: init kernel" },
      { "<leader>jr", "<cmd>MagmaRestart!<CR>", silent = true, desc = "Magma: restart kernel (clear state)" },
      { "<leader>jx", "<cmd>MagmaInterrupt<CR>", silent = true, desc = "Magma: interrupt kernel" },
      { "<leader>jw", "<cmd>MagmaSave<CR>", silent = true, desc = "Magma: save outputs" },
      { "<leader>jL", "<cmd>MagmaLoad<CR>", silent = true, desc = "Magma: load outputs" },
    },
    init = function()
      -- Point Neovim at the dedicated venv that has pynvim + jupyter_client.
      -- Must be set before any plugin tries to use the Python provider.
      -- Prefer a project-local venv (.venv or venv) found in cwd; fall back to
      -- the shared neovim venv.
      local function find_python()
        local cwd = vim.fn.getcwd()
        for _, rel in ipairs({ "/.venv/bin/python", "/venv/bin/python", "/.env/bin/python", "/env/bin/python" }) do
          local p = cwd .. rel
          if vim.fn.executable(p) == 1 then
            return p
          end
        end
        return vim.fn.expand("~/.venvs/neovim/bin/python")
      end
      vim.g.python3_host_prog = find_python()
      -- Must be set before plugin loads; false = only show output after explicit request
      vim.g.magma_automatically_open_output = false
      -- "none" | "ueberzug" | "kitty" — set to "kitty" if terminal supports it
      vim.g.magma_image_provider = "none"
      vim.g.magma_wrap_output = true
      vim.g.magma_output_window_borders = true
    end,
  },
}
