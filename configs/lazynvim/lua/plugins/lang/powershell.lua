-- PowerShell: LSP via powershell-editor-services (installed through Mason).
return {
  {
    "TheLeoP/powershell.nvim",
    opts = {
      bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
    },
  },
}
