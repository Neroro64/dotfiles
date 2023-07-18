return {
  -- { "justinmk/vim-sneak", lazy = false },
  'junegunn/vim-easy-align',
  {"mbbill/undotree", lazy = false },
  { 'embark-theme/vim', as = 'embark'},
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
  {
    "Exafunction/codeium.vim",
    lazy = false,
    config = function()
      vim.keymap.set('i', '<m-i>', function () return vim.fn['codeium#Accept']() end, { expr = true })
      vim.keymap.set('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true })
      vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true })
      vim.keymap.set('i', '<c-x>', function() return vim.fn['codeium#Clear']() end, { expr = true })
    end
  },
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
