-- Mojo: tree-sitter, LSP, formatter and DAP. Not covered by any LazyVim extra.
--
-- SDK discovery: the Mojo toolchain may live in a pixi environment (project
-- `.pixi/envs/*` or `~/.pixi/envs/*`) instead of on PATH, so every integration
-- resolves binaries through `mojo_env_dir()` below.
--
-- Tree-sitter grammar: lsh/tree-sitter-mojo (forked from tree-sitter-python,
-- tracks current Mojo syntax: match/if-case patterns, capture lists, t-strings,
-- __guard, __union). Ships highlights/locals/indents/injections/textobjects
-- queries; nvim-treesitter-textobjects picks those up automatically.

-- Env directory containing the Mojo SDK (`<env>/bin/mojo-lsp-server`), or nil.
local function mojo_env_dir()
  local exe = vim.fn.exepath("mojo-lsp-server")
  if exe ~= "" then
    return vim.fs.dirname(vim.fs.dirname(exe))
  end

  local envs, seen = {}, {}
  local function push_envs(root)
    if root and vim.uv.fs_stat(root) then
      for name, kind in vim.fs.dir(root) do
        local dir = vim.fs.joinpath(root, name)
        if kind == "directory" and not seen[dir] then
          seen[dir] = true
          envs[#envs + 1] = dir
        end
      end
    end
  end

  local pixi = vim.fs.find(".pixi", { upward = true, path = vim.fn.getcwd(), type = "directory", limit = 8 })[1]
  if pixi then
    push_envs(vim.fs.joinpath(pixi, "envs"))
  end
  push_envs(vim.fs.joinpath(vim.env.HOME, ".pixi", "envs"))

  for _, dir in ipairs(envs) do
    if vim.uv.fs_stat(vim.fs.joinpath(dir, "bin", "mojo-lsp-server")) then
      return dir
    end
  end
  return nil
end

-- Path to a tool in the resolved SDK env; bare name when no env was found.
local function mojo_bin(name)
  local dir = mojo_env_dir()
  return dir and vim.fs.joinpath(dir, "bin", name) or name
end

local lsp_cmd = { mojo_bin("mojo-lsp-server") }
if vim.fn.isdirectory("src") == 1 then
  vim.list_extend(lsp_cmd, { "-I", "src" })
end

local env_dir = mojo_env_dir()

-- Mirror pixi's env activation so the tools work without an activated shell:
-- `mojo build` resolves `std` through MODULAR_HOME, and the mojo binaries link
-- against $PREFIX/lib. No-op when the shell was already activated.
if env_dir and vim.env.CONDA_PREFIX ~= env_dir then
  vim.env.CONDA_PREFIX = env_dir
  vim.env.MODULAR_HOME = vim.fs.joinpath(env_dir, "share", "max")
  local lib_path = vim.fs.joinpath(env_dir, "lib")
  local swift_lib_path = vim.fs.joinpath(lib_path, "swift")
  local lib_var = vim.fn.has("mac") == 1 and "DYLD_FALLBACK_LIBRARY_PATH" or "LD_LIBRARY_PATH"
  vim.env[lib_var] = table.concat({ lib_path, swift_lib_path, vim.env[lib_var] or "" }, ":")
end

local lsp_env = env_dir and {
  PATH = vim.fs.joinpath(env_dir, "bin") .. ":" .. (vim.env.PATH or ""),
} or nil

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
              url = "https://github.com/lsh/tree-sitter-mojo",
              revision = "25d997674f83f082a0e39e67396e8a72a5388115",
              -- nvim-treesitter expects queries at `runtime/queries/`; this
              -- grammar ships them at the repo root instead.
              queries = "queries",
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
          cmd = lsp_cmd,
          cmd_env = lsp_env,
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
          command = mojo_bin("mojo"),
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
      local sdk_dir = mojo_env_dir()
      local bin_dir = sdk_dir and vim.fs.joinpath(sdk_dir, "bin")
      local lib_dir = sdk_dir and vim.fs.joinpath(sdk_dir, "lib")

      local ext = "so"
      if vim.fn.has("mac") == 1 then
        ext = "dylib"
      elseif vim.fn.has("win32") == 1 then
        ext = "dll"
      end

      -- The real DAP binary is `_mojo-lldb-dap`; the `mojo-lldb-dap` wrapper
      -- only adds $CONDA_PREFIX-dependent pre-init commands, which we pass
      -- ourselves below. Fall back to the bare name when the SDK env is on PATH.
      local adapter_bin = bin_dir and vim.fs.joinpath(bin_dir, "_mojo-lldb-dap") or "mojo-lldb-dap"

      local plugin = lib_dir and vim.fs.joinpath(lib_dir, "libMojoLLDB." .. ext) or nil
      local visualizers = lib_dir and vim.fs.joinpath(lib_dir, "lldb-visualizers") or nil

      local adapter_env = sdk_dir
          and {
            PATH = bin_dir .. ":" .. (vim.env.PATH or ""),
            LD_LIBRARY_PATH = lib_dir,
            CONDA_PREFIX = sdk_dir,
            -- Let LLDB tooling locate the Mojo plugin/visualizers without the
            -- explicit `plugin load` command (mirrors what mojo.nvim sets).
            MODULAR_MOJO_MAX_LLDB_PLUGIN_PATH = plugin,
            MODULAR_MOJO_MAX_LLDB_VISUALIZERS_PATH = visualizers,
          }
        or nil

      dap.adapters.mojo = function(callback)
        local args = { "--connection", "listen://localhost:${port}" }
        if plugin and vim.uv.fs_stat(plugin) then
          -- Must run before DAP initialization so the language plugin
          -- registers its capabilities (break on `raise`, Mojo formatters).
          vim.list_extend(args, { "--pre-init-command", "plugin load " .. plugin })
        end
        if visualizers and vim.uv.fs_stat(vim.fs.joinpath(visualizers, "lldbDataFormatters.py")) then
          -- `?` = best-effort: these pretty-print the compiler's C++ internals
          -- (not Mojo values), so never fail the session when scripting is off.
          vim.list_extend(args, {
            "--pre-init-command",
            "?command script import " .. vim.fs.joinpath(visualizers, "lldbDataFormatters.py"),
            "--pre-init-command",
            "?command script import " .. vim.fs.joinpath(visualizers, "mlirDataFormatters.py"),
          })
        end
        callback({
          type = "server",
          port = "${port}",
          executable = {
            command = adapter_bin,
            args = args,
            -- On windows you may have to uncomment this:
            -- detached = false,
            options = { env = adapter_env },
          },
        })
      end
      dap.adapters["mojo-lldb"] = dap.adapters.mojo

      -- `mojo run` debugs the JIT'd CLI process, so source breakpoints rarely
      -- bind. Build a standalone binary first (with full Mojo debug info), then
      -- let LLDB launch it.
      local function debug_build()
        local mojo = mojo_bin("mojo")
        if vim.fn.executable(mojo) ~= 1 then
          vim.notify(
            "Mojo SDK not found: no mojo on PATH and no .pixi env with one",
            vim.log.levels.ERROR,
            { title = "DAP" }
          )
          return nil
        end
        local file = vim.fn.expand("%:p")
        local out_dir = vim.fs.joinpath(vim.fn.getcwd(), "_mojo-debug")
        vim.fn.mkdir(out_dir, "p")
        local out = vim.fs.joinpath(out_dir, vim.fn.fnamemodify(file, ":t:r") .. ".bin")
        local result = vim.fn.system({
          mojo_bin("mojo"),
          "build",
          "-O0",
          "--debug-level",
          "full",
          "--debug-info-language",
          "Mojo",
          file,
          "-o",
          out,
        })
        if vim.v.shell_error ~= 0 then
          vim.notify("mojo build failed:\n" .. result, vim.log.levels.ERROR, { title = "DAP" })
          return nil
        end
        return out
      end

      dap.configurations.mojo = {
        {
          name = "Debug current file",
          type = "mojo",
          request = "launch",
          console = "integratedTerminal",
          program = debug_build,
          cwd = "${workspaceFolder}",
          sourceMap = { { ".", "${workspaceFolder}" } },
          initCommands = { "settings set target.source-map . ${workspaceFolder}" },
        },
        {
          name = "Debug current file (with args)",
          type = "mojo",
          request = "launch",
          console = "integratedTerminal",
          program = debug_build,
          args = function()
            local input = vim.fn.input("Arguments: ")
            if input == "" then
              return {}
            end
            return vim.split(input, " ")
          end,
          cwd = "${workspaceFolder}",
          sourceMap = { { ".", "${workspaceFolder}" } },
          initCommands = { "settings set target.source-map . ${workspaceFolder}" },
        },
        {
          name = "Launch executable",
          type = "mojo",
          request = "launch",
          console = "integratedTerminal",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          args = function()
            local input = vim.fn.input("Arguments: ")
            if input == "" then
              return {}
            end
            return vim.split(input, " ")
          end,
          cwd = "${workspaceFolder}",
          sourceMap = { { ".", "${workspaceFolder}" } },
          initCommands = { "settings set target.source-map . ${workspaceFolder}" },
        },
        {
          name = "Attach to process",
          type = "mojo",
          request = "attach",
          pid = function()
            return tonumber(vim.fn.input("PID to attach: "))
          end,
          cwd = "${workspaceFolder}",
        },
      }
    end,
  },
}
