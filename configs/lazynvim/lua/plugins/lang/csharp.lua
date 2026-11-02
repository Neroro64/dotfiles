-- C# / .NET: base support comes from `lazyvim.plugins.extras.lang.dotnet`
-- (omnisharp + omnisharp-extended for solution-wide definitions, csharpier
-- formatter, netcoredbg DAP adapter, neotest-vstest).
--
-- This file:
--   * tunes OmniSharp for large solutions (snappy startup)
--   * provides richer launch/attach DAP configurations than the extra's default
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = {
          settings = {
            FormattingOptions = {
              -- Read code style, naming convention and analyzer settings
              -- from .editorconfig.
              EnableEditorConfigSupport = true,
              -- Group and sort 'using' directives during document formatting.
              OrganizeImports = true,
            },
            MsBuild = {
              -- Only load projects for files actually opened in the editor.
              -- Large C# codebases initialize dramatically faster; the trade-off
              -- is potentially incomplete reference lists for unopened projects.
              LoadProjectsOnDemand = true,
            },
            RoslynExtensionsOptions = {
              -- Roslyn analyzers, code fixes and rulesets.
              EnableAnalyzersSupport = true,
              -- Show unimported types/methods in completions and auto-add the
              -- 'using' on commit (slows the very first completion session).
              EnableImportCompletion = true,
              -- Only run analyzers against open documents.
              AnalyzeOpenDocumentsOnly = true,
            },
            Sdk = {
              -- Include preview SDK versions when loading projects.
              IncludePrereleases = true,
            },
          },
        },
      },
    },
  },

  -- Skip fantomas (F# formatter) — pulled in by the dotnet extra but unused.
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts.registries = opts.registries or { "github:mason-org/mason-registry" }
      if not vim.tbl_contains(opts.registries, "github:Crashdummyy/mason-registry") then
        table.insert(opts.registries, "github:Crashdummyy/mason-registry")
      end
      opts.ensure_installed = vim.tbl_filter(function(p)
        return p ~= "fantomas"
      end, opts.ensure_installed or {})
    end,
  },

  -- Debugging: the dotnet extra registers the `netcoredbg` adapter; these
  -- configurations reference it (NOTE: config `type` must match the adapter
  -- name, i.e. "netcoredbg", not "coreclr").
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")

      local netcoredbg = vim.fn.exepath("netcoredbg")
      if netcoredbg == "" then
        netcoredbg = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"
      end
      dap.adapters.netcoredbg = {
        type = "executable",
        command = netcoredbg,
        args = { "--interpreter=vscode" },
      }

      dap.configurations.cs = {
        {
          type = "netcoredbg",
          name = "Launch .NET Executable",
          request = "launch",
          program = function()
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          env = {
            DOTNET_ENVIRONMENT = "Development",
            ASPNETCORE_ENVIRONMENT = "Development",
          },
          justMyCode = false,
        },
        {
          type = "netcoredbg",
          name = "Launch with Arguments",
          request = "launch",
          program = function()
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
          args = function()
            local input = vim.fn.input("Arguments: ")
            if input == "" then
              return {}
            end
            return vim.split(input, " ")
          end,
          cwd = "${workspaceFolder}",
          env = {
            DOTNET_ENVIRONMENT = "Development",
            ASPNETCORE_ENVIRONMENT = "Development",
          },
          justMyCode = false,
        },
        {
          type = "netcoredbg",
          name = "Attach to Process",
          request = "attach",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
          justMyCode = false,
        },
      }
    end,
  },
}
