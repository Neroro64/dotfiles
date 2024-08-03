local dap = require "dap"

dap.adapters.mojo = {
  type = "executable",
  command = "mojo-lldb-dap",
  args = {},
}

dap.configurations.mojo = {
  {
    name = "Launch current file",
    type = "mojo",
    request = "launch",
    program = "mojo ${file}",
    cwd = "${workspaceFolder}",
    args = {},
    env = {},
    stopOnEntry = false,
    runInTerminal = false,
  },
  {
    name = "Launch executable",
    type = "mojo",
    request = "launch",
    program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
    cwd = "${workspaceFolder}",
    args = {},
    env = {},
    stopOnEntry = false,
    runInTerminal = false,
  },
}
