return {
  -- CSharp support
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "c_sharp" })
      end
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "coreclr" })
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "csharpier" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "omnisharp", "csharpier", "netcoredbg" })
    end,
  },
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
    config = function()
      local install_dir = vim.fn.stdpath "data" .. "/mason" .. "/packages/netcoredbg/netcoredbg"
      if vim.fn.has "win64" == 1 or vim.fn.has "win32" == 1 then install_dir = install_dir .. ".exe" end

      require("dap").adapters.netcoredbg = {
        type = "executable",
        command = install_dir,
        args = { "--interpreter=vscode" },
      }
    end,
    dependencies = {
      {
        "AstroNvim/astrolsp",
        opts = {
          config = {
            omnisharp = {
              keys = {
                {
                  "gd",
                  function() require("omnisharp_extended").telescope_lsp_definitions() end,
                  desc = "Goto Definition",
                },
              },
              settings = {
                FormattingOptions = {
                  -- Enables support for reading code style, naming convention and analyzer
                  -- settings from .editorconfig.
                  EnableEditorConfigSupport = true,
                  -- Specifies whether 'using' directives should be grouped and sorted during
                  -- document formatting.
                  OrganizeImports = true,
                },
                MsBuild = {
                  -- If true, MSBuild project system will only load projects for files that
                  -- were opened in the editor. This setting is useful for big C# codebases
                  -- and allows for faster initialization of code navigation features only
                  -- for projects that are relevant to code that is being edited. With this
                  -- setting enabled OmniSharp may load fewer projects and may thus display
                  -- incomplete reference lists for symbols.
                  LoadProjectsOnDemand = false,
                },
                RoslynExtensionsOptions = {
                  -- Enables support for roslyn analyzers, code fixes and rulesets.
                  EnableAnalyzersSupport = true,
                  -- Enables support for showing unimported types and unimported extension
                  -- methods in completion lists. When committed, the appropriate using
                  -- directive will be added at the top of the current file. This option can
                  -- have a negative impact on initial completion responsiveness,
                  -- particularly for the first few completion sessions after opening a
                  -- solution.
                  EnableImportCompletion = true,
                  -- Only run analyzers against open files when 'enableRoslynAnalyzers' is true
                  AnalyzeOpenDocumentsOnly = true,
                },
                Sdk = {
                  -- Specifies whether to include preview versions of the .NET SDK when
                  -- determining which version to use for project loading.
                  IncludePrereleases = true,
                },
              },
              handlers = {
                ["textDocument/definition"] = function(...) require("omnisharp_extended").definition_handler(...) end,
                ["textDocument/typeDefinition"] = function(...)
                  require("omnisharp_extended").type_definition_handler(...)
                end,
                ["textDocument/references"] = function(...) require("omnisharp_extended").references_handler(...) end,
                ["textDocument/implementation"] = function(...)
                  require("omnisharp_extended").implementation_handler(...)
                end,
              },
            },
          },
        },
      },
    },
  },
  { "Issafalcon/neotest-dotnet", event = "VeryLazy" },
  {
    "nvim-neotest/neotest",
    dependencies = { "Issafalcon/neotest-dotnet" },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(
        opts.adapters,
        require "neotest-dotnet" {
          dap = {
            -- Extra arguments for nvim-dap configuration
            -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
            args = { justMyCode = false, stopAtEntry = false },
            -- Enter the name of your dap adapter, the default value is netcoredbg
            adapter_name = "netcoredbg",
          },
          -- Tell neotest-dotnet to use either solution (requires .sln file) or project (requires .csproj or .fsproj file) as project root
          -- Note: If neovim is opened from the solution root, using the 'project' setting may sometimes find all nested projects, however,
          --       to locate all test projects in the solution more reliably (if a .sln file is present) then 'solution' is better.
          discovery_root = "solution",
        }
      )
    end,
  },
}
