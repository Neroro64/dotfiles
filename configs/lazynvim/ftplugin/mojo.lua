-- Mojo filetype settings (sourced automatically by Neovim on FileType mojo).
-- The `.🔥` extension mapping lives in lua/config/options.lua (filetype
-- detection runs before this file exists on the buffer).
vim.opt_local.tabstop = 4 -- A tab counts as 4 spaces
vim.opt_local.shiftwidth = 4 -- Number of spaces for indentation
vim.opt_local.expandtab = true -- Convert tabs to spaces
vim.opt_local.softtabstop = 4 -- Number of spaces for tab key
-- The Neovim runtime ships no commentstring for Mojo, so `gcc` (mini.comment)
-- and similar operators silently do nothing without this.
vim.bo.commentstring = "# %s"
