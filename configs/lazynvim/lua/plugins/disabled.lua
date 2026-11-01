-- Trim or disable built-in plugins.
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- bigfile is enabled by LazyVim already; nothing to add here.
      -- toggleterm replaces snacks terminal.
      terminal = { enabled = false },
    },
  },
}
