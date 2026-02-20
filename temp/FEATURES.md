# rvim — Built-in Features

> Every feature listed here is built natively into rvim. No plugins to
> install, no configuration ritual, no dependency management. Open rvim
> and everything works.

---

## 1. Feature Map: Neovim Plugin → rvim Built-in

| Category | Neovim Plugin(s) | rvim Equivalent | Crate |
|----------|-----------------|-----------------|-------|
| **Syntax Highlighting** | nvim-treesitter | Native tree-sitter | rvim-syntax |
| **LSP** | nvim-lspconfig, mason.nvim | Pre-configured LSP client | rvim-lsp |
| **Completion** | nvim-cmp, cmp-nvim-lsp, cmp-buffer, cmp-path | Unified completion engine | rvim-term |
| **Snippet** | LuaSnip, friendly-snippets | LSP snippet support | rvim-lsp |
| **Fuzzy Finder** | telescope.nvim, fzf-lua | Built-in picker | rvim-picker |
| **File Explorer** | neo-tree.nvim, nvim-tree, oil.nvim | Built-in explorer | rvim-term |
| **Git Signs** | gitsigns.nvim | Gutter diff signs | rvim-git |
| **Git UI** | fugitive.vim, lazygit.nvim, diffview.nvim | Git status/blame/log | rvim-git |
| **Debugging** | nvim-dap, nvim-dap-ui | Native DAP client + UI | rvim-dap |
| **Statusline** | lualine.nvim, galaxyline | Built-in statusline | rvim-term |
| **Bufferline** | bufferline.nvim | Built-in tabline | rvim-term |
| **Which-key** | which-key.nvim | Key hint popup | rvim-term |
| **Surround** | nvim-surround, mini.surround | Native `ys`/`cs`/`ds` | rvim-core |
| **Comment** | Comment.nvim, mini.comment | Native `gc` operator | rvim-core |
| **Auto-pairs** | nvim-autopairs, mini.pairs | Insert-mode auto-close | rvim-term |
| **Indent Guides** | indent-blankline.nvim | Tree-sitter indent lines | rvim-term |
| **Diagnostics Panel** | trouble.nvim | Built-in diagnostics list | rvim-term |
| **Terminal** | toggleterm.nvim | Built-in terminal splits | rvim-term |
| **Color Highlight** | nvim-colorizer | Inline color preview | rvim-term |
| **Jump/Flash** | flash.nvim, leap.nvim | Label-jump motions | rvim-core |
| **Treesitter Text Objs** | nvim-treesitter-textobjects | Native TS text objects | rvim-syntax |
| **Autopairs** | nvim-ts-autotag | TS-aware auto-close tags | rvim-syntax |
| **Formatting** | conform.nvim | LSP + external formatters | rvim-lsp |
| **Linting** | nvim-lint | LSP diagnostics | rvim-lsp |
| **Multi-cursor** | vim-visual-multi | Native multi-cursor | rvim-core |
| **Marks** | marks.nvim | Built-in mark display | rvim-view |
| **Scrollbar** | nvim-scrollbar | Built-in scrollbar | rvim-tui |
| **Notifications** | nvim-notify | Status messages | rvim-term |

---

## 2. Feature Details

### 2.1 Syntax Highlighting (Tree-sitter)

**Replaces:** `nvim-treesitter`

Tree-sitter provides *incremental* parsing — the syntax tree updates in <1ms
after each edit, enabling reliable highlighting even in complex files.

**Capabilities:**
- Accurate syntax highlighting via `highlights.scm` queries
- Language injection (e.g., SQL in Python strings, JS in HTML)
- Rainbow delimiters (matched bracket colorization)
- Current scope highlighting (subtle background on current function)
- Sticky scroll (show current function signature at top of viewport)

**Shipped languages (initial):** Rust, Python, JavaScript, TypeScript, Go, C,
C++, Java, Lua, Bash, JSON, TOML, YAML, HTML, CSS, Markdown, SQL, Ruby,
Zig, Haskell, Elixir, Nix, Dockerfile, plus any grammar in the tree-sitter
ecosystem (100+ available).

---

