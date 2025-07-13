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
      -- control auto formatting on save
      format_on_save = {
        enabled = false, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          "cpp",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      "mojo",
      "zls",
    },
    -- customize language server configuration options passed to `lspconfig`
    ---@diagnostic disable: missing-fields
    config = {
      mojo = {
        cmd = {
          "mojo-lsp-server"
        },
        filetypes = { "mojo" },
        root_dir = function(fname)
          return vim.fs.dirname(vim.fs.find("pixi.toml", {path = fname, upward = true })[1])
        end,
      },
    },
    -- customize how language servers are attached
    handlers = {
      -- This will apply the on_exit logic to ALL servers that don't have a specific handler defined.
      function(server_name, opts)
        local on_attach_original = opts.on_attach -- Store the original on_attach if it exists
        local lspconfig = require('lspconfig')

        opts.on_attach = function(client, bufnr)
          -- Call the original on_attach if it was provided by AstroLSP or a server-specific config
          if on_attach_original then
            on_attach_original(client, bufnr)
          end

          -- Your custom on_exit handler
          client.on_exit = function(code, signal, client_id)
            if code ~= 0 then -- Server exited with an error
              print(string.format("LSP server %s (id: %d) exited with code %s, signal %s. Attempting restart...", client.name, client_id, tostring(code), tostring(signal)))
              -- A small delay before restarting might be good to avoid a rapid restart loop
              vim.defer_fn(function()
                -- Check if the client is still registered before attempting restart
                -- This prevents errors if the client was explicitly stopped or already restarted
                if vim.lsp.get_client_by_id(client_id) then
                    vim.cmd(string.format(":LspRestart %s", client.name))
                end
              end, 1000) -- Wait 1 second before restarting
            else
              print(string.format("LSP server %s (id: %d) exited cleanly.", client.name, client_id))
            end
          end

          -- IMPORTANT: AstroLSP already sets up common keymaps and autocmds.
          -- If you put them here, they might be duplicated or conflict.
          -- Stick to the on_exit logic in this part, and use AstroLSP's `mappings` and `autocmds` sections for keymaps/autocmds.
        end

        -- Call the standard lspconfig setup with your modified opts
        lspconfig[server_name].setup(opts)
      end,

      -- If you had a specific server that you wanted to exclude from this behavior,
      -- or give it a different on_exit logic, you could do it here:
      -- rust_analyzer = function(_, opts)
      --   -- Custom on_attach for rust_analyzer
      --   opts.on_attach = function(client, bufnr)
      --     print("Rust Analyzer attached!")
      --     -- No auto-restart for rust_analyzer in this example
      --   end
      --   require("lspconfig").rust_analyzer.setup(opts)
      -- end,
    },
    -- Configure buffer local auto commands to add when attaching a language server
    autocmds = {
      -- first key is the `augroup` to add the auto commands to (:h augroup)
      lsp_codelens_refresh = {
        -- Optional condition to create/delete auto command group
        -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
        -- condition will be resolved for each client on each execution and if it ever fails for all clients,
        -- the auto commands will be deleted for that buffer
        cond = "textDocument/codeLens",
        -- cond = function(client, bufnr) return client.name == "lua_ls" end,
        -- list of auto commands to set
        {
          -- events to trigger
          event = { "InsertLeave", "BufEnter" },
          -- the rest of the autocmd options (:h nvim_create_autocmd)
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
