-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

vim.cmd [[
  nnoremap <expr> <C-h> &diff ? ']c' : '<C-W>h'
  nnoremap <expr> <C-j> &diff ? '[c' : '<C-W>j'

  set wildcharm=<c-z>
  cnoremap <expr> <Tab>   getcmdtype() =~ '[?/]' ? "<c-g>" : "<c-z>"
  cnoremap <expr> <S-Tab> getcmdtype() =~ '[?/]' ? "<c-t>" : "<S-Tab>"

  " Start interactive EasyAlign in visual mode (e.g. vipga)
  " xmap ga <Plug>(EasyAlign)

  " Start interactive EasyAlign for a motion/text object (e.g. gaip)
  " nmap ga <Plug>(EasyAlign)

]]
