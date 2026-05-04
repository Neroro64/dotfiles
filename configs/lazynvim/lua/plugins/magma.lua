return {
  "dccsillag/magma-nvim",
  build = ":UpdateRemotePlugins",
  lazy = false,
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
  config = function()
    -- MagmaEvaluateOperator must use expr = true: the command returns "g@" which
    -- is then fed back as a normal-mode command to enter operator-pending mode.
    vim.keymap.set("n", "<leader>jo", function()
      return vim.api.nvim_exec2("MagmaEvaluateOperator", { output = true }).output
    end, { expr = true, silent = true, desc = "Evaluate operator" })

    -- <C-u> clears the '<,'> range visual mode inserts before the command
    vim.keymap.set("x", "<leader>j", ":<C-u>MagmaEvaluateVisual<CR>", { silent = true, desc = "Evaluate visual" })

    vim.keymap.set("n", "<leader>jl", "<cmd>MagmaEvaluateLine<CR>", { silent = true, desc = "Evaluate line" })
    vim.keymap.set("n", "<leader>jc", "<cmd>MagmaReevaluateCell<CR>", { silent = true, desc = "Reevaluate cell" })
    vim.keymap.set("n", "<leader>jd", "<cmd>MagmaDelete<CR>", { silent = true, desc = "Delete cell" })
    vim.keymap.set("n", "<leader>js", "<cmd>MagmaShowOutput<CR>", { silent = true, desc = "Show output" })
    -- noautocmd suppresses BufEnter/WinEnter that would immediately close the float
    vim.keymap.set("n", "<leader>je", "<cmd>noautocmd MagmaEnterOutput<CR>", { silent = true, desc = "Enter output" })

    -- Kernel lifecycle
    vim.keymap.set("n", "<leader>ji", "<cmd>MagmaInit<CR>", { silent = true, desc = "Init kernel" })
    vim.keymap.set(
      "n",
      "<leader>jr",
      "<cmd>MagmaRestart!<CR>",
      { silent = true, desc = "Restart kernel (clear state)" }
    )
    vim.keymap.set("n", "<leader>jx", "<cmd>MagmaInterrupt<CR>", { silent = true, desc = "Interrupt kernel" })

    -- Persistence: save/load cell outputs alongside the source file
    vim.keymap.set("n", "<leader>jw", "<cmd>MagmaSave<CR>", { silent = true, desc = "Save outputs" })
    vim.keymap.set("n", "<leader>jL", "<cmd>MagmaLoad<CR>", { silent = true, desc = "Load outputs" })
  end,
}
