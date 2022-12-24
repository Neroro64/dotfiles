require("dapui").setup()

vim.keymap.set('n', '<leader>bui', function() require("dapui").open({}) end, {desc="open DAP UI"})
vim.keymap.set('n', '<leader>buc', function() require("dapui").close({}) end, {desc="close DAP UI"})
vim.keymap.set('n', '<leader>buu', function() require("dapui").toggle({}) end, {desc="toggle DAP UI"})

