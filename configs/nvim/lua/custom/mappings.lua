vim.keymap.set('n', 'vA', 'ggVG') -- Select all text

vim.keymap.set("v", "<Leader>y", '"+y') -- copy selected text to + register (usually the clipboard)
vim.keymap.set("v", "<Leader>v", '"+p') -- paste the clipboard content

vim.keymap.set("n", "<leader>tb", "<cmd> :enew <CR>") -- new buffer
vim.keymap.set("n", "<leader>tt", "<cmd> :tabnew <CR>") -- new tabs
vim.keymap.set("n", "<leader>w", "<cmd> :w <CR>")
vim.keymap.set("n", "<leader>q", "<cmd> :q <CR>")

-- Switch between tabs
vim.keymap.set('n', '<Leader>1', '1gt')
vim.keymap.set('n', '<Leader>2', '2gt')
vim.keymap.set('n', '<Leader>3', '3gt')
vim.keymap.set('n', '<Leader>4', '4gt')
vim.keymap.set('n', '<Leader>5', '5gt')
vim.keymap.set('n', '<Leader>6', '6gt')
vim.keymap.set('n', '<Leader>7', '7gt')
vim.keymap.set('n', '<Leader>8', '8gt')
vim.keymap.set('n', '<Leader>8', '8gt')
vim.keymap.set('n', '<Leader>q', ':q<CR>')

-- Remap VIM 0 to first non-blank character, aka. press '0' to jump to the first character of current line
vim.keymap.set('n', "0", '^')
vim.keymap.set('v', "0", '^')

-- Move a line of text using ALT+[jk] or Command+[jk] on mac
vim.keymap.set('n', '<A-j>', ":m .+1<CR>==")
vim.keymap.set('n', '<A-k>', ":m .-2<CR>==")
vim.keymap.set('i', '<A-j>', "<Esc>:m .+1<CR>==gi")
vim.keymap.set('i', '<A-k>', "<Esc>:m .-2<CR>==gi")
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv")

vim.keymap.set('n', "<leader>%", "let @+ = expand('%:p') echo @+")

-- Perforce actions
vim.keymap.set('n', "<leader>pe", ":!p4 edit -c default %:p <cr>")
vim.keymap.set('n', "<leader>pc", ":!p4 edit %:p -c ")
vim.keymap.set('n', "<leader>pr", ":!p4 revert %:p <cr>")

-- Undotree
vim.keymap.set('n', "<Leader>U", ":UndotreeToggle<CR>")

vim.cmd([[
  nnoremap <expr> <C-h> &diff ? ']c' : '<C-W>h'
  nnoremap <expr> <C-j> &diff ? '[c' : '<C-W>j'

  " /foo<tab><tab><cr> to search and jump to the ones directly, with another word, you can use <tab> to jump between matches when typing in the search bar
  set wildcharm=<c-z>
  cnoremap <expr> <Tab>   getcmdtype() =~ '[?/]' ? "<c-g>" : "<c-z>"
  cnoremap <expr> <S-Tab> getcmdtype() =~ '[?/]' ? "<c-t>" : "<S-Tab>"
]])

