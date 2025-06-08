-- Use Ctrl-h
vim.api.nvim_set_keymap("n", "<C-h>", "[c", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-l>", "]c", { noremap = true })
vim.api.nvim_set_keymap("n", "<do>", ":DiffGet<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<dp>", ":DiffPut<CR>", { noremap = true })

-- Use Tab to switch search results
vim.cmd [[
  "" set wildcharm for tab completion
  set wildcharm=<c-z>
  cnoremap <expr> <Tab>   getcmdtype() =~ '[?/]' ? "<c-g>" : "<c-z>"
  cnoremap <expr> <S-Tab> getcmdtype() =~ '[?/]' ? "<c-t>" : "<S-Tab>"
]]

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
  defaults = {
    file_ignore_patterns = {
      "node_modules",
      "build",
      "dist",
      "%.git/.*",
      "lib",
      "bin",
      "obj",
      "vendor",
      "*rtifact/.*",
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