### 2.2 Language Server Protocol (LSP)

**Replaces:** `nvim-lspconfig`, `mason.nvim`

Pre-configured language server definitions ship in `languages.toml`. rvim
detects the file type, checks if the configured server is on `$PATH`, and
starts it automatically.

**Capabilities:**

| Feature | Key / Trigger | Description |
|---------|---------------|-------------|
| Completion | Auto / `Ctrl-Space` | Context-aware completions with documentation |
| Hover | `K` | Type info and documentation popup |
| Go to Definition | `gd` | Jump to symbol definition |
| Go to Declaration | `gD` | Jump to symbol declaration |
| Go to Implementation | `gi` | Jump to interface implementation |
| Go to Type Definition | `gy` | Jump to type definition |
| References | `gr` | List all references to symbol |
| Rename | `<space>rn` | Rename symbol across project |
| Code Actions | `<space>ca` | Quick fixes, refactors |
| Diagnostics | Inline + `]d`/`[d` | Error/warning squiggles, navigation |
| Signature Help | Auto (in parens) | Function parameter hints |
| Inlay Hints | Toggle | Type annotations, parameter names |
| Document Symbols | `<space>ds` | Outline of current file |
| Workspace Symbols | `<space>ws` | Search symbols across project |
| Formatting | `<space>f` / on save | Format document or selection |
| Call Hierarchy | `<space>ci` / `<space>co` | Incoming/outgoing calls |
| Semantic Tokens | Auto | Enhanced highlighting from LSP |

**Pre-configured servers:**

| Language | Server | Auto-detected |
|----------|--------|---------------|
| Rust | rust-analyzer | ✓ |
| Python | pyright / pylsp | ✓ |
| TypeScript/JS | typescript-language-server | ✓ |
| Go | gopls | ✓ |
| C/C++ | clangd | ✓ |
| Lua | lua-language-server | ✓ |
| Java | jdtls | ✓ |
| HTML/CSS | vscode-langservers | ✓ |
| JSON | vscode-json-languageserver | ✓ |
| YAML | yaml-language-server | ✓ |
| Bash | bash-language-server | ✓ |
| Zig | zls | ✓ |
| Nix | nil / nixd | ✓ |

Users can add/override in `~/.config/rvim/languages.toml`:

```toml
[[language]]
name = "rust"
scope = "source.rust"
file-types = ["rs"]
roots = ["Cargo.toml"]
language-servers = ["rust-analyzer"]
formatter = { command = "rustfmt" }
auto-format = true

[language-server.rust-analyzer]
command = "rust-analyzer"

[language-server.rust-analyzer.config]
check.command = "clippy"
```

---

### 2.3 Completion Engine

