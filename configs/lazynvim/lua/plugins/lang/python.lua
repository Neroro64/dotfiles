-- Python: base support comes from `lazyvim.plugins.extras.lang.python`
-- (pyright + ruff LSP, ruff formatter, debugpy DAP, neotest).
-- This file only adds large-codebase performance tuning.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            pyright = {
              -- ruff owns import organization; avoids duplicate/slow organizeImports.
              disableOrganizeImports = true,
            },
            python = {
              analysis = {
                -- Only diagnose open files instead of the whole workspace.
                -- Major responsiveness win in large repos; project-wide issues
                -- still surface via ruff / test runs.
                diagnosticMode = "openFilesOnly",
                -- Don't pull in every unrelated library's types.
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
      },
    },
  },
}
