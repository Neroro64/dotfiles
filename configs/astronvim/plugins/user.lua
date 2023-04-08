return {
  { "justinmk/vim-sneak", lazy = false },
  'junegunn/vim-easy-align',
  {"mbbill/undotree", lazy = false },
  { 'embark-theme/vim', as = 'embark', lazy = false },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
}
