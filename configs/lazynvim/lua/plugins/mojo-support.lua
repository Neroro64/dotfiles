return {
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
}
