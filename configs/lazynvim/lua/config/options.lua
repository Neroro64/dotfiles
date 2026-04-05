vim.opt.clipboard = ""

-- undotree
vim.cmd("packadd nvim.undotree")
vim.keymap.set("n", "<leader>uu", require("undotree").open, { desc = "Undotree" })
