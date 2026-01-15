return {
  "mfussenegger/nvim-dap",
  lazy = true,
  config = function()
    local dap = require("dap")
    dap.adapters.mojo = {
      type = "server",
      port = "${port}",
      executable = {
        command = "mojo-lldb-dap",
        args = { "--connection", "listen://localhost:${port}" },
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
        console = "integratedTerminal",
        program = "mojo",
        args = {
          "run",
          "--no-optimization",
          "--debug-level",
          "full",
          "--debug-info-language",
          "Mojo",
          "-Werror",
          "-I",
          "src",
          "${file}",
        },
        cwd = "${workspaceFolder}",
        initCommands = {
          "plugin load " .. vim.fn.expand("$MODULAR_HOME") .. "/../../lib/libMojoLLDB.so",
          "command script import "
            .. vim.fn.expand("$MODULAR_HOME")
            .. "/../../lib/lldb-visualizers/lldbDataFormatters.py ",
          -- Add any other necessary commands to initialize the plugin
        },
      },
      {
        name = "Launch executable",
        type = "mojo",
        request = "launch",
        console = "integratedTerminal",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        args = function()
          local input = vim.fn.input("Arguments: ")
          if input == "" then
            return {}
          else
            return vim.split(input, " ")
          end
        end,
        initCommands = {
          "plugin load " .. vim.fn.expand("$MODULAR_HOME") .. "/../../lib/libMojoLLDB.so",
          -- Add any other necessary commands to initialize the plugin
        },
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
          return vim.split(args_string, " ")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    }

    dap.configurations.c = dap.configurations.cpp

    -- C#
    local install_dir = vim.fn.stdpath("data") .. "/mason" .. "/packages/netcoredbg/netcoredbg"
    if vim.fn.has("win64") == 1 or vim.fn.has("win32") == 1 then
      install_dir = install_dir .. ".exe"
    end

    dap.adapters.netcoredbg = {
      type = "executable",
      command = install_dir,
      args = { "--interpreter=vscode" },
    }

    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "Launch .NET Executable",
        request = "launch",
        program = function()
          return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
        end,
        cwd = "${workspaceFolder}",
        env = {
          DOTNET_ENVIRONMENT = "Development",
          ASPNETCORE_ENVIRONMENT = "Development",
        },
        justMyCode = false,
      },
      {
        type = "coreclr",
        name = "Launch with Arguments",
        request = "launch",
        program = function()
          return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
        end,
        args = function()
          return vim.split(vim.fn.input("Arguments: "), " ")
        end,
        cwd = "${workspaceFolder}",
        env = {
          DOTNET_ENVIRONMENT = "Development",
          ASPNETCORE_ENVIRONMENT = "Development",
        },
        justMyCode = false,
      },
      {
        type = "coreclr",
        name = "Attach to Process",
        request = "attach",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
        justMyCode = false,
      },
    }
  end,
}