**Replaces:** `nvim-cmp`, `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `LuaSnip`

Unified completion from multiple sources, ranked and displayed in a single
menu.

**Sources (by priority):**
1. **LSP completions** — context-aware from language server
2. **Snippet completions** — LSP snippets + user-defined snippets
3. **Buffer words** — words from open buffers
4. **File paths** — triggered by `/` or `./`

**UX:**
- Auto-triggers after typing 2-3 characters (configurable)
- `Ctrl-Space` for manual trigger
- `Tab` / `Shift-Tab` to navigate menu (or `Ctrl-n` / `Ctrl-p`)
- `Enter` to confirm
- `Ctrl-e` to dismiss
- Ghost text preview of top suggestion (optional)
- Documentation popup alongside completion menu
- Snippet placeholders with tab-stop navigation

---

### 2.4 Fuzzy Picker

**Replaces:** `telescope.nvim`, `fzf-lua`

A fast, streaming fuzzy finder with preview pane.

**Pickers:**

| Keymap | Picker | Description |
|--------|--------|-------------|
| `<space>ff` | Files | Find files (respects .gitignore) |
| `<space>fg` | Live Grep | Search file contents (streaming) |
| `<space>fb` | Buffers | Switch between open buffers |
| `<space>fh` | Help | Search help topics |
| `<space>fd` | Diagnostics | All diagnostics across project |
| `<space>fs` | Document Symbols | LSP symbols in current file |
| `<space>fS` | Workspace Symbols | LSP symbols across project |
| `<space>fc` | Commands | Command palette |
| `<space>fr` | Recent Files | Recently opened files |
| `<space>f/` | Search History | Previous search patterns |
| `<space>f:` | Command History | Previous : commands |
| `<space>fm` | Marks | Jump to mark |
| `<space>fR` | Registers | View register contents |
| `<space>ft` | Themes | Preview and switch themes |
| `<space>fk` | Keymaps | Search keybindings |

**Preview pane:** Syntax-highlighted preview of the selected item. For files,
shows the file contents centered on the match. For symbols, shows the
definition in context.

**Matching:** Uses the `nucleo` crate (same as Helix) for best-in-class fuzzy
matching performance with streaming results.

---

### 2.5 Git Integration

**Replaces:** `gitsigns.nvim`, `fugitive.vim`, `lazygit.nvim`, `diffview.nvim`

#### Gutter Signs
Always-on diff markers in the gutter:
- `│` green — added lines
- `│` blue — modified lines
- `_` red — deleted lines (shown as underline on line above)

Updates asynchronously in the background via `gix`.

#### Hunk Operations

| Keymap | Action |
|--------|--------|
| `]c` | Jump to next hunk |
| `[c` | Jump to previous hunk |
| `<space>hs` | Stage hunk |
| `<space>hu` | Unstage hunk |
| `<space>hr` | Reset hunk |
| `<space>hp` | Preview hunk diff (popup) |

#### Git Blame
| Keymap | Action |
|--------|--------|
| `<space>gb` | Toggle inline blame (virtual text) |
| `<space>gB` | Full blame for current file |

#### Git Status Panel
| Keymap | Action |
|--------|--------|
| `<space>gs` | Open git status panel |

Shows staged, unstaged, and untracked files. Actions within:
- `s` — stage file/hunk
- `u` — unstage
- `=` — toggle inline diff
- `cc` — commit
- `ca` — commit --amend
- `Enter` — open file

#### Git Log
| Keymap | Action |
|--------|--------|
| `<space>gl` | Git log (current file) |
| `<space>gL` | Git log (all) |

---

### 2.6 Debug Adapter Protocol (DAP)

**Replaces:** `nvim-dap`, `nvim-dap-ui`

Built-in debugging via the Debug Adapter Protocol.

**UI Layout (when debugging):**

```
┌──────────────────────────────────────────────────────┐
│ [Threads] [Stack Frames]                             │
├──────────────────────────────────┬───────────────────┤
│                                  │ Variables         │
│   Source Code                    │  ├── Local        │
│   (with breakpoint gutter)      │  │   x = 42       │
│                                  │  │   name = "hi"  │
│  ● 15 │ let x = compute();      │  ├── Global       │
│    16 │ if x > 0 {              │  └── Arguments     │
│  → 17 │     process(x); ←PAUSED │                    │
│    18 │ }                        ├───────────────────┤
│                                  │ Watch             │
│                                  │  x + y = 57       │
├──────────────────────────────────┴───────────────────┤
│ [Debug Console / REPL]                               │
└──────────────────────────────────────────────────────┘
```

**Keybindings:**

| Keymap | Action |
|--------|--------|
| `<space>db` | Toggle breakpoint |
| `<space>dB` | Conditional breakpoint |
| `<space>dc` | Continue |
| `<space>ds` | Step over |
| `<space>di` | Step into |
| `<space>do` | Step out |
| `<space>dr` | Open REPL |
| `<space>dl` | Run last configuration |
| `<space>dt` | Terminate session |

**Pre-configured adapters:**

| Language | Adapter | Config key |
|----------|---------|------------|
| Rust / C / C++ | codelldb / lldb-dap | `debugger.codelldb` |
| Python | debugpy | `debugger.debugpy` |
| JavaScript / TS | js-debug | `debugger.js-debug` |
| Go | dlv (delve) | `debugger.delve` |

---

### 2.7 Surround

**Replaces:** `nvim-surround`, `mini.surround`

Built-in as native Vim operators and commands.

| Keymap | Action | Example |
|--------|--------|---------|
| `ys{motion}{char}` | Add surround | `ysiw"` → surround word with `"` |
| `yss{char}` | Surround line | `yss)` → wrap line in `()` |
| `cs{old}{new}` | Change surround | `cs"'` → change `"` to `'` |
| `ds{char}` | Delete surround | `ds(` → remove surrounding `()` |
| `S{char}` (visual) | Surround selection | Select, `S{` → wrap in `{}` |

