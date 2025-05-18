-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.completion.blink-cmp" },
  { import = "astrocommunity.debugging.nvim-dap-repl-highlights" },
  { import = "astrocommunity.debugging.nvim-dap-virtual-text" },
  { import = "astrocommunity.diagnostics.tiny-inline-diagnostic-nvim" },
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.editing-support.conform-nvim" },
  { import = "astrocommunity.editing-support.multiple-cursors-nvim" },
  { import = "astrocommunity.editing-support.telescope-undo-nvim" },
  { import = "astrocommunity.editing-support.zen-mode-nvim" },
  { import = "astrocommunity.file-explorer.oil-nvim" },
  { import = "astrocommunity.git.diffview-nvim" },
  { import = "astrocommunity.motion.flash-nvim" },
  { import = "astrocommunity.motion.mini-surround" },
  { import = "astrocommunity.recipes.vscode" },
  { import = "astrocommunity.test.neotest" },
}
