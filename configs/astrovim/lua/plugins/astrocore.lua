---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = true, -- sets vim.opt.wrap
        clipboard = "", -- resets the clipboard integration
        fixendofline = false,
        laststatus = 3,
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map
        -- NeoTree keybindings
        ["<leader>E"] = { ":Neotree reveal_file=%<CR>", desc = "Locate current file in Neotree" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        ["<Leader>b"] = { desc = "Buffers" },

        -- My Custom Mappings
        ["vA"] = { "ggVG", desc = "Select all text" },
        ["<leader>p"] = { '"+p', desc = "paste from clipboard" },
        ["<leader>y"] = { '"+y', desc = "copy to clipboard" },
        ["0"] = { "^", desc = "Jump to first non-blank char" },
        ["<A-j>"] = { ":m .+1<CR>==", desc = "Move line down" },
        ["<A-k>"] = { ":m .-2<CR>==", desc = "Move line up" },
        ["<leader>%"] = { ":let @+ = expand('%:p')<cr>", desc = "copy filename" },

        -- Perforce actions
        ["<leader>pe"] = { ":!p4 edit -c default %:p <cr>", desc = "p4 edit default" },
        ["<leader>pc"] = { ":!p4 reopen %:p -c ", desc = "p4 reopen <CL>" },
        ["<leader>pr"] = { ":!p4 revert %:p <cr>", desc = "p4 revert" },

        -- Zen mode
        ["<leader>z"] = {
          function()
            require("zen-mode").setup {
              window = {
                width = 0.6,
                options = {},
              },
            }
            require("zen-mode").toggle()
            vim.wo.wrap = false
            vim.wo.number = true
            vim.wo.rnu = true
            vim.opt.colorcolumn = "0"
          end,
          desc = "Toggle Zen Mode",
        },
      },
      i = {
        ["<A-h>"] = { "<Left>" },
        ["<A-j>"] = { "<Down>" },
        ["<A-k>"] = { "<Up>" },
        ["<A-l>"] = { "<Right>" },
      },
      v = {
        ["<leader>p"] = { '"+p', desc = "paste from clipboard" },
        ["<leader>y"] = { '"+y', desc = "copy to clipboard" },
      },
      t = {
        ["<C-t>"] = { "<C-\\><C-n>", desc = "Exit terminal insert mode" },
      },
    },
  },
}
