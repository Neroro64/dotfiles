return {
  "neovim/nvim-lspconfig",
  opts = {
    config = {
      mojo = {
        -- This is a TABLE, as expected by the plugin.
        cmd = { "mojo-lsp-server", "-I", "src" },
        filetypes = { "mojo" },
        root_dir = function(fname)
          local root = vim.fs.find("pixi.toml", { path = fname, upward = true })
          if root and root[1] then
            return vim.fs.dirname(root[1])
          end
          -- Fallback to a common pattern if pixi.toml isn't found
          return require("lspconfig").util.root_pattern(".git")(fname)
        end,
      },
    },

    -- Dynamic setup logic is placed here. This is called *after* the config above is processed.
    handlers = {
      -- This handler is now specific to 'mojo'
      mojo = function(server_name, opts)
        -- Debounce the restart mechanism
        local restart_scheduled = false
        local restart_delay_ms = 100

        opts.on_exit = function(code, signal, client_id)
          if signal ~= 0 and not restart_scheduled then
            restart_scheduled = true
            vim.notify(
              string.format(
                "Mojo LSP crashed (code: %s, signal: %s). Automatically restarting...",
                tostring(code),
                tostring(signal)
              ),
              vim.log.levels.WARN,
              { title = "LSP" }
            )

            -- Delay to prevent restart loops
            vim.defer_fn(function()
              local client = vim.lsp.get_client_by_id(client_id)
              if client then
                client:stop()
              end
              vim.api.nvim_exec_autocmds("FileType", { modeline = false })
              restart_scheduled = false
            end, restart_delay_ms)
          end
        end

        require("lspconfig")[server_name].setup(opts)
      end,
    },
  },
}
