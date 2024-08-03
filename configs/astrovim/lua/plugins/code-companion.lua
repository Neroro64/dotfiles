return {
    "Neroro64/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim", -- Optional
      {
        "stevearc/dressing.nvim", -- Optional: Improves the default Neovim UI
        opts = {},
      },
    },
    config = function()
      require("codecompanion").setup {
        adapters = {
          strategies = {
            chat = "openai",
            inline = "openai",
            tool = "openai",
          },
        },
      }
      -- Expand `cc` into CodeCompanion in the command line
      vim.cmd [[cab cc CodeCompanion]]
    end,
  }
