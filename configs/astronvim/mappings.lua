-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
return {
  -- first key is the mode
  n = {
    -- second key is the lefthand side of the map
    -- mappings seen under group name "Buffer"
    ["C-q"] = { "<C-v>", desc = "Select single character vertically" },
    ["<leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
    ["<leader>bD"] = {
      function()
        require("astronvim.utils.status").heirline.buffer_picker(function(bufnr) require("astronvim.utils.buffer").close(bufnr) end)
      end,
      desc = "Pick to close",
    },
    -- tables with the `name` key will be registered with which-key if it's installed
    -- this is useful for naming menus
    ["<leader>b"] = { name = "Buffers" },
    -- quick save
    -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
    --
    -- my custom mappings
    ['vA'] = {'ggVG', desc = "Select all text"},
    ["<leader>p"] = {'"+p', desc = "paste from clipboard"},
    ["0"] = {'^', desc = "Jump to first non-blank char"},
    ['<A-j>'] = {":m .+1<CR>==", desc = "Move line down"},
    ['<A-k>'] = {":m .-2<CR>==", desc = "Move line up"},
    ["<leader>%"] = {":let @+ = expand('%:p')<cr>", desc = "copy filename"},

    -- Perforce actions
    ["<leader>pe"] = {':!p4 edit -c default %:p <cr>', desc = "p4 edit default"},
    ["<leader>pc"] = {':!p4 reopen %:p -c ', desc = "p4 reopen <CL>"},
    ["<leader>pr"] = {':!p4 revert %:p <cr>', desc = "p4 revert"},
    ["<leader>U"] = {':UndotreeToggle<CR>', desc = "Toggle UndoTree"},
  },
  i = {
    ['<A-j>'] = {"<Esc>:m .+1<CR>==gi", desc = "Move line down"},
    ['<A-k>'] = {"<Esc>:m .-2<CR>==gi", desc = "Move line up"},
  },
  t = {
    -- setting a mapping to false will disable it
    -- ["<esc>"] = false,
  },
  v = {
    ["<leader>y"] = {'"+y', desc = "copy to clipboard"},
    ["<leader>p"] = {'"+p', desc = "paste from clipboard"},
    ["0"] = {'^', desc = "Jump to first non-blank char"},
    ['<A-j>'] = {":m '>+1<CR>gv=gv", desc = "Move line down"},
    ['<A-k>'] = {":m '<-2<CR>gv=gv", desc = "Move line up"},
  }
}
