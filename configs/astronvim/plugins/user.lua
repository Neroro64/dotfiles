return {
  {'junegunn/vim-easy-align', lazy = false},
  {"mbbill/undotree", lazy = false },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  {"rebelot/kanagawa.nvim"},
  {"luisiacc/gruvbox-baby"},
  {
    "phaazon/hop.nvim",
    lazy = false,
    config = function()
      local hop = require('hop')
      hop.setup({ })
      local directions = require('hop.hint').HintDirection
      vim.keymap.set('', 'f', function()
        hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
      end, {remap=true})
      vim.keymap.set('', 'F', function()
        hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
      end, {remap=true})
      vim.keymap.set('', '<leader>s', function()
        hop.hint_char2({ direction = directions.AFTER_CURSOR, current_line_only = false })
      end, {remap=true})
      vim.keymap.set('', '<leader>S', function()
        hop.hint_char2({ direction = directions.BEFORE_CURSOR, current_line_only = false })
      end, {remap=true})
      vim.keymap.set('', 't', function()
        hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
      end, {remap=true})
      vim.keymap.set('', 'T', function()
        hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
      end, {remap=true})
    end
  }
}
