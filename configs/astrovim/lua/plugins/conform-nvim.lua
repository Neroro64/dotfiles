return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff" },
      cs = { "csharpier" },
      c = { "clang-format" },
      cpp = { "clang-format" },
    },
  },
}
