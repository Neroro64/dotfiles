vim.keymap.set("n", "0", "^", { desc = "Jump to first non-blank char" })

-- Perforce ops
vim.keymap.set("n", "<leader>pe", ":!p4 edit -c default %:p <cr>", { desc = "p4 edit default" })
vim.keymap.set("n", "<leader>pc", ":!p4 reopen %:p -c ", { desc = "p4 reopen <CL>" })
vim.keymap.set("n", "<leader>pr", ":!p4 revert %:p <cr>", { desc = "p4 revert" })
-- lua/config/keymaps.lua

-- Safely delete LazyVim's default Lazygit mappings
pcall(vim.keymap.del, "n", "<leader>gg")
pcall(vim.keymap.del, "n", "<leader>gG")
pcall(vim.keymap.del, "n", "<leader>gl")

-- Safely delete LazyVim's default Terminal mappings
pcall(vim.keymap.del, "n", "<leader>ft")
pcall(vim.keymap.del, "n", "<leader>fT")
pcall(vim.keymap.del, "n", "<c-/>")
pcall(vim.keymap.del, "n", "<c-_>")

-- Clipboard: explicit system clipboard yank/paste
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>pp", '"+p', { desc = "Paste from clipboard" })
