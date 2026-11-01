-- C/C++: base support comes from `lazyvim.plugins.extras.lang.clangd`.
-- This file only adds large-codebase performance tuning.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            -- Index in the background so the UI never blocks on symbol lookups.
            "--background-index",
            "--background-index-priority=normal",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            -- Keep PCH in memory: faster re-analysis, at the cost of RAM.
            "--pch-storage=memory",
          },
        },
      },
    },
  },
}
