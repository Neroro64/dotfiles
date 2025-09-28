return {
  -- CodeCompanion.nvim plugin definition
  {
    "olimorris/codecompanion.nvim",
    event = "VeryLazy", -- Load lazily to not slow down startup
    dependencies = {
      "nvim-lua/plenary.nvim", -- Essential utility library
      "nvim-treesitter/nvim-treesitter", -- For syntax parsing and context
      "MeanderingProgrammer/render-markdown.nvim", -- Recommended for chat buffer rendering
      "ravitemer/codecompanion-history.nvim",
    },
    build = ":TSUpdate", -- Ensure treesitter parsers are updated for better context awareness
    config = function()
      local companion = require "codecompanion"
      local map = vim.keymap.set

      -- Setup CodeCompanion.nvim
      companion.setup {
        -- General options for CodeCompanion
        opts = {
          log_level = "INFO", -- Set to 'DEBUG' or 'TRACE' for more detailed logging during troubleshooting
          -- Other global options can go here
          show_default_actions = true, -- Show the default actions in the action palette?
          show_default_prompt_library = true, -- Show the default prompt library in the action palette?
        },

        -- Adapters: Configure your LLM providers
        adapters = {
          http = {

          -- LM Studio Adapter Configuration
          -- LM Studio provides an OpenAI-compatible API, so we use the 'openai' adapter type.
          lmstudio = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              env = {
                api_key = "OPENAI_API_KEY",
                url = "http://localhost:1234",
              },
            })
          end,

          -- You can optionally add other adapters here if you use other LLM providers:
          -- openai = {
          --   api_key = os.getenv("OPENAI_API_KEY"), -- Remember to set this environment variable
          --   model = "gpt-4o",
          -- },
          -- ollama = {
          --   host = "http://localhost:11434",
          --   model = "codellama",
          -- },
          }
        },

        -- Strategies: How you interact with the AI (e.g., chat, inline suggestions)
        strategies = {
          chat = {
            adapter = "lmstudio", -- Set LM Studio as the default adapter for chat interactions
            -- Customize keymaps within the chat buffer (optional)
            keymaps = {
              -- Example: '<C-y>' = { "accept_suggestion", mode = { "n", "i" } },
            },
            tools = require("agent_tools.lsp_file_llm_tools")
          },
          inline = {
            adapter = "lmstudio", -- Set LM Studio as the default adapter for inline suggestions
            -- Keymaps for inline suggestions (often triggered by specific commands)
          },
          -- Add more strategies (e.g., 'agent', 'command') as needed
        },

        -- User Interface (UI) options for CodeCompanion's windows
        ui = {
          chat_buffer = {
            width = 0.4, -- Chat buffer width (e.g., 40% of Neovim's width)
            height = 0.8, -- Chat buffer height (e.g., 80% of Neovim's height)
            position = "right", -- Where the chat buffer appears ('right', 'left', 'top', 'bottom')

            -- Other UI specific settings
          },
          -- inline_assistant = {}, -- Options for inline suggestion display
        },
        extensions = {
          history = {
            enabled = true,
            opts = {
              -- Keymap to open history from chat buffer (default: gh)
              keymap = "gh",
              -- Keymap to save the current chat manually (when auto_save is disabled)
              save_chat_keymap = "sc",
              -- Save all chats by default (disable to save only manually using 'sc')
              auto_save = false,
              -- Number of days after which chats are automatically deleted (0 to disable)
              expiration_days = 0,
              -- Picker interface ("telescope" or "snacks" or "fzf-lua" or "default")
              picker = "telescope",
              ---Automatically generate titles for new chats
              auto_generate_title = true,
              title_generation_opts = {
                ---Adapter for generating titles (defaults to active chat's adapter)
                adapter = nil, -- e.g "copilot"
                ---Model for generating titles (defaults to active chat's model)
                model = nil, -- e.g "gpt-4o"
              },
              ---On exiting and entering neovim, loads the last chat on opening chat
              continue_last_chat = false,
              ---When chat is cleared with `gx` delete the chat from history
              delete_on_clearing_chat = false,
              ---Directory path to save the chats
              dir_to_save = vim.fn.stdpath "data" .. "/codecompanion-history",
              ---Enable detailed logging for history extension
              enable_logging = false,
            },
          },
        },
      }

      -- Keybindings for CodeCompanion.nvim
      -- These are global keymaps to interact with CodeCompanion's features.
      -- You can adjust these to your preferred leader key or other combinations.

      -- Chat Commands
      map("n", "<leader>ac", ":CodeCompanionChat Toggle<CR>", { desc = "CodeCompanion: Toggle Chat" })
      map("v", "<leader>aa", ":CodeCompanionChat Add<CR>", { desc = "CodeCompanion: Add selected file to Chat" })

      -- Action Palette (a UI to access various commands)
      map({ "n", "v" }, "<leader>ap", ":CodeCompanionActions<CR>", { desc = "CodeCompanion: Open Action Palette" })
      map({ "n", "v" }, "<leader>ab", ":CodeCompanion #{buffer} ", { desc = "CodeCompanion: Chat with current buffer " })
      map({ "n", "v" }, "<leader>ai", function()
        require("codecompanion").inline({prompt = vim.fn.input("Prompt: ")})
      end, { desc = "Code Companion Inline" })
    end,
  },

  -- Separate entry for render-markdown.nvim to ensure it's loaded correctly
  -- and applies to 'codecompanion' filetype.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" }, -- Ensure it renders markdown in codecompanion buffers
    config = function()
      vim.keymap.set({ "n", "v" }, "<leader>mr", ":RenderMarkdown toggle<CR>", { desc = "Toggle Markdown rendering" })
    end
  },

  -- Ensure treesitter is set up if you don't have a separate configuration for it
  -- This is vital for CodeCompanion's understanding of your code.
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPost",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = {
          "markdown",
          "markdown_inline", -- Critical for CodeCompanion's chat rendering
          "lua",
          "vim",
          "javascript",
          "typescript",
          "html",
          "css",
          "json",
          "yaml", -- Add your commonly used languages
        },
        highlight = {
          enable = true, -- Enable syntax highlighting
        },
        indent = {
          enable = true, -- Enable indentation
        },
      }
    end,
  },
}
