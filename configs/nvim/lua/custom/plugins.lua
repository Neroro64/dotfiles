return function(use)
  use({
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup({})
    end
  })
  use({
    "ggandor/leap.nvim",
    config = function()
      require('leap').add_default_mappings()
    end
  })
  use "mbbill/undotree"
  use({
    "Vonr/align.nvim",
    config = function()
      require "custom.align"
    end
  })
  use "tpope/vim-surround"
  use "Pocco81/true-zen.nvim"
  use({
    "mfussenegger/nvim-dap",
    config = function()
      require "custom.dap"
    end
  })
  use({
    "rcarriga/nvim-dap-ui",
    config = function()
      require "custom.dapui"
    end
  })
  use "sainnhe/everforest"
  use "ellisonleao/gruvbox.nvim"
end
