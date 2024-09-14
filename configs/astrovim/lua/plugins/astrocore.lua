-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

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
        wrap = false, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

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
        ["0"] = { "^", desc = "Jump to first non-blank char" },
        ["<A-j>"] = { ":m .+1<CR>==", desc = "Move line down" },
        ["<A-k>"] = { ":m .-2<CR>==", desc = "Move line up" },
        ["<leader>%"] = { ":let @+ = expand('%:p')<cr>", desc = "copy filename" },

        -- Perforce actions
        ["<leader>pe"] = { ":!p4 edit -c default %:p <cr>", desc = "p4 edit default" },
        ["<leader>pc"] = { ":!p4 reopen %:p -c ", desc = "p4 reopen <CL>" },
        ["<leader>pr"] = { ":!p4 revert %:p <cr>", desc = "p4 revert" },

        -- Harpoon
        ["<leader>Wa"] = { function() require("harpoon"):list():add() end, desc = "Add current buffer to Harpoon" },
        ["<leader>Wd"] = {
          function() require("harpoon"):list():remove() end,
          desc = "Remove current buffer to Harpoon",
        },
        ["<C-e>"] = {
          function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end,
          desc = "Toggle Harpoon quick menu",
        },
        ["<C-W1>"] = { function() require("harpoon"):list():select(1) end, desc = "Go to first buffer in Harpoon" },
        ["<C-W2>"] = { function() require("harpoon"):list():select(2) end, desc = "Go to second buffer in Harpoon" },
        ["<C-W3>"] = { function() require("harpoon"):list():select(3) end, desc = "Go to third buffer in Harpoon" },
        ["<C-W4>"] = { function() require("harpoon"):list():select(4) end, desc = "Go to fourth buffer in Harpoon" },
        -- Toggle previous & next buffers stored within Harpoon list
        ["<C-S-P>"] = { function() require("harpoon"):list():prev() end, desc = "Go to previous buffer in Harpoon" },
        ["<C-S-N>"] = { function() require("harpoon"):list():next() end, desc = "Go to next buffer in Harpoon" },

        -- Zen mode
        ["<leader>r"] = {
          function()
            require("zen-mode").setup {
              window = {
                width = 120,
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

        -- CodeCompanion
        ["<C-a>"] = { ":CodeCompanionActions<cr>", desc = "Show CodeCompanionActions" },
        ["<leader>m"] = { ":CodeCompanionToggle<cr>", desc = "Toogle CodeCompanionChat" },
      },
      t = {
        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
      i = {
        ["<A-j>"] = { "<Esc>:m .+1<CR>==gi", desc = "Move line down" },
        ["<A-k>"] = { "<Esc>:m .-2<CR>==gi", desc = "Move line up" },
      },
      v = {
        ["<leader>y"] = { '"+y', desc = "copy to clipboard" },
        ["<leader>p"] = { '"+p', desc = "paste from clipboard" },
        ["0"] = { "^", desc = "Jump to first non-blank char" },
        ["<A-j>"] = { ":m '>+1<CR>gv=gv", desc = "Move line down" },
        ["<A-k>"] = { ":m '<-2<CR>gv=gv", desc = "Move line up" },
        -- CodeCompanion
        ["<C-a>"] = { ":CodeCompanionActions<cr>", desc = "Show CodeCompanionActions" },
        ["<leader>m"] = { ":CodeCompanionToggle<cr>", desc = "Toogle CodeCompanionChat" },
        ["ga"] = { ":CodeCompanionAdd<cr>", desc = "Add selected text to CodeCompanionChat" },
      },
    },
  },
}
