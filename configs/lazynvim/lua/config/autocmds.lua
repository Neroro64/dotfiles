-- Disable autoformat for C/C++ files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "c", "cpp" },
  callback = function()
    vim.b.autoformat = false
  end,
})

-- Mojo filetype settings live in ftplugin/mojo.lua (the idiomatic place for
-- per-filetype options).
