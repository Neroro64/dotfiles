---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = false, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    -- customize lsp formatting options
    formatting = {
      format_on_save = { enabled = false },
      disabled = {},
      timeout_ms = 1000,
    },
    -- enable servers that you already have installed without mason
    servers = {
      "mojo",
      "zls",
    },
    -- Static configuration is placed here. This is read first.
    ---@diagnostic disable: missing-fields
    config = {
      mojo = {
        -- This is a TABLE, as expected by the plugin.
        cmd = { "mojo-lsp-server" },
        filetypes = { "mojo" },
        root_dir = function(fname)
          local root = vim.fs.find("pixi.toml", { path = fname, upward = true })
          if root and root[1] then return vim.fs.dirname(root[1]) end
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
              string.format("Mojo LSP crashed (code: %s, signal: %s). Automatically restarting...", tostring(code), tostring(signal)),
              vim.log.levels.WARN,
              { title = "LSP" }
            )

            -- Delay to prevent restart loops
            vim.defer_fn(function()
              vim.lsp.stop_client(client_id)
              vim.api.nvim_exec_autocmds("FileType", { modeline = false })
              restart_scheduled = false
            end, restart_delay_ms)
          end
        end

        require("lspconfig")[server_name].setup(opts)
      end,
    },

-- Configure buffer local auto commands
    autocmds = {
      lsp_codelens_refresh = {
        cond = "textDocument/codeLens",
        {
          event = { "InsertLeave", "BufEnter" },
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
          end,
        },
      },
    },
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
      },
    },
  },
}