**Smart pairs:** `(` adds with spaces `( foo )`, `)` without `(foo)`.
Same for `{`/`}`, `[`/`]`.

**Tag support:** `t` for HTML tags. `cst<div>` changes surrounding tag to
`<div>`. `dst` deletes surrounding tag.

---

### 2.8 Comment Toggle

**Replaces:** `Comment.nvim`, `mini.comment`

The `gc` operator toggles comments using Tree-sitter to determine the
correct comment syntax for the language at the cursor position.

| Keymap | Action |
|--------|--------|
| `gc{motion}` | Toggle comment (operator) |
| `gcc` | Toggle comment on current line |
| `gc` (visual) | Toggle comment on selection |
| `gC{motion}` | Toggle block comment |

Correctly handles:
- Embedded languages (CSS in HTML, JS in HTML)
- JSX/TSX (line comments in code, `{/* */}` in JSX)
- Multiple comment styles per language (e.g., `//` and `/* */` in C)

---

### 2.9 Which-key Hints

**Replaces:** `which-key.nvim`

After pressing a prefix key (e.g., `<space>`, `g`, `z`, `[`, `]`), a popup
appears showing all available continuations:

```
┌──────────────────────────────────────────┐
│ <space> +                                │
│                                          │
│  f  → Find...        g  → Git...        │
│  d  → Debug...       r  → Rename        │
│  c  → Code action    e  → Explorer      │
│  b  → Buffer...      w  → Window...     │
│  h  → Hunk...        t  → Terminal      │
│  /  → Search project  q  → Quickfix     │
└──────────────────────────────────────────┘
```

- Appears after a configurable delay (default: 300ms)
- Disappears on next keypress
- Groups sub-menus with `+` suffix
- Shows key descriptions from keymap definitions

---

### 2.10 Built-in Terminal

**Replaces:** `toggleterm.nvim`

| Keymap | Action |
|--------|--------|
| `<space>t` | Toggle terminal (horizontal split) |
| `<space>T` | Toggle terminal (vertical split) |
| `<C-\><C-n>` | Exit terminal mode → normal mode |
| `:terminal` | Open terminal in current split |
| `:terminal {cmd}` | Run command in terminal |

Terminal supports:
- True color rendering
- Multiple persistent terminal instances
- Terminal normal mode (scroll, copy text)
- Auto-insert mode when entering terminal pane
- Send selection to terminal (`<space>ts` in visual mode)

---

### 2.11 Auto-pairs

**Replaces:** `nvim-autopairs`, `mini.pairs`

In insert mode, automatically close brackets and quotes:

| Trigger | Result | Condition |
|---------|--------|-----------|
| `(` | `()` with cursor between | Always |
| `{` | `{}` with cursor between | Always |
| `[` | `[]` with cursor between | Always |
| `"` | `""` with cursor between | Not inside string (TS) |
| `'` | `''` with cursor between | Not inside string (TS) |
| `` ` `` | ` `` ` ` ` | Not inside string (TS) |
| `<BS>` on `()` | Delete both | Cursor between pair |
| `<CR>` on `{}` | Expand with indent | Cursor between pair |

Tree-sitter-aware: doesn't auto-close inside strings or comments.

---

### 2.12 Indent Guides

**Replaces:** `indent-blankline.nvim`

Renders vertical lines at indentation levels:

```
  fn main() {
  │   let x = 1;
  │   if x > 0 {
  │   │   println!("positive");
  │   │   if x > 10 {
  │   │   │   println!("big!");
  │   │   }
  │   }
  }
