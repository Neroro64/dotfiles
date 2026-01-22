return {
  "folke/sidekick.nvim",
  opts = {
    -- Disable Next Edit Suggestions (NES) by default
    nes = {
      enabled = false,
    },
  },
  keys = {
    {
      "<M-.>",
      function()
        require("sidekick.cli").toggle()
      end,
      desc = "Sidekick Toggle",
      mode = { "n", "t", "i", "x" },
    },
  },
}
