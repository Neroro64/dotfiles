-- Completion engine tweaks.
-- blink.cmp is LazyVim's default completion engine (much faster than nvim-cmp).
return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "super-tab",
      },
    },
  },

  -- Snippets come from LSP servers; the friendly-snippets packs (~40MB) are
  -- disabled to keep the install lean.
  { "rafamadriz/friendly-snippets", enabled = false },
}