```

- Current scope highlighted in a brighter color
- Uses Tree-sitter to determine scope boundaries
- Configurable: on/off, character, color

---

### 2.13 File Explorer

**Replaces:** `neo-tree.nvim`, `nvim-tree`, `oil.nvim`

Two modes:

**Tree mode** (`<space>e`): sidebar file tree
```
  rvim/
  ├── src/
  │   ├── main.rs
  │   ├── editor.rs
  │   └── config.rs
  ├── Cargo.toml
  └── README.md
```

**Oil mode** (`-`): edit directory as buffer (like oil.nvim)
- Navigate into directories by pressing `Enter`
- Press `-` to go up
- Rename files by editing the buffer
- Delete files by deleting lines
- Create files by typing new entries

---

### 2.14 Label-jump (EasyMotion / Flash / Leap)

**Replaces:** `flash.nvim`, `leap.nvim`, `hop.nvim`

Quick jump to any visible position using labels:

| Keymap | Action |
|--------|--------|
| `s{c}{c}` | Jump forward to 2-char match |
| `S{c}{c}` | Jump backward to 2-char match |

After typing two characters, all matches on screen get a label:

```
  let result = compute_value(x, y);
                a              b  c
  let output = format_result(result);
                d              e
```

Press the label letter to jump there instantly.

Can also be used as a motion with operators: `ds{c}{c}` deletes to the
labeled position.

---

### 2.15 Diagnostics Panel

**Replaces:** `trouble.nvim`

`<space>xx` opens a diagnostics panel at the bottom:

```
┌─ Diagnostics (3 errors, 5 warnings) ─────────────────────┐
│ E src/main.rs:15:4   unused variable `x`                  │
│ E src/main.rs:22:1   mismatched types                      │
│ E src/lib.rs:8:12    cannot find value `foo`               │
│ W src/main.rs:3:1    unused import `std::io`               │
│ W src/config.rs:45:8 field `name` is never read            │
│ ...                                                        │
└───────────────────────────────────────────────────────────┘
```

- Filter by severity, file, or source
- `Enter` to jump to location
- Auto-refreshes as LSP diagnostics update
- Also accessible as a picker: `<space>fd`

---

### 2.16 Multi-cursor

**Replaces:** `vim-visual-multi`

| Keymap | Action |
|--------|--------|
| `<C-d>` | Add cursor at next match of current word/selection |
| `<C-u>` | Remove last added cursor |
| `<A-j>` / `<A-k>` | Add cursor above/below |
| `<space>ma` | Select all matches in document |

Once multiple cursors are active, all normal editing operations apply
simultaneously to all cursor positions.

---

### 2.17 Statusline

**Replaces:** `lualine.nvim`

```
 NORMAL │ main │ src/main.rs [+] │ rust │ E:2 W:5 │ utf-8 │ LF │ 42:15 │ 67%
```

Sections (left to right):
1. **Mode** — Color-coded (green=normal, blue=insert, purple=visual)
2. **Git branch** — Current branch name
3. **Filename** — Relative path, `[+]` if modified, `[RO]` if read-only
4. **Language** — Detected filetype
5. **Diagnostics** — Error/warning counts
6. **Encoding** — utf-8, latin1, etc.
7. **Line ending** — LF or CRLF
8. **Position** — line:column
9. **Progress** — Percentage through file

---

### 2.18 Tabline / Bufferline

**Replaces:** `bufferline.nvim`

Configurable bar at the top showing open buffers or tabs:

```
 main.rs │ config.rs [+] │ Cargo.toml │ lib.rs
