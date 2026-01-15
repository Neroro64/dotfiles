-- Disable autoformat for lua files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "cpp", "h", "hpp" },
  callback = function()
    vim.b.autoformat = false
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "mojo",
  callback = function()
    -- Use 4 spaces for indentation in Mojo files
    vim.opt_local.tabstop = 4 -- A tab counts as 4 spaces
    vim.opt_local.shiftwidth = 4 -- Number of spaces for indentation
    vim.opt_local.expandtab = true -- Convert tabs to spaces
    vim.opt_local.softtabstop = 4 -- Number of spaces for tab key
  end,
})
