# LazyVim Config

Personal [LazyVim](https://lazyvim.org) configuration, symlinked from
`~/.config/nvim` → `configs/lazynvim` in this dotfiles repo.

## Layout

```
init.lua                     bootstrap + colorscheme
ftplugin/                    per-filetype options (e.g. mojo.lua)
lua/config/
  lazy.lua                   lazy.nvim bootstrap + performance tuning
  options.lua                global options + small helpers
  keymaps.lua                custom keymaps
  autocmds.lua               general autocommands
lua/plugins/
  completion.lua             blink.cmp keymap
  coding.lua                 mini.surround
  colors.lua                 extra colorschemes
  dap.lua                    core DAP keymaps + C/C++ (codelldb) adapters
  disabled.lua               disable/trim built-in plugins (snacks, ...)
  editor.lua                 orgmode, magma (Jupyter kernels)
  toggleterm.lua             terminals + maki AI agent integration
  lang/
    typescript.lua           monorepo tuning (vtsls)
    python.lua               pyright/ruff tuning
    rust.lua                 rust-analyzer tuning
    clangd.lua               clangd flags
    csharp.lua               OmniSharp tuning + netcoredbg DAP
    mojo.lua                 Mojo LSP + formatter + mojo-lldb-dap
    powershell.lua           PowerShell LSP
```

Language base support comes from LazyVim extras (see `lazyvim.json`):
`lang.typescript`, `lang.python`, `lang.rust`, `lang.clangd`, `lang.dotnet`,
`lang.json` — plus `dap.core`, `test.core`, `harpoon2`, `vscode`.
The `lang/*.lua` files only add overrides on top.

## AI agent (maki)

| Key         | Action                                            |
| ----------- | ------------------------------------------------- |
| `<leader>ai`| Toggle maki floating terminal                      |
| `<leader>as`| Paste visual selection (with `path:lines` header)  |
| `<leader>af`| Paste current file path:line                       |
| `<leader>ab`| Multi-select buffers, paste their contents         |

Pasting uses bracketed-paste mode in 1 KB chunks, so multi-line code lands
in the prompt as one block instead of submitting line by line.

## Notes

- `nvim-ts-autotag`, blink.cmp, and snacks (bigfile etc.) keep editing fast;
  the system clipboard provider is disabled — use `<leader>y` / `<leader>pp`.
- After cloning to a new machine, run `nvim` twice: once to install plugins,
  once to let Mason/treesitter finish installing servers and parsers.
