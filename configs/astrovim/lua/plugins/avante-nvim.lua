-- return {}
-- Define a leader key prefix for all Avante keybindings
local prefix = "<Leader>a"
return {
  -- Avante is an AI assistant plugin for Neovim
  "Neroro64/avante.nvim",
  -- Build command depends on the OS (Windows or other)
  build = vim.fn.has "win32" == 1 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
    or "make",
  -- Define commands that will lazy-load the plugin when used
  cmd = {
    "AvanteAsk",     -- Ask AI a question
    "AvanteChat",    -- Start a chat session with AI
    "AvanteBuild",   -- Build/generate code with AI
    "AvanteEdit",    -- Edit selected text with AI
    "AvanteRefresh", -- Refresh AI response
    "AvanteSwitchProvider", -- Switch between AI providers
    "AvanteChat",    -- Duplicate entry, could be removed
    "AvanteToggle",  -- Toggle AI interface
    "AvanteClear",   -- Clear chat history
  },
  -- Required plugins for Avante to function
  dependencies = {
    "stevearc/dressing.nvim",   -- Improves UI for inputs
    "nvim-lua/plenary.nvim",    -- Common utilities
    "MunifTanjim/nui.nvim",     -- UI components
    "echasnovski/mini.pick",    -- For file selection functionality
    {
      -- Integrate with AstroNvim for keybindings
      "AstroNvim/astrocore",
      opts = function(_, opts)
        -- Add main keybinding group
        opts.mappings.n[prefix] = { desc = " Avante" }
        -- Add chat keybinding in normal mode
        opts.mappings.n[prefix .. "c"] =
          { function() require("avante.api").ask { ask = false } end, desc = "Avante Chat" }
        -- Add chat keybinding in visual mode
        opts.mappings.v[prefix .. "c"] =
          { function() require("avante.api").ask { ask = false } end, desc = "Avante Chat" }
      end,
    },
  },
  opts = {
    -- General behavior configuration
    behavior = {
      auto_suggestion = false,  -- Disable automatic suggestions
    },
    hints = { enabled = false }, -- Disable inline hints
    -- Configure keybindings for different Avante actions
    mappings = {
      ask = prefix .. "<CR>",   -- Ask AI about selected text
      edit = prefix .. "e",     -- Edit with AI
      chat = prefix .. "c",     -- Open chat
      refresh = prefix .. "r",  -- Refresh response
      focus = prefix .. "f",    -- Focus on Avante window
      toggle = {
        default = prefix .. "t",   -- Toggle main interface
        debug = prefix .. "d",     -- Toggle debug info
        hint = prefix .. "h",      -- Toggle hints
        suggestion = prefix .. "s", -- Toggle suggestions
        repomap = prefix .. "R",   -- Toggle repository map
      },
      diff = {
        next = prefix .. "n",     -- Navigate to next diff
        prev = prefix .. "p",     -- Navigate to previous diff
      },
      files = {
        add_current = prefix .. ".", -- Add current file to context
      },
    },
    -- AI provider configuration
    -- NOTE: Provider settings
    provider = "localcopilot",  -- Default AI provider
    vendors = {
      ---@type AvanteProvider
      localcopilot = {
        __inherited_from = "openai", -- Inherits configuration from OpenAI provider
        api_key_name = "",          -- No API key needed for local deployment
        endpoint = "127.0.0.1:9000/v1", -- Local endpoint
        model = "LocalCopilot",     -- Model to use
      },
      copilot_claude = {
        __inherited_from = "copilot", -- Inherits from Copilot provider
        model = "claude-3.7-sonnet-thought" -- Uses Claude 3.7 Sonnet with thought process
      },
      copilot_openai = {
        __inherited_from = "copilot", -- Inherits from Copilot provider
        model = "o3-mini"            -- Uses OpenAI o3-mini model
      }
    },
  },
  specs = { -- configure optional plugins
    -- Add Avante icon to AstroNvim UI
    { "AstroNvim/astroui", opts = { icons = { Avante = "" } } },
    {
      -- make sure `Avante` is added as a filetype for render-markdown plugin
      "MeanderingProgrammer/render-markdown.nvim",
      optional = true,
      opts = function(_, opts)
        if not opts.file_types then opts.filetypes = { "markdown" } end
        opts.file_types = require("astrocore").list_insert_unique(opts.file_types, { "Avante" })
      end,
    },
    {
      -- make sure `Avante` is added as a filetype for markview plugin
      "OXY2DEV/markview.nvim",
      optional = true,
      opts = function(_, opts)
        if not opts.filetypes then opts.filetypes = { "markdown", "quarto", "rmd" } end
        opts.filetypes = require("astrocore").list_insert_unique(opts.filetypes, { "Avante" })
      end,
    },
  },
}
