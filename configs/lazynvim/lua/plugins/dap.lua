-- Core debugging: extra keymaps + C/C++ adapters.
-- (C# → lang/csharp.lua, Mojo → lang/mojo.lua, Rust/Python DAP come from extras.)
return {
  "mfussenegger/nvim-dap",
  ft = { "c", "cpp", "mojo" },
  keys = {
    {
      "<leader>dB",
      function()
        require("dap").clear_breakpoints()
      end,
      desc = "Delete all breakpoints",
    },
    {
      "<leader>do",
      function()
        require("dap").step_over()
      end,
      desc = "Step over",
    },
    {
      "<leader>dO",
      function()
        require("dap").step_out()
      end,
      desc = "Step out",
    },
  },
  opts = function()
    local dap = require("dap")

    -- codelldb (Mason-managed; used by C/C++ configs, shared with rustaceanvim)
    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
        args = { "--port", "${port}" },
      },
    }

    dap.configurations.cpp = {
      {
        name = "Launch executable",
        type = "codelldb",
        request = "launch",
        console = "integratedTerminal",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
      {
        name = "Launch with arguments",
        type = "codelldb",
        request = "launch",
        console = "integratedTerminal",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        args = function()
          local args_string = vim.fn.input("Arguments: ")
          if args_string == "" then
            return {}
          end
          return vim.split(args_string, " ")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    }

    dap.configurations.c = dap.configurations.cpp
  end,
}
