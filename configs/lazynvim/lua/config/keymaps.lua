vim.keymap.set("n", "0", "^", { desc = "Jump to first non-blank char" })

-- Perforce ops
vim.keymap.set("n", "<leader>pe", ":!p4 edit -c default %:p <cr>", { desc = "p4 edit default" })
vim.keymap.set("n", "<leader>pc", ":!p4 reopen %:p -c ", { desc = "p4 reopen <CL>" })
vim.keymap.set("n", "<leader>pr", ":!p4 revert %:p <cr>", { desc = "p4 revert" })
