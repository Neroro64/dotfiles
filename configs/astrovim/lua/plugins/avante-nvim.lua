local prefix = "<Leader>A"
return {
  "Neroro64/avante.nvim",
  build = vim.fn.has "win32" == 1 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
    or "make",
  event = "User AstroFile", -- load on file open because Avante manages it's own bindings
  cmd = {
    "AvanteAsk",
    "AvanteChat",
    "AvanteBuild",
    "AvanteEdit",
    "AvanteRefresh",
    "AvanteSwitchProvider",
    "AvanteChat",
    "AvanteToggle",
    "AvanteClear",
  },
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        opts.mappings.n[prefix] = { desc = " Avante" }
        opts.mappings.n[prefix .. "c"] =
          { function() require("avante.api").ask { ask = false } end, desc = "Avante Chat" }
        opts.mappings.v[prefix .. "c"] =
          { function() require("avante.api").ask { ask = false } end, desc = "Avante Chat" }
      end,
    },
  },
  opts = {
    mappings = {
      ask = prefix .. "<CR>",
      edit = prefix .. "e",
      chat = prefix .. "c",
      refresh = prefix .. "r",
      focus = prefix .. "f",
      toggle = {
        default = prefix .. "t",
        debug = prefix .. "d",
        hint = prefix .. "h",
        suggestion = prefix .. "s",
        repomap = prefix .. "R",
      },
      diff = {
        next = prefix .. "n",
        prev = prefix .. "p",
      },
      files = {
        add_current = prefix .. ".",
      },
    },
    -- NOTE: Provider settings
    provider = "localcopilot",
    auto_suggestions_provider = "localcopilot",
    vendors = {
      ---@type AvanteProvider
      localcopilot = {
        __inherited_from = "openai",
        api_key_name = "",
        endpoint = "127.0.0.1:9000/v1",
        model = "LocalCopilot",
      },
    },
  },
  specs = { -- configure optional plugins
    { "AstroNvim/astroui", opts = { icons = { Avante = "" } } },
    {
      -- make sure `Avante` is added as a filetype
      "MeanderingProgrammer/render-markdown.nvim",
      optional = true,
      opts = function(_, opts)
        if not opts.file_types then opts.filetypes = { "markdown" } end
        opts.file_types = require("astrocore").list_insert_unique(opts.file_types, { "Avante" })
      end,
    },
    {
      -- make sure `Avante` is added as a filetype
      "OXY2DEV/markview.nvim",
      optional = true,
      opts = function(_, opts)
        if not opts.filetypes then opts.filetypes = { "markdown", "quarto", "rmd" } end
        opts.filetypes = require("astrocore").list_insert_unique(opts.filetypes, { "Avante" })
      end,
    },
  },
}
