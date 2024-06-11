-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {
  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },
  { "czheo/mojo.vim", lazy = false },
  {
    "ThePrimeagen/harpoon",
    lazy = false,
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    config = function()
      local harpoon = require "harpoon"

      -- REQUIRED
      harpoon:setup()
      -- REQUIRED

      -- basic telescope configuration
      local conf = require("telescope.config").values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        require("telescope.pickers")
          .new({}, {
            prompt_title = "Harpoon",
            finder = require("telescope.finders").new_table {
              results = file_paths,
            },
            previewer = conf.file_previewer {},
            sorter = conf.generic_sorter {},
          })
          :find()
      end

      vim.keymap.set("n", "<C-e>", function() toggle_telescope(harpoon:list()) end, { desc = "Open harpoon window" })
    end,
  },
  {
    "AlexvZyl/nordic.nvim",
    lazy = false,
    priority = 1000,
    config = function() require("nordic").load() end,
  },
  { "folke/zen-mode.nvim" },
  {
    "Neroro64/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim", -- Optional
      {
        "stevearc/dressing.nvim", -- Optional: Improves the default Neovim UI
        opts = {},
      },
    },
    config = function()
      require("codecompanion").setup {
        adapters = {
          strategies = {
            chat = "openai",
            inline = "openai",
            tool = "openai",
          },
        },
      }
      -- Expand `cc` into CodeCompanion in the command line
      vim.cmd [[cab cc CodeCompanion]]
    end,
  },
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    init = function()
      vim.opt.laststatus = 3
      vim.opt.splitkeep = "screen"
    end,
    opts = {
      right = {
        { ft = "codecompanion", title = "Code Companion Chat", size = { width = 0.45 } },
      },
    },
  },
  {
    "Issafalcon/neotest-dotnet",
    event = "VeryLazy",
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-dotnet")({
            dap = {
            -- Extra arguments for nvim-dap configuration
            -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
              args = {justMyCode = false },
            -- Enter the name of your dap adapter, the default value is netcoredbg
              adapter_name = "netcoredbg"
            },
            -- Tell neotest-dotnet to use either solution (requires .sln file) or project (requires .csproj or .fsproj file) as project root
            -- Note: If neovim is opened from the solution root, using the 'project' setting may sometimes find all nested projects, however,
            --       to locate all test projects in the solution more reliably (if a .sln file is present) then 'solution' is better.
            discovery_root = "solution"
          })
        }
      })

      local install_dir = vim.fn.stdpath("data") .. "/mason" .. '/packages/netcoredbg/netcoredbg'
      if vim.fn.has("win64") == 1 or vim.fn.has("win32") == 1 then
        install_dir = install_dir .. ".exe"
      end

      require("dap").adapters.netcoredbg = {
        type = 'executable',
        command = install_dir,
        args = {'--interpreter=vscode'}
      }
    end
  },
  {
    "Willem-J-an/nvim-dap-powershell",
    event = "VeryLazy",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "mfussenegger/nvim-dap",
        "rcarriga/nvim-dap-ui",
        {
            "m00qek/baleia.nvim",
            lazy = true,
            tag = "v1.4.0",
        },
    },
    config = function()
      require("dap-powershell").setup()
      local dapui = require("dapui")
      local dap = require("dap")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open({})
          require('dap-powershell').correct_repl_colors()
      end
    end,
  }
}
