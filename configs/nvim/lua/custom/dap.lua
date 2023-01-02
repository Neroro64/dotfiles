local dap = require('dap')

dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
  name = 'lldb'
}

dap.adapters.coreclr = {
  type = 'executable',
  command = '/usr/bin/netcoredbg',
  args = {'--interpreter=vscode'}
}

local venv = os.getenv("VIRTUAL_ENV")
if venv == nil then
  venv = ""
end
dap.adapters.python = {
  type = 'executable';
  command = venv .. "/bin/python";
  args = { '-m', 'debugpy.adapter' };
}

dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = true,
    args = {},
  },

  {
    -- If you get an "Operation not permitted" error using this, try disabling YAMA:
    --  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    name = "Attach to process",
    type = 'cpp', -- Adjust this to match your adapter name (`dap.adapters.<name>`)
    request = 'attach',
    pid = require('dap.utils').pick_process,
    args = {},
  },
}

-- If you want to use this for Rust and C, add something like this:
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp
--
--
-- Map K to hover while session is active.
-- local api = vim.api
-- local keymap_restore = {}
-- dap.listeners.after['event_initialized']['me'] = function()
--   for _, buf in pairs(api.nvim_list_bufs()) do
--     local keymaps = api.nvim_buf_get_keymap(buf, 'n')
--     for _, keymap in pairs(keymaps) do
--       if keymap.lhs == "K" then
--         table.insert(keymap_restore, keymap)
--         api.nvim_buf_del_keymap(buf, 'n', 'K')
--       end
--     end
--   end
--   api.nvim_set_keymap(
--     'n', 'K', '<Cmd>lua require("dap.ui.widgets").hover()<CR>', { silent = true })
-- end
-- 
-- dap.listeners.after['event_terminated']['me'] = function()
--   for _, keymap in pairs(keymap_restore) do
--     api.nvim_buf_set_keymap(
--       keymap.buffer,
--       keymap.mode,
--       keymap.lhs,
--       keymap.rhs,
--       { silent = keymap.silent == 1 }
--     )
--   end
--   keymap_restore = {}
-- end
-- Making debuggin .Net simpler
vim.g.dotnet_build_project = function()
    local default_path = vim.fn.getcwd() .. '/'
    if vim.g['dotnet_last_proj_path'] ~= nil then
        default_path = vim.g['dotnet_last_proj_path']
    end
    local path = vim.fn.input('Path to your *proj file', default_path, 'file')
    vim.g['dotnet_last_proj_path'] = path
    local cmd = 'dotnet build -c Debug ' .. path .. ' > /dev/null'
    print('')
    print('Cmd to execute: ' .. cmd)
    local f = os.execute(cmd)
    if f == 0 then
        print('\nBuild: ✔️ ')
    else
        print('\nBuild: ❌ (code: ' .. f .. ')')
    end
end

vim.g.dotnet_get_dll_path = function()
    local request = function()
        return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
    end

    if vim.g['dotnet_last_dll_path'] == nil then
        vim.g['dotnet_last_dll_path'] = request()
    else
        if vim.fn.confirm('Do you want to change the path to dll?\n' .. vim.g['dotnet_last_dll_path'], '&yes\n&no', 2) == 1 then
            vim.g['dotnet_last_dll_path'] = request()
        end
    end

    return vim.g['dotnet_last_dll_path']
end

local config = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    program = function()
        if vim.fn.confirm('Should I recompile first?', '&yes\n&no', 2) == 1 then
            vim.g.dotnet_build_project()
        end
        return vim.g.dotnet_get_dll_path()
    end,
  },
}

dap.configurations.cs = config
dap.configurations.fsharp = config
vim.api.nvim_set_keymap('n', '<C-b>', ':lua vim.g.dotnet_build_project()<CR>', { noremap = true, silent = true })
--
-- Python 
dap.configurations.python = {
  {
    -- The first three options are required by nvim-dap
    type = 'python'; -- the type here established the link to the adapter definition: `dap.adapters.python`
    request = 'launch';
    name = "Launch file";

    -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

    program = "${file}"; -- This configuration will launch the current file if used.
    pythonPath = function()
        return venv .. '/bin/python'
    end;
  },
}
--
-- Mappings
vim.keymap.set('n', '<leader>br', function() require('dap').restart() end, {desc = "restart"})
vim.keymap.set('n', '<leader>bc', function() require('dap').continue() end, {desc = "continue"})
vim.keymap.set('n', '<leader>bs', function() require('dap').close() end, {desc = "terminate"})
vim.keymap.set('n', '<leader>bl', function() require('dap').run_last() end, {desc = "run last"})
vim.keymap.set('n', '<leader>ba', function() require('dap').run_to_cursor() end, {desc = "run to cursor"})

vim.keymap.set('n', '<leader>bp', function() require('dap').toggle_breakpoint() end, {desc = "toggle breakpoint"})
vim.keymap.set('n', '<leader>bx', function() require('dap').clear_breakpoints() end, {desc = "step into"})

vim.keymap.set('n', '<leader>bn', function() require('dap').step_over() end, {desc = "step over"})
vim.keymap.set('n', '<leader>bi', function() require('dap').step_into() end, {desc = "step into"})
vim.keymap.set('n', '<leader>bo', function() require('dap').step_out() end, {desc = "step out"})
vim.keymap.set('n', '<leader>bb', function() require('dap').step_back() end, {desc = "step back"})

vim.keymap.set('n', '<leader>bk', function() require("dap.ui.widgets").hover() end, { silent = true, desc = "hover" })