```

- Active buffer highlighted
- Modified indicator (`[+]`)
- Click to switch (mouse support)
- `gt` / `gT` or `:bnext` / `:bprev` to cycle

---

### 2.19 Scrollbar

**Replaces:** `nvim-scrollbar`

Thin scrollbar on the right edge showing:
- Current viewport position
- Diagnostic markers (red/yellow dots)
- Search match positions
- Git diff markers

---

### 2.20 Colorscheme Engine

**Replaces:** Manual theme configuration

Themes are TOML files mapping scope names to styles. Scopes follow a
hierarchical naming convention:

```toml
# Syntax scopes (from tree-sitter captures)
"keyword"                = { fg = "#c678dd", modifiers = ["bold"] }
"keyword.control"        = { fg = "#c678dd" }
"keyword.function"       = { fg = "#c678dd" }
"function"               = { fg = "#61afef" }
"function.builtin"       = { fg = "#56b6c2" }
"type"                   = { fg = "#e5c07b" }
"type.builtin"           = { fg = "#e5c07b", modifiers = ["bold"] }
"string"                 = { fg = "#98c379" }
"number"                 = { fg = "#d19a66" }
"comment"                = { fg = "#5c6370", modifiers = ["italic"] }
"variable"               = { fg = "#e06c75" }
"constant"               = { fg = "#d19a66", modifiers = ["bold"] }
"operator"               = { fg = "#56b6c2" }
"punctuation"            = { fg = "#abb2bf" }

# UI scopes
"ui.background"          = { bg = "#282c34" }
"ui.cursor"              = { fg = "#282c34", bg = "#528bff" }
"ui.cursor.match"        = { fg = "#282c34", bg = "#e06c75" }
"ui.selection"           = { bg = "#3e4452" }
"ui.linenr"              = { fg = "#495162" }
"ui.linenr.selected"     = { fg = "#abb2bf" }
"ui.statusline"          = { fg = "#abb2bf", bg = "#21252b" }
"ui.statusline.inactive" = { fg = "#5c6370", bg = "#21252b" }
"ui.popup"               = { fg = "#abb2bf", bg = "#21252b" }
"ui.menu"                = { fg = "#abb2bf", bg = "#21252b" }
"ui.menu.selected"       = { fg = "#282c34", bg = "#61afef" }
"ui.virtual.indent-guide" = { fg = "#3b4048" }
"ui.virtual.ruler"       = { bg = "#2c313a" }

# Diagnostic scopes
"diagnostic.error"       = { underline = { color = "#e06c75", style = "curl" } }
"diagnostic.warning"     = { underline = { color = "#e5c07b", style = "curl" } }
"diagnostic.info"        = { underline = { color = "#61afef", style = "curl" } }
"diagnostic.hint"        = { underline = { color = "#56b6c2", style = "curl" } }

# Diff scopes
"diff.plus"              = { fg = "#98c379" }
"diff.minus"             = { fg = "#e06c75" }
"diff.delta"             = { fg = "#e5c07b" }
"diff.plus.gutter"       = { fg = "#98c379" }
"diff.minus.gutter"      = { fg = "#e06c75" }
"diff.delta.gutter"      = { fg = "#e5c07b" }
```

**Shipped themes:** onedark, catppuccin (latte, frappe, macchiato, mocha),
gruvbox (dark, light), tokyonight (night, storm, day), rose-pine (main, moon,
dawn), kanagawa, nord, dracula, solarized (dark, light), everforest, nightfox.

---

## 3. Configuration

All features are configurable via `~/.config/rvim/config.toml`:

```toml
theme = "onedark"

[editor]
line-number = "relative"
scrolloff = 8
cursorline = true
auto-save = false
auto-format = true
auto-pairs = true
idle-timeout = 250           # ms before idle events (completion, hover)
completion-trigger-len = 2   # chars before auto-complete triggers
mouse = true
rulers = [80, 120]

[editor.indent-guides]
render = true
character = "│"
skip-levels = 0

[editor.gutters]
layout = ["diagnostics", "diff", "line-numbers", "spacer", "breakpoints"]

[editor.statusline]
left = ["mode", "git-branch", "file-name", "file-modified"]
center = []
right = ["diagnostics", "language", "encoding", "line-ending", "position", "file-type"]

[editor.whitespace]
render = "none"              # "none", "all", "trailing"

[editor.cursor-shape]
normal = "block"
insert = "bar"
visual = "underline"

[editor.file-picker]
hidden = false               # show hidden files
git-ignore = true

[keys.normal]
# Custom keybindings
"C-s" = ":write"
"C-q" = ":quit"

[keys.normal.space]
# Space-prefixed leader keys (customizable)
f = { f = "file_picker", g = "live_grep", b = "buffer_picker" }
```
