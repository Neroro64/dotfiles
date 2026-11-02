-- Mojo: LSP, formatter and DAP. Not covered by any LazyVim extra.
local lib_ext = "so"
if vim.fn.has("mac") == 1 then
  lib_ext = "dylib"
elseif vim.fn.has("win32") == 1 then
  lib_ext = "dll"
end

local mojo_init_commands = {
  "plugin load " .. vim.fn.expand("$MODULAR_HOME") .. "/../../lib/libMojoLLDB." .. lib_ext,
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "mojo" } },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        group = vim.api.nvim_create_augroup("mojo_treesitter", { clear = true }),
        callback = function()
          require("nvim-treesitter.parsers").mojo = {
            install_info = {
              url = "https://github.com/dmitry-salin/tree-sitter-mojo",
              revision = "429918d92978087aae3e2c4b00242b8270d9ad6f",
              queries = "nvim-queries/mojo",
            },
          }
        end,
      })
    end,
  },
  -- Mojo LSP with crash detection + rate-limited auto-restart.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        mojo = {
          cmd = { "mojo-lsp-server", "-I", "src" },
          filetypes = { "mojo" },
          -- Full document sync avoids the incremental-diff state machinery
          -- (state_by_group / buf_state) that can nil-crash inside on_lines,
          -- which Neovim treats as the callback returning true — permanently
          -- detaching the change listener with attached_buffers[buf] still set.
          flags = { allow_incremental_sync = false },
          on_exit = function(code, signal, _)
            -- Mirror Neovim's own crash condition (client.lua:1413):
            -- signal 15 = SIGTERM = intentional stop, not a crash.
            if code ~= 0 or (signal ~= 0 and signal ~= 15) then
              -- Track last restart to enforce a minimum cooldown between attempts.
              local last_restart = vim.g.mojo_lsp_last_restart or 0
              local now = vim.fn.reltimefloat(vim.fn.reltime())
              local elapsed = now - last_restart
              local min_interval = 5
              local delay = math.max(0, min_interval - elapsed)

              vim.notify(
                string.format(
                  "Mojo LSP crashed (code: %s, signal: %s). Restarting in %.1fs...",
                  tostring(code),
                  tostring(signal),
                  delay
                ),
                vim.log.levels.WARN,
                { title = "LSP" }
              )

              local delay_ms = math.max(100, math.floor(delay * 1000))

              vim.defer_fn(function()
                -- Mirror what vim.lsp.enable() does for pre-existing buffers:
                -- fire lsp_enable_callback for every loaded buffer via the
                -- nvim.lsp.enable augroup. It starts a fresh client using the
                -- fully-registered config (including this on_exit handler),
                -- and reuse_client_default skips the now-dead client.
                vim.cmd.doautoall("nvim.lsp.enable FileType")
                vim.g.mojo_lsp_last_restart = vim.fn.reltimefloat(vim.fn.reltime())
              end, delay_ms)
            end
          end,
        },
      },
    },
  },

  -- Formatting via `mojo format`.
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        mojo = { "mojo" },
      },
      formatters = {
        mojo = {
          command = "mojo",
          args = { "format", "-" },
          stdin = true,
        },
      },
    },
  },

  -- Debugging via mojo-lldb-dap.
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")

      dap.adapters.mojo = {
        type = "server",
        port = "${port}",
        executable = {
          command = "mojo-lldb-dap",
          args = { "--connection", "listen://localhost:${port}" },
          -- On windows you may have to uncomment this:
          -- detached = false,
        },
      }
      dap.adapters["mojo-lldb"] = dap.adapters["mojo"]

      dap.configurations.mojo = {
        {
          name = "Launch current file",
          type = "mojo",
          request = "launch",
          console = "integratedTerminal",
          program = "mojo",
          args = {
            "run",
            "--no-optimization",
            "--debug-level",
            "full",
            "--debug-info-language",
            "Mojo",
            "-Werror",
            "-I",
            "src",
            "${file}",
          },
          cwd = "${workspaceFolder}",
          initCommands = mojo_init_commands,
        },
        {
          name = "Launch executable",
          type = "mojo",
          request = "launch",
          console = "integratedTerminal",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          args = function()
            local input = vim.fn.input("Arguments: ")
            if input == "" then
              return {}
            end
            return vim.split(input, " ")
          end,
          initCommands = mojo_init_commands,
        },
      }
    end,
  },
}
