-- Rust: base support comes from `lazyvim.plugins.extras.lang.rust`
-- (rustaceanvim: rust-analyzer, inlay hints, code actions, codelldb DAP, neotest).
-- This file only adds large-workspace tuning.
return {
  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        settings = {
          ["rust-analyzer"] = {
            -- Reference/type lenses are recomputed on every change and are one
            -- of the most expensive rust-analyzer features in big workspaces.
            lens = {
              enable = false,
            },
            -- Priming the cache up front makes the first edits much smoother,
            -- at the cost of some background CPU right after open.
            cachePriming = {
              enable = true,
            },
          },
        },
      },
    },
  },
}
