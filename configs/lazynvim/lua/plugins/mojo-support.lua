return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      mojo = {
        cmd = { "mojo-lsp-server", "-I", "src" },
        filetypes = { "mojo" },
        on_exit = function(code, signal, client_id)
          if signal ~= 0 then
            vim.notify(
              string.format(
                "Mojo LSP crashed (code: %s, signal: %s). Automatically restarting...",
                tostring(code),
                tostring(signal)
              ),
              vim.log.levels.WARN,
              { title = "LSP" }
            )
            vim.defer_fn(function()
              local client = vim.lsp.get_client_by_id(client_id)
              if client then
                client:stop()
              end
              vim.api.nvim_exec_autocmds("FileType", { modeline = false })
            end, 100)
          end
        end,
      },
    },
  },
}
