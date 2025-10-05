-- Load the plugin
return {
  -- Plugin name and details
  "ThePrimeagen/harpoon",
  lazy = false,
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  cmd = { "HarpoonList", "HarpoonAddFile", "HarpoonQuickMenu" },
  config = function()
    -- Initialize harpoon module
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

    -- Harpoon keymaps
    vim.keymap.set("n", "<leader>rw", function() toggle_telescope(harpoon:list()) end, { desc = "Open harpoon window" })
    vim.keymap.set("n", "<leader>ra", function() harpoon:list():add() end, { desc = "Add to Harpoon" })
    vim.keymap.set("n", "<leader>rr", function() harpoon:list():remove() end, { desc = "Remove from Harpoon" })

    -- Navigation
    vim.keymap.set("n", "<leader>r1", function() harpoon:list():select(1) end, { desc = "Harpoon buffer 1" })
    vim.keymap.set("n", "<leader>r2", function() harpoon:list():select(2) end, { desc = "Harpoon buffer 2" })
    vim.keymap.set("n", "<leader>r3", function() harpoon:list():select(3) end, { desc = "Harpoon buffer 3" })
    vim.keymap.set("n", "<leader>r4", function() harpoon:list():select(4) end, { desc = "Harpoon buffer 4" })

    -- Previous/Next navigation
    vim.keymap.set("n", "<leader>rp", function() harpoon:list():prev() end, { desc = "Prev Harpoon buffer" })
    vim.keymap.set("n", "<leader>rn", function() harpoon:list():next() end, { desc = "Next Harpoon buffer" })
  end,
}
