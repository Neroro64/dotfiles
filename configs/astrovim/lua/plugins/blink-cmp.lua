return {
  "saghen/blink.cmp",
  dependencies = {
    { "Kaiser-Yang/blink-cmp-avante" },
  },
  opts = {
    sources = {
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
        "copilot",
        "avante",
      },
      providers = {
        avante = {
          module = "blink-cmp-avante",
          name = "Avante",
          opts = {
            -- options for blink-cmp-avante
          },
        },
      },
    },
  },
}
