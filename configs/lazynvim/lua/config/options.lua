-- tree-sitter (via cc-rs) generates \\?\-prefixed absolute output paths on Windows.
-- Strawberry Perl's ld.exe rejects these paths with "Invalid argument".
-- LLVM's clang uses lld-link.exe instead, which accepts \\?\ UNC paths.
if vim.fn.has("win32") == 1 then
  vim.env.CC = "clang"
end

vim.opt.clipboard = ""

-- undotree
vim.cmd("packadd nvim.undotree")
vim.keymap.set("n", "<leader>uu", require("undotree").open, { desc = "Undotree" })

-- helpers
function sort_lines()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2] - 1
  local end_line = end_pos[2]
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)

  table.sort(lines)

  vim.api.nvim_buf_set_lines(0, start_line, end_line, false, lines)
end

function sort_and_uniq_lines()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2] - 1
  local end_line = end_pos[2]
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)

  table.sort(lines)

  local uniq_lines = {}
  local last_line = nil
  for _, line in ipairs(lines) do
    if line ~= last_line then
      table.insert(uniq_lines, line)
      last_line = line
    end
  end

  vim.api.nvim_buf_set_lines(0, start_line, end_line, false, uniq_lines)
end

vim.api.nvim_set_keymap(
  "v",
  "<Leader>ss",
  ":lua sort_lines()<CR>",
  { noremap = true, silent = true, desc = "Sort the selected lines" }
)
vim.api.nvim_set_keymap(
  "v",
  "<Leader>su",
  ":lua sort_and_uniq_lines()<CR>",
  { noremap = true, silent = true, desc = "Sort and remove duplicate lines" }
)
