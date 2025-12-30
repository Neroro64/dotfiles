-- Disable autoformat for lua files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "cpp", "h", "hpp" },
  callback = function()
    vim.b.autoformat = false
  end,
})
