-- Colorscheme handling.
--
-- emberbox (custom, in colors/ + lua/emberbox.lua) is the only scheme.
-- Setting LazyVim's colorscheme here means tokyonight is no longer loaded and
-- applied first on every startup — the default tokyonight/catppuccin plugin
-- specs are disabled entirely.
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "emberbox",
    },
  },

  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin", enabled = false },
}
