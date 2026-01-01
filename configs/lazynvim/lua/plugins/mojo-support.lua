return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        mojo = {
          cmd = { "mojo-lsp-server", "-I", "src" },
          filetypes = { "mojo" },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        mojo = { "mojo" },
      },
      formatters = {
        mojo = {
          command = "mojo",
          args = { "format", "-" },
          stdin = true,
        },
      },
    },
  },
}
