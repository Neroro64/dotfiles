-- Use Ctrl-h and Ctrl-j to go to next or previous diff, when in diff-mode
vim.api.nvim_set_keymap("n", "<C-h>", "<cmd>diffnext<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-j>", "<cmd>diffprev<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<do>", ":DiffGet<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<dp>", ":DiffPut<CR>", { noremap = true })

-- EasyAlign
vim.api.nvim_set_keymap("x", "gA", "<Plug>(EasyAlign)", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "ga", "<Plug>(EasyAlign)", { noremap = true, silent = true })

-- Use Tab to switch search results
vim.cmd [[
  "" set wildcharm for tab completion
  set wildcharm=<c-z>
  cnoremap <expr> <Tab>   getcmdtype() =~ '[?/]' ? "<c-g>" : "<c-z>"
  cnoremap <expr> <S-Tab> getcmdtype() =~ '[?/]' ? "<c-t>" : "<S-Tab>"
]]

-- Settings
vim.opt.fixendofline = false
vim.opt.ff = "unix"

-- Color Scheme
vim.cmd.colorscheme "calvera"

-- PowerShell DAP Setup (for Windows)
if vim.fn.has "win64" == 1 or vim.fn.has "win32" == 1 then
  vim.cmd [[
    let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
    let &shellcmdflag = '-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';'
    let &shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
    let &shellpipe  = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
    set shellquote= shellxquote=
  ]]
end

-- Telescope Configuration
require("telescope").setup {
  pickers = {
    oldfiles = {
      cwd_only = true,
    },
  },
}

-- NeoTree Setup
require("neo-tree").setup {
  config = {
    window = {
      auto_expand_width = true, -- expand the window when file exceeds the window width. does not work with position = "float"
    },
  },
}

-- Avante Library Load
require("avante_lib").load()
