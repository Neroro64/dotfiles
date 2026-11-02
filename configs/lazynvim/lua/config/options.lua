if vim.fn.has("win32") == 1 and not vim.env.CC then
  local clang = vim.fn.exepath("clang")
  if clang == "" then
    local vswhere = (vim.env["ProgramFiles(x86)"] or "C:/Program Files (x86)")
      .. "/Microsoft Visual Studio/Installer/vswhere.exe"
    if vim.fn.executable(vswhere) == 1 then
      local paths = vim.fn.systemlist({
        vswhere,
        "-latest",
        "-products",
        "*",
        "-find",
        "VC/Tools/Llvm/x64/bin/clang.exe",
      })
      if vim.v.shell_error == 0 then
        clang = vim.trim(paths[1] or "")
      end
    end
  end
  if clang ~= "" and vim.fn.executable(clang) == 1 then
    vim.env.CC = clang
  end
end

-- Empty string = never touch the system clipboard provider. Clipboard access
-- is a classic Neovim startup/large-file stall; we map explicit copy/paste
-- keymaps instead (see keymaps.lua).
vim.opt.clipboard = ""

-- Undotree: only load the plugin when actually invoked.
vim.keymap.set("n", "<leader>uu", function()
  vim.cmd("packadd nvim.undotree")
  require("undotree").open()
end, { desc = "Undotree" })

--------------------------------------------------------------------------------
-- Sort helpers (visual mode)
--------------------------------------------------------------------------------
local function sort_lines(dedup)
  local start_line = vim.fn.getpos("v")[2]
  local end_line = vim.fn.getpos(".")[2]
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  table.sort(lines)

  if dedup then
    local uniq = {}
    local last = nil
    for _, line in ipairs(lines) do
      if line ~= last then
        uniq[#uniq + 1] = line
        last = line
      end
    end
    lines = uniq
  end

  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
end

vim.keymap.set("v", "<Leader>ss", function()
  sort_lines(false)
end, { noremap = true, silent = true, desc = "Sort the selected lines" })

vim.keymap.set("v", "<Leader>su", function()
  sort_lines(true)
end, { noremap = true, silent = true, desc = "Sort and remove duplicate lines" })
