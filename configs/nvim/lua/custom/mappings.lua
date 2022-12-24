-- Select all text
vim.keymap.set('n', 'vA', 'ggVG', {desc = "Select all text"})

-- copy selected text to + register (usually the clipboard)
vim.keymap.set("v", "<leader>y", '"+y', {noremap = true, desc = "copy to clipboard"})
-- paste the clipboard content
vim.keymap.set("v", "<leader>v", '"+p', {noremap = true,desc = "paste from clipboard"})

-- new buffer
vim.keymap.set("n", "<leader>tb", function() vim.api.nvim_command('enew') end, {desc = "new buffer"})
-- new tabs
vim.api.nvim_set_keymap('n', '<leader>tt', ':tabnew<cr>', {noremap = true, silent = true})

vim.keymap.set("n", "<leader>w", ":w<cr>", {desc = ""})

-- Switch between tabs
vim.keymap.set('n', '<leader>1', '1gt', {desc = "Tab 1"})
vim.keymap.set('n', '<leader>2', '2gt', {desc = "Tab 2"})
vim.keymap.set('n', '<leader>3', '3gt', {desc = "Tab 3"})
vim.keymap.set('n', '<leader>4', '4gt', {desc = "Tab 4"})
vim.keymap.set('n', '<leader>5', '5gt', {desc = "Tab 5"})
vim.keymap.set('n', '<leader>6', '6gt', {desc = "Tab 6"})
vim.keymap.set('n', '<leader>7', '7gt', {desc = "Tab 7"})
vim.keymap.set('n', '<leader>8', '8gt', {desc = "Tab 8"})
vim.keymap.set('n', '<leader>8', '8gt', {desc = "Tab 9"})

-- Remap VIM 0 to first non-blank character, aka. press '0' to jump to the first character of current line
vim.keymap.set('n', "0", '^', {desc = ""})
vim.keymap.set('v', "0", '^', {desc = ""})

-- Move a line of text using ALT+[jk] or Command+[jk] on mac
vim.keymap.set('n', '<A-j>', ":m .+1<CR>==", {desc = ""})
vim.keymap.set('n', '<A-k>', ":m .-2<CR>==", {desc = ""})
vim.keymap.set('i', '<A-j>', "<Esc>:m .+1<CR>==gi", {desc = ""})
vim.keymap.set('i', '<A-k>', "<Esc>:m .-2<CR>==gi", {desc = ""})
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", {desc = ""})
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", {desc = ""})

vim.keymap.set('n', "<leader>%", "let @+ = expand('%:p') echo @+", {desc = "copy filename"})

-- Perforce actions
vim.keymap.set('n', "<leader>pe", ':!p4 edit -c default %:p <cr>', {desc = "p4 edit default"})
vim.keymap.set('n', "<leader>pc", ':!p4 edit %:p -c ', {desc = "p4 edit <CL>"})
vim.keymap.set('n', "<leader>pr", ':!p4 revert %:p <cr>', {desc = "p4 revert"})

-- Undotree
vim.keymap.set('n', "<leader>U", ':UndotreeToggle<CR>', {desc = "Toggle UndoTree"})

-- DAP UI
-- vim.keymap.set('n', '<leader>bui', require("dapui").setup, {desc="init DAP UI"})
-- vim.keymap.set('n', '<leader>b', require("dapui").open({}) , {desc="open DAP UI"})
-- vim.keymap.set('n', '<leader>buc', require("dapui").close({}) , {desc="close DAP UI"})
vim.keymap.set('n', '<leader>but', require("dapui").toggle, {desc="toggle DAP UI"})

vim.cmd([[
  nnoremap <expr> <C-h> &diff ? ']c' : '<C-W>h'
  nnoremap <expr> <C-j> &diff ? '[c' : '<C-W>j'

  " /foo<tab><tab><cr> to search and jump to the ones directly, with another word, you can use <tab> to jump between matches when typing in the search bar
  set wildcharm=<c-z>
  cnoremap <expr> <Tab>   getcmdtype() =~ '[?/]' ? "<c-g>" : "<c-z>"
  cnoremap <expr> <S-Tab> getcmdtype() =~ '[?/]' ? "<c-t>" : "<S-Tab>"
]])
