return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "powershell" })
      end
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "powershell-editor-services" })
    end,
  },
  {
    "Willem-J-an/nvim-dap-powershell",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
      {
        "m00qek/baleia.nvim",
        lazy = true,
        tag = "v1.4.0",
      },
    },
    config = function()
      require("dap-powershell").setup {
        include_configs = true,
        pwsh_executable = [["C:\Program Files\FrostShele-Preview\pwsh.exe"]],
      }
      local dapui = require "dapui"
      local dap = require "dap"
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open {}
        require("dap-powershell").correct_repl_colors()
      end
    end,
  },
}
