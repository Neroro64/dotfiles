return {}
-- return {
--   {
--     "zbirenbaum/copilot.lua",
--     branch = "create-pull-request/update-copilot-dist",
--     cmd = "Copilot",
--     event = "InsertEnter",
--     config = function(_, opts)
--       local new_opts = vim.tbl_extend("force", opts, {
--         server_opts_overrides = {
--           cmd = {
--             "node",
--             vim.api.nvim_get_runtime_file("copilot/dist/language-server.js", false)[1],
--             "--stdio",
--           },
--           init_options = {
--             copilotIntegrationId = "vscode-chat",
--           },
--         },
--       })
--
--       require("copilot").setup(new_opts)
--       require("copilot").setup {
--         suggestion = { enabled = false, auto_trigger = false },
--         panel = { enabled = false },
--       }
--
--       local util = require "copilot.util"
--       local orig_get_editor_configuration = util.get_editor_configuration
--
--       ---@diagnostic disable-next-line: duplicate-set-field
--       util.get_editor_configuration = function()
--         local config = orig_get_editor_configuration()
--
--         return vim.tbl_extend("force", config, {
--           github = {
--             copilot = {
--               selectedCompletionModel = "gpt-4o-copilot",
--             },
--           },
--         })
--       end
--
--       return new_opts
--     end,
--   },
--   {
--     "giuxtaposition/blink-cmp-copilot",
--   },
--   {
--     "saghen/blink.cmp",
--     dependencies = {
--       {
--         "giuxtaposition/blink-cmp-copilot",
--       },
--     },
--     opts = {
--       sources = {
--         default = { "lsp", "path", "snippets", "buffer", "copilot" },
--         providers = {
--           copilot = {
--             name = "copilot",
--             module = "blink-cmp-copilot",
--             score_offset = 100,
--             async = true,
--           },
--         },
--       },
--     },
--   },
--   -- {
--   --   "CopilotC-Nvim/CopilotChat.nvim",
--   --   dependencies = {
--   --     { "zbirenbaum/copilot.lua" },
--   --     { "nvim-lua/plenary.nvim" },
--   --   },
--   --   opts = {
--   --     model = "claude-3.7-sonnet-thought",
--   --   },
--   --   -- See Commands section for default commands if you want to lazy load on them
--   -- }
-- }
