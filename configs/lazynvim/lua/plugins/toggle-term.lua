return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      open_mapping = [[<c-\>]],
      direction = "horizontal",
      size = 15,
      float_opts = {
        border = "curved",
      },
    })

    local Terminal = require("toggleterm.terminal").Terminal
    local keymap = vim.api.nvim_set_keymap
    local opts = { noremap = true, silent = true }

    -- ==========================================
    -- Fix: Custom Terminal Keymaps
    -- ==========================================
    local function custom_on_open(term)
      -- 1. Force <C-\> to close this specific window, overriding the default behavior
      vim.keymap.set("t", "<C-\\>", "<cmd>close<CR>", { buffer = term.bufnr, noremap = true, silent = true })

      -- 2. Map <Esc> to drop into Normal mode (useful for scrolling up in oh-my-pi)
      vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = term.bufnr, noremap = true, silent = true })

      -- 3. Map 'q' to close Lazygit smoothly without leaving terminal mode
      if term.cmd == "lazygit" then
        vim.keymap.set("t", "q", "<cmd>close<CR>", { buffer = term.bufnr, noremap = true, silent = true })
      end
    end

    -- ==========================================
    -- Dedicated App: oh-my-pi
    -- ==========================================
    local omp = Terminal:new({
      cmd = "omp",
      hidden = true,
      direction = "float",
      on_open = custom_on_open, -- Inject the fix here
    })
    function _omp_toggle()
      omp:toggle()
    end
    keymap("n", "<leader>ai", "<cmd>lua _omp_toggle()<CR>", opts)

    -- ==========================================
    -- Dedicated App: Lazygit
    -- ==========================================
    local lazygit = Terminal:new({
      cmd = "lazygit",
      hidden = true,
      direction = "float",
      on_open = custom_on_open, -- Inject the fix here
    })
    function _lazygit_toggle()
      lazygit:toggle()
    end
    keymap("n", "<leader>lg", "<cmd>lua _lazygit_toggle()<CR>", opts)

    -- ==========================================
    -- Numbered Standard Terminals (1, 2, 3)
    -- ==========================================
    keymap("n", "<leader>t1", "<cmd>1ToggleTerm direction=horizontal<CR>", opts)
    keymap("n", "<leader>t2", "<cmd>2ToggleTerm direction=horizontal<CR>", opts)
    keymap("n", "<leader>t3", "<cmd>3ToggleTerm direction=horizontal<CR>", opts)
  end,
}
