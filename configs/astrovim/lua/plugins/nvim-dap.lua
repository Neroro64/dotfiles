return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require "dap"
    dap.adapters.mojo = {
      type = "server",
      port = "${port}",
      executable = {
        command = "mojo-lldb-dap",
        args = { "--port", "${port}" },
        -- On windows you may have to uncomment this:
        -- detached = false,
      },
    }
    dap.adapters["mojo-lldb"] = dap.adapters["mojo"]

    dap.configurations.mojo = {
      {
        name = "Launch current file",
        type = "mojo",
        request = "launch",
        program = "mojo",
        args = { "run", "--no-optimization", "--debug-level", "full", "${file}" },
        cwd = "${workspaceFolder}",
        initCommands = {
          "plugin load " .. vim.fn.expand "$MODULAR_HOME" .. "/../../lib/libMojoLLDB.so",
          -- Add any other necessary commands to initialize the plugin
        },
      },
      {
        name = "Launch executable",
        type = "mojo",
        request = "launch",
        program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
        cwd = "${workspaceFolder}",
        initCommands = {
          "plugin load " .. vim.fn.expand "$MODULAR_HOME" .. "/../../lib/libMojoLLDB.so",
          -- Add any other necessary commands to initialize the plugin
        },
      },
    }

    dap.configurations.cpp = {
      {
        name = "Launch executable",
        type = "codelldb",
        request = "launch",
        program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
      {
        name = "Launch with arguments",
        type = "codelldb",
        request = "launch",
        program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
        args = function()
          local args_string = vim.fn.input "Arguments: "
          return vim.split(args_string, " ")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    }

    dap.configurations.c = dap.configurations.cpp
  end,
}
