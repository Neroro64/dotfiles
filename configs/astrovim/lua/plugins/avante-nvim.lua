return {
  "yetone/avante.nvim",
  build = ":AvanteBuild",
  cmd = {
    "AvanteAsk",
    "AvanteBuild",
    "AvanteConflictChooseAllTheirs",
    "AvanteConflictChooseBase",
    "AvanteConflictChooseBoth",
    "AvanteConflictChooseCursor",
    "AvanteConflictChooseNone",
    "AvanteConflictChooseOurs",
    "AvanteConflictChooseTheirs",
    "AvanteConflictListQf",
    "AvanteConflictNextConflict",
    "AvanteConflictPrevConflict",
    "AvanteEdit",
    "AvanteRefresh",
    "AvanteSwitchProvider",
  },
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = assert(opts.mappings)
        local prefix = "<Leader>a"

        maps.n[prefix] = { desc = "Avante functionalities" }

        maps.n[prefix .. "a"] = { function() require("avante.api").ask() end, desc = "Avante ask" }
        maps.v[prefix .. "a"] = { function() require("avante.api").ask() end, desc = "Avante ask" }

        maps.v[prefix .. "r"] = { function() require("avante.api").refresh() end, desc = "Avante refresh" }

        maps.n[prefix .. "e"] = { function() require("avante.api").edit() end, desc = "Avante edit" }
        maps.v[prefix .. "e"] = { function() require("avante.api").edit() end, desc = "Avante edit" }

        -- the following key bindings do not have an official api implementation
        maps.n.co = { ":AvanteConflictChooseOurs<CR>", desc = "Choose ours" }
        maps.v.co = { ":AvanteConflictChooseOurs<CR>", desc = "Choose ours" }

        maps.n.ct = { ":AvanteConflictChooseTheirs<CR>", desc = "Choose theirs" }
        maps.v.ct = { ":AvanteConflictChooseTheirs<CR>", desc = "Choose theirs" }

        maps.n.ca = { ":AvanteConflictChooseAllTheirs<CR>", desc = "Choose all theirs" }
        maps.v.ca = { ":AvanteConflictChooseAllTheirs<CR>", desc = "Choose all theirs" }

        maps.n.c0 = { ":AvanteConflictChooseNone<CR>", desc = "Choose none" }
        maps.v.c0 = { ":AvanteConflictChooseNone<CR>", desc = "Choose none" }

        maps.n.cb = { ":AvanteConflictChooseBoth<CR>", desc = "Choose both" }
        maps.v.cb = { ":AvanteConflictChooseBoth<CR>", desc = "Choose both" }

        maps.n.cc = { ":AvanteConflictChooseCursor<CR>", desc = "Choose cursor" }
        maps.v.cc = { ":AvanteConflictChooseCursor<CR>", desc = "Choose cursor" }

        maps.n["]x"] = { ":AvanteConflictPrevConflict<CR>", desc = "Move to previous conflict" }
        maps.v["]x"] = { ":AvanteConflictPrevConflict<CR>", desc = "Move to previous conflict" }

        maps.n["[x"] = { ":AvanteConflictNextConflict<CR>", desc = "Move to next conflict" }
        maps.x["[x"] = { ":AvanteConflictNextConflict<CR>", desc = "Move to next conflict" }
      end,
    },
  },
  opts = {
    provider = "localcopilot",
    vendors = {
      ---@type AvanteProvider
      localcopilot = {
        ["local"] = true,
        endpoint = "127.0.0.1:9000/v1",
        model = "llama3.1",
        parse_curl_args = function(opts, code_opts)
          return {
            url = opts.endpoint .. "/chat/completions",
            headers = {
              ["Accept"] = "application/json",
              ["Content-Type"] = "application/json",
            },
            body = {
              model = opts.model,
              messages = require("avante.providers").copilot.parse_message(code_opts), -- you can make your own message, but this is very advanced
              max_tokens = 32768,
              stream = true,
            },
          }
        end,
        parse_response_data = function(data_stream, event_state, opts)
          require("avante.providers").openai.parse_response(data_stream, event_state, opts)
        end,
      },
    },
  },
  specs = { -- configure optional plugins
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
