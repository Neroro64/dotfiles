vim.cmd [[
  "" Use Ctrl-h and Ctrl-j to go to next or previous diff, when in diff-mode
  nnoremap <expr> <C-h> &diff ? ']c' : '<C-W>h'
  nnoremap <expr> <C-j> &diff ? '[c' : '<C-W>j'
  nnoremap <expr> <do> ':diffget'
  nnoremap <expr> <dp> ':diffput'

  " Start interactive EasyAlign in visual mode (e.g. vipga)
  xmap ga <Plug>(EasyAlign)

  " Start interactive EasyAlign for a motion/text object (e.g. gaip)
  nmap ga <Plug>(EasyAlign)

  "" Use Tab to switch search results

  set wildcharm=<c-z>
  cnoremap <expr> <Tab>   getcmdtype() =~ '[?/]' ? "<c-g>" : "<c-z>"
  cnoremap <expr> <S-Tab> getcmdtype() =~ '[?/]' ? "<c-t>" : "<S-Tab>"

  set nofixendofline
  set ff=unix
  colorscheme kanagawa
]]

-- Setting up the powershell dap
if vim.fn.has "win64" == 1 or vim.fn.has "win32" == 1 then
  vim.cmd [[
    let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
	  let &shellcmdflag = '-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';'
	  let &shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
	  let &shellpipe  = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
	  set shellquote= shellxquote=
  ]]
end

-- Set the telescope to only show recent files in the CWD
require("telescope").setup {
  pickers = {
    oldfiles = {
      cwd_only = true,
    },
  },
}

require("neo-tree").setup {
  config = {
    window = {
      auto_expand_width = true, -- expand the window when file exceeds the window width. does not work with position = "float"
    },
  },
}
