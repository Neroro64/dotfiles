-- TypeScript/JavaScript: base support comes from `lazyvim.plugins.extras.lang.typescript`
-- (vtsls + tsserver, eslint, biome) and `...lang.json` (tsconfig/package.json LSP).
-- This file only adds monorepo/large-codebase performance tuning.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            typescript = {
              tsserver = {
                -- Raise the tsserver memory ceiling so huge monorepos don't
                -- silently degrade (tsserver caps itself at 3GB by default).
                maxTsServerMemory = 8192,
              },
            },
            javascript = {
              tsserver = {
                maxTsServerMemory = 8192,
              },
            },
          },
        },
      },
    },
  },
}
