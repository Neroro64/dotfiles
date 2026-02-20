# rvim — Development Roadmap

> Phased plan from first keystroke to a full Neovim replacement.
> Each phase produces a usable (if incomplete) editor, enabling
> dogfooding as early as possible.

---

## Timeline Overview

```
Phase 1: Foundation          ████████████░░░░░░░░░░░░░░░░░░░░░░░░  Months 1-3
Phase 2: Language Intel      ░░░░░░░░░░░░████████████░░░░░░░░░░░░  Months 3-5
Phase 3: Power Editing       ░░░░░░░░░░░░░░░░░░░░░░░░████████░░░░  Months 5-7
Phase 4: Ecosystem           ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█████  Months 7-10
Phase 5: Polish & Community  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██  Months 10+
```

---

## Phase 1 — Foundation (Months 1-3)

> *Goal: A working modal editor that can open, edit, and save files
> with basic Vim keybindings. The skeleton that everything else
> builds on.*

### Milestone 1.1 — Terminal & Rendering (Weeks 1-2)

**Deliverable:** A blank terminal canvas you can draw on.

| Task | Crate | Description |
|------|-------|-------------|
| Raw mode setup | rvim-tui | Enter/exit raw mode, alternate screen, cleanup on panic |
| Cell grid | rvim-tui | `Surface` type: 2D array of `Cell { symbol, style }` |
| Double buffering | rvim-tui | Diff previous/current surface, flush minimal writes |
| Crossterm backend | rvim-tui | Implement `Backend` trait for crossterm |
| Basic layout | rvim-tui | `Rect` type, split into sub-rects |
| Event reading | rvim-tui | Read keyboard/mouse/resize events via crossterm |
| Style primitives | rvim-tui | `Color` (RGB, indexed, named), `Modifier`, `Style` |

**Test:** Fill screen with colored text, respond to resize.

### Milestone 1.2 — Rope Buffer (Weeks 2-3)

**Deliverable:** A text buffer you can programmatically edit.

| Task | Crate | Description |
|------|-------|-------------|
| Rope wrapper | rvim-core | Thin wrapper over `ropey::Rope` with helper methods |
| Position math | rvim-core | Byte ↔ char ↔ (line, col) conversions |
| Line ending | rvim-core | Detect and normalize LF/CRLF |
| Grapheme support | rvim-core | Grapheme-cluster-aware iteration and width |
| Character class | rvim-core | Word vs WORD vs whitespace vs punctuation |
| Selection type | rvim-core | `Range { anchor, head }`, `Selection` (Vec<Range>) |
| Transaction type | rvim-core | `ChangeSet` (retain/insert/delete), `Transaction` |
| File I/O | rvim-core | Open file → Rope, Rope → save file (atomic write) |

**Test:** Unit tests for all rope operations, round-trip file open/save.

### Milestone 1.3 — Basic Rendering (Weeks 3-4)

**Deliverable:** Open a file and see its contents on screen.

| Task | Crate | Description |
|------|-------|-------------|
| Document type | rvim-view | `Document` struct: Rope + Selection + filepath |
| View type | rvim-view | `View`: document ID, scroll offset, viewport rect |
| Editor type | rvim-view | `Editor`: owns documents, views, config |
| Text rendering | rvim-term | Render document text line-by-line to surface |
| Line numbers | rvim-term | Gutter with absolute line numbers |
| Cursor rendering | rvim-term | Show block cursor at primary selection head |
| Viewport scroll | rvim-view | Scroll offset tracking, scrolloff margin |
| Application shell | rvim-term | `Application` struct, basic event loop |
| CLI args | rvim-term | `rvim <filename>` opens file |

**Test:** Open a Rust file, see syntax-less text with cursor.

### Milestone 1.4 — Vim Grammar Core (Weeks 4-6)

**Deliverable:** Basic modal editing — `hjkl`, `dw`, `cw`, etc.

| Task | Crate | Description |
|------|-------|-------------|
| Mode enum | rvim-core | Normal, Insert, Visual (stub), CommandLine (stub) |
| VimGrammar state machine | rvim-core | Ground, OperatorPending, WaitingForChar states |
| Count accumulation | rvim-core | `[count]` prefix parsing |
| Character motions | rvim-core | `h`, `j`, `k`, `l` |
| Word motions | rvim-core | `w`, `b`, `e`, `W`, `B`, `E`, `ge`, `gE` |
| Line motions | rvim-core | `0`, `^`, `$`, `g_` |
| Vertical motions | rvim-core | `gg`, `G`, `H`, `M`, `L` |
| Find motions | rvim-core | `f`, `F`, `t`, `T`, `;`, `,` |
| Paragraph motions | rvim-core | `{`, `}` |
| Delete operator | rvim-core | `d` + motion, `dd`, `D`, `x`, `X` |
| Change operator | rvim-core | `c` + motion, `cc`, `C`, `s`, `S` |
| Yank operator | rvim-core | `y` + motion, `yy`, `Y` |
| Put (paste) | rvim-core | `p`, `P` |
| Basic text objects | rvim-core | `iw`, `aw`, `iW`, `aW`, `i(`, `a(`, `i"`, `a"` |
| Insert mode | rvim-term | `i`, `a`, `o`, `O`, `I`, `A` → type text → `Esc` |
| Insert mode editing | rvim-term | `Backspace`, `Delete`, `Enter`, arrow keys |
| Mode indicator | rvim-term | Show current mode in statusline area |
| Keymap trie | rvim-term | `KeyTrie` for multi-key sequence lookup |
| Default keymap | rvim-term | Wire all above commands to keys |

**Test:** Navigate and edit a file using standard Vim motions.

### Milestone 1.5 — Undo, Save, Buffers (Weeks 6-8)

**Deliverable:** A usable (if basic) text editor.

| Task | Crate | Description |
|------|-------|-------------|
| History (linear) | rvim-core | Undo stack of Transactions. `u` / `Ctrl-r` |
| Modified tracking | rvim-view | Document tracks unsaved changes |
| Write command | rvim-term | `:w` — save current file |
| Quit command | rvim-term | `:q`, `:q!`, `:wq`, `:x` |
| Prompt component | rvim-term | `:` command-line input at bottom of screen |
| Buffer management | rvim-view | Multiple documents in Editor |
| Buffer commands | rvim-term | `:e {file}`, `:bnext`, `:bprev`, `:bd` |
| Compositor | rvim-term | Component stack: EditorView + Prompt layers |
| Join lines | rvim-core | `J` command |
| Replace char | rvim-core | `r{char}` command |
| Tilde (toggle case) | rvim-core | `~` command |
| Repeat | rvim-core | `.` (dot repeat) — basic version |
| Statusline | rvim-term | Mode + filename + modified + line:col + percentage |

**Test:** Full editing session: open → edit → save → switch buffer → quit.

### Phase 1 Exit Criteria
- [ ] Open file from CLI
- [ ] All basic Vim motions working (h/j/k/l, w/b/e, 0/^/$, gg/G, f/t)
- [ ] Operators d/c/y compose with motions and basic text objects
- [ ] Insert mode with proper entry/exit
- [ ] Undo/redo
- [ ] `:w`, `:q`, `:wq`, `:e`, `:bnext`, `:bprev`
- [ ] Dot repeat for basic commands
- [ ] No crashes on large files or binary files

---

## Phase 2 — Language Intelligence (Months 3-5)

> *Goal: Syntax highlighting and LSP make rvim actually useful for
> programming. This is where dogfooding becomes viable.*

### Milestone 2.1 — Tree-sitter Highlighting (Weeks 8-10)

| Task | Crate | Description |
|------|-------|-------------|
| Grammar loader | rvim-syntax | Load compiled `.so` grammars from runtime dir |
| Grammar fetch/build | rvim-syntax | `rvim --grammar fetch && rvim --grammar build` |
| Parser wrapper | rvim-syntax | `Syntax` type wrapping `tree_sitter::Parser` + `Tree` |
| Incremental re-parse | rvim-syntax | Update tree after Transaction edit |
| Highlight queries | rvim-syntax | Load and apply `highlights.scm` |
| Highlight iterator | rvim-syntax | Iterate highlight events → styled spans |
| Language detection | rvim-syntax | File extension → language mapping in `languages.toml` |
| Integration | rvim-term | Apply highlight styles during text rendering |
| Ship queries | runtime | `highlights.scm` for Rust, Python, JS, TS, Go, C, JSON, TOML, Markdown |
| Grammar CI | build | Fetch + compile grammars in CI/release |

**Test:** Open a Rust file, see correct keyword/string/comment highlighting.

### Milestone 2.2 — Theme Engine (Weeks 10-11)

| Task | Crate | Description |
|------|-------|-------------|
| Theme TOML parser | rvim-view | Parse theme files with scope → style mappings |
| Scope resolution | rvim-view | Hierarchical lookup: `keyword.function` → `keyword` → default |
| UI scopes | rvim-view | Cursor, selection, gutter, statusline, popup styles |
| Palette support | rvim-view | Named colors in `[palette]` section |
| Ship themes | runtime | onedark, catppuccin-mocha, gruvbox-dark, tokyonight |
| Theme switching | rvim-term | `:theme {name}` command |
| Theme picker | rvim-term | Preview themes in picker (once picker exists) |

**Test:** Switch between themes, all UI elements update correctly.

### Milestone 2.3 — LSP Client (Weeks 11-14)

| Task | Crate | Description |
|------|-------|-------------|
| JSON-RPC transport | rvim-lsp | Framed reader/writer over stdio |
| LSP client core | rvim-lsp | Initialize, capabilities, shutdown lifecycle |
| Document sync | rvim-lsp | textDocument/didOpen, didChange, didClose, didSave |
| Client registry | rvim-lsp | Language → client mapping, multiple server support |
| Completion | rvim-lsp + term | textDocument/completion → menu UI |
| Completion menu | rvim-term | Popup menu with item list, doc preview, ghost text |
| Diagnostics | rvim-lsp + view | Receive + display inline diagnostics |
| Diagnostic navigation | rvim-term | `]d`, `[d` jump to next/prev diagnostic |
| Hover | rvim-lsp + term | `K` → textDocument/hover → popup |
| Go to definition | rvim-lsp + term | `gd` → textDocument/definition |
| Go to references | rvim-lsp + term | `gr` → textDocument/references → picker |
| Signature help | rvim-lsp + term | Auto-show in function call parens |
| Progress reporting | rvim-lsp | Show LSP progress in statusline |
| Server configs | runtime | Default configs for top 10 language servers |

**Test:** Open a Rust project, get completions, see diagnostics, jump to definition.

### Milestone 2.4 — TS Indent + Text Objects (Weeks 14-16)

| Task | Crate | Description |
|------|-------|-------------|
| Indent queries | rvim-syntax | Load `indents.scm`, compute indent for new lines |
| Smart indent | rvim-term | Apply TS indent on `Enter` and `o`/`O` |
| Text object queries | rvim-syntax | Load `textobjects.scm` |
| TS text objects | rvim-core + syntax | `af`, `if` (function), `ac`, `ic` (class), `aa`, `ia` (parameter) |
| All bracket pairs | rvim-core | `i(`, `i{`, `i[`, `i<`, `i"`, `i'`, `i`` ` |
| Tag text objects | rvim-core | `it`, `at` (HTML/XML tags) |
| Sentence/paragraph | rvim-core | `is`, `as`, `ip`, `ap` |

**Test:** `vaf` selects entire function, `cic` changes class body.

### Phase 2 Exit Criteria
- [ ] Syntax highlighting for 10+ languages
- [ ] 4 themes shipping
- [ ] LSP completion, diagnostics, go-to-definition, hover working
- [ ] Tree-sitter-powered indentation
- [ ] Tree-sitter text objects (function, class, parameter)
- [ ] All bracket/quote text objects
- [ ] Viable for simple programming sessions (dogfood-ready)

---

## Phase 3 — Power Editing (Months 5-7)

> *Goal: The features that make Vim users productive — visual mode,
> splits, registers, macros, search/replace, and the fuzzy picker.*

### Milestone 3.1 — Visual Mode (Weeks 16-18)

| Task | Crate | Description |
|------|-------|-------------|
| Visual charwise | rvim-core + term | `v` → motions extend selection → operator acts on it |
| Visual linewise | rvim-core + term | `V` → select whole lines |
| Visual blockwise | rvim-core + term | `Ctrl-v` → rectangular selection |
| Visual operators | rvim-core | d, c, y, >, <, ~, u, U, J, gq in visual mode |
| Visual surround | rvim-core | `S{char}` wraps visual selection |
| `gv` | rvim-term | Reselect last visual selection |
| `o` / `O` in visual | rvim-term | Swap selection anchor/head |

### Milestone 3.2 — Splits & Windows (Weeks 18-19)

| Task | Crate | Description |
|------|-------|-------------|
| Split tree | rvim-view | Binary tree of views (horizontal/vertical splits) |
| Split commands | rvim-term | `:split`, `:vsplit`, `Ctrl-w s`, `Ctrl-w v` |
| Window navigation | rvim-term | `Ctrl-w h/j/k/l`, `Ctrl-w w` |
| Window resize | rvim-term | `Ctrl-w +/-/</>`, `Ctrl-w =` |
| Window close | rvim-term | `Ctrl-w q`, `Ctrl-w o` (close others) |
| Window move | rvim-term | `Ctrl-w H/J/K/L` (move window to edge) |
| Multi-view rendering | rvim-term | Render split tree with separator lines |

### Milestone 3.3 — Registers & Macros (Weeks 19-20)

| Task | Crate | Description |
|------|-------|-------------|
| Named registers | rvim-core | `"a` - `"z` (write), `"A` - `"Z` (append) |
| System clipboard | rvim-core | `"+` / `"*` via platform clipboard commands |
| Special registers | rvim-core | `"0` (yank), `"1`-`"9` (delete ring), `"/`, `":`, `"_` |
| Macro recording | rvim-core | `q{reg}` to record, `q` to stop |
| Macro playback | rvim-term | `@{reg}` to play, `@@` to repeat, `{count}@{reg}` |
| Recursion guard | rvim-core | Max depth = 1000 |
| `:registers` command | rvim-term | Display register contents |

### Milestone 3.4 — Search & Replace (Weeks 20-22)

| Task | Crate | Description |
|------|-------|-------------|
| Forward search | rvim-term | `/pattern<CR>` with incremental highlighting |
| Backward search | rvim-term | `?pattern<CR>` |
| Search navigation | rvim-term | `n`, `N`, `*`, `#` |
| Search highlighting | rvim-term | Highlight all matches in viewport |
| `:noh` | rvim-term | Clear search highlights |
| Substitute | rvim-term | `:s/old/new/g`, `:%s/old/new/g`, visual range `:s` |
| Substitute flags | rvim-term | `g` (global), `i` (case insensitive), `c` (confirm) |
| Confirm substitute | rvim-term | `y`/`n`/`a`/`q`/`l` at each match |
| `&` / `:&&` | rvim-term | Repeat last substitute |

### Milestone 3.5 — Fuzzy Picker (Weeks 22-24)

| Task | Crate | Description |
|------|-------|-------------|
| Picker core | rvim-picker | Generic `Picker<T>` with nucleo fuzzy matching |
| Picker UI | rvim-term | Input → filtered list → preview pane |
| Async injection | rvim-picker | Stream items in from background |
| File picker | rvim-picker | Walk directories respecting .gitignore |
| Live grep | rvim-picker | Ripgrep-style content search |
| Buffer picker | rvim-picker | Switch between open buffers |
| Symbol picker | rvim-picker | LSP document/workspace symbols |
| Diagnostic picker | rvim-picker | List all diagnostics |
| Command palette | rvim-picker | Search all available commands |
| Syntax preview | rvim-picker | Highlighted preview of selected file |

### Milestone 3.6 — Remaining Operators & Motions (Weeks 24-26)

| Task | Crate | Description |
|------|-------|-------------|
| Indent/dedent | rvim-core | `>` / `<` operators, `>>` / `<<` |
| Auto-indent | rvim-core | `=` operator |
| Format | rvim-core | `gq` operator (textwidth or LSP) |
| Case operators | rvim-core | `gu`, `gU`, `g~` |
| LSP rename | rvim-term | `<space>rn` → textDocument/rename |
| LSP code actions | rvim-term | `<space>ca` → textDocument/codeAction |
| LSP formatting | rvim-term | `<space>f` → textDocument/formatting |
| LSP inlay hints | rvim-term | Toggle inlay hint display |
| Jump list | rvim-core | `Ctrl-o` / `Ctrl-i` — navigate jump history |
| Change list | rvim-core | `g;` / `g,` — navigate change positions |
| Mark system | rvim-core | `m{a-z}` set mark, `` ` ``/`'` go to mark |
| Scroll commands | rvim-term | `Ctrl-u`, `Ctrl-d`, `Ctrl-f`, `Ctrl-b`, `zz`, `zt`, `zb` |

### Phase 3 Exit Criteria
- [ ] Full visual mode (char, line, block)
- [ ] Split windows with navigation
- [ ] Named registers + system clipboard
- [ ] Macro recording and playback
- [ ] Search with highlighting + `:substitute`
- [ ] Fuzzy picker for files, grep, buffers, symbols
- [ ] All standard Vim operators working
- [ ] Jump list and mark system
- [ ] **Dogfoodable for daily Rust development**

---

## Phase 4 — Ecosystem (Months 7-10)

> *Goal: The quality-of-life features that make the difference between
> "I can use this" and "I don't want to go back."*

### Milestone 4.1 — Git Integration (Weeks 26-28)

| Task | Crate | Description |
|------|-------|-------------|
| Git diff provider | rvim-git | Async line-level diff computation via `gix` |
| Gutter diff signs | rvim-git + term | Added/modified/deleted signs in gutter |
| Hunk navigation | rvim-term | `]c` / `[c` jump between hunks |
| Hunk operations | rvim-term | Stage, unstage, reset, preview hunk |
| Inline blame | rvim-git + term | Virtual text blame toggle |
| Git status panel | rvim-term | Interactive file status list |
| Git log | rvim-term | Commit log with diff viewer |

### Milestone 4.2 — DAP Integration (Weeks 28-30)

| Task | Crate | Description |
|------|-------|-------------|
| DAP transport | rvim-dap | Content-Length framed JSON over stdio |
| DAP client | rvim-dap | Initialize, launch/attach, lifecycle |
| Breakpoints | rvim-dap + view | Set/toggle, conditional, gutter display |
| Step execution | rvim-dap | Continue, step over/into/out |
| Debug UI | rvim-term | Stack frames, variables, watch, REPL |
| Adapter configs | runtime | codelldb, debugpy, delve, js-debug |

### Milestone 4.3 — Built-in Extras (Weeks 30-34)

| Task | Crate | Description |
|------|-------|-------------|
| Surround | rvim-core | `ys`, `cs`, `ds` operators |
| Comment toggle | rvim-core | `gc` operator (TS-aware) |
| Auto-pairs | rvim-term | Insert-mode bracket/quote auto-close (TS-aware) |
| Which-key popup | rvim-term | Key hint display after prefix key delay |
| Indent guides | rvim-term | Vertical indent lines with scope highlight |
| Built-in terminal | rvim-term | Terminal emulator in splits |
| Diagnostics panel | rvim-term | Filterable diagnostic list (trouble-like) |
| Label-jump | rvim-core + term | `s`/`S` two-char jump (flash/leap-like) |
| File explorer | rvim-term | Tree sidebar + oil-like buffer mode |
| Tabline / bufferline | rvim-term | Buffer bar at top of screen |
| Scrollbar | rvim-tui | Viewport indicator with diagnostic/search markers |
| Color highlighter | rvim-term | Inline color swatches for hex/rgb values |

### Milestone 4.4 — Configuration (Weeks 34-36)

| Task | Crate | Description |
|------|-------|-------------|
| Config file loading | rvim-term | `~/.config/rvim/config.toml` |
| Keybinding customization | rvim-term | User keymaps merge with defaults |
| Languages config | rvim-view | `languages.toml` for LSP, formatter, debugger |
| Project-local config | rvim-term | `.rvim/config.toml` in workspace root |
| `:set` command | rvim-term | Runtime option changes |
| Config hot-reload | rvim-term | Watch config files, apply changes live |

### Phase 4 Exit Criteria
- [ ] Git gutter, blame, status, log working
- [ ] DAP debugging for Rust + Python
- [ ] Surround, comment, auto-pairs built in
- [ ] Which-key, indent guides, diagnostics panel
- [ ] Built-in terminal
- [ ] File explorer (tree + oil mode)
- [ ] Full user configuration system
- [ ] **Competitive with a well-configured Neovim setup**

---

## Phase 5 — Polish & Community (Months 10+)

> *Goal: Production quality. Performance, stability, documentation,
> and the features that make rvim a joy to use.*

### Milestone 5.1 — Performance & Stability

| Task | Description |
|------|-------------|
| Profiling | Benchmark keypress-to-render latency, target <5ms |
| Large file handling | Test with 1GB+ files, ensure no OOM or hangs |
| Memory profiling | Track RSS, ensure <50MB for typical sessions |
| Stress testing | Rapid input, pathological inputs, concurrent LSP responses |
| Crash recovery | Auto-save swap files, recovery on restart |
| Binary file detection | Graceful handling of non-text files |
| Encoding support | UTF-8 (primary), Latin-1, detection heuristics |

### Milestone 5.2 — Undo Tree

| Task | Description |
|------|-------------|
| Tree undo model | Branching history instead of linear stack |
| `g-` / `g+` | Navigate undo by timestamp |
| `:earlier` / `:later` | Time-based undo (`:earlier 5m`) |
| Persistent undo | Save undo history to disk across sessions |
| Undo tree visualizer | Visual representation of undo branches |

### Milestone 5.3 — Advanced Features

| Task | Description |
|------|-------------|
| Session save/restore | `:mksession`, auto-session |
| Mouse support | Click, drag-select, scroll, resize splits |
| Multiple cursor polish | `Ctrl-d` workflow, select all matches |
| Spell checking | Built-in spell check with dictionary |
| Folding | Tree-sitter-based code folding (`zf`, `zo`, `zc`, `za`) |
| Diff mode | Side-by-side diff view (`:diffthis`) |
| Persistent marks | Marks survive across sessions |
| Quickfix list | `:copen`, `:cnext`, `:cprev` |
| Location list | Per-window quickfix equivalent |
| Help system | `:help` with searchable documentation |

### Milestone 5.4 — Distribution & Packaging

| Task | Description |
|------|-------------|
| CI/CD | GitHub Actions for Linux, macOS, Windows |
| Release binaries | Pre-built binaries for all platforms |
| Homebrew formula | `brew install rvim` |
| Cargo install | `cargo install rvim` |
| AUR package | Arch Linux package |
| Nix flake | Reproducible Nix build with pre-compiled grammars |
| Snap / Flatpak | Linux universal packages |
| Single binary mode | Embed runtime assets in binary |

### Milestone 5.5 — Documentation & Community

| Task | Description |
|------|-------------|
| User guide | Comprehensive book (mdbook) |
| API docs | `cargo doc` for all crates |
| Keybinding reference | Full keymap cheat sheet |
| Migration guide | "Coming from Neovim" document |
| Contributing guide | How to add languages, themes, features |
| Website | Landing page + documentation site |
| Community | Discord / Matrix channel |

### Milestone 5.6 — Extensibility (Future)

| Task | Description |
|------|-------------|
| Plugin architecture | Define plugin API boundaries |
| WASM runtime | Load WASM plugins (like Zed/Lapce) |
| Plugin API | Expose editor state, keybindings, UI to plugins |
| Plugin manager | Fetch, install, update plugins |
| Plugin repository | Community plugin registry |

---

## Risk Register

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Vim grammar complexity underestimated | High | Medium | Start with subset, add incrementally. Test against Vim behavior |
| Tree-sitter grammar compatibility | Medium | Low | Use same grammars/queries as Helix — proven ecosystem |
| LSP spec complexity | High | Medium | Start with core features (completion, diag, goto-def). Add incrementally |
| DAP spec less stable than LSP | Medium | Medium | Follow Helix's implementation as reference |
| Single-developer velocity | High | High | Prioritize ruthlessly. Phase 1-2 must be laser-focused |
| Performance regression | Medium | Medium | Benchmark from day 1. Profile regularly |
| Feature creep | High | High | Stick to phased roadmap. Say "not yet" often |

---

## Metrics to Track

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Keypress-to-render latency | <5ms p99 | Internal instrumentation |
| Startup time (empty file) | <20ms | `time rvim --headless -c ':quit'` |
| Startup time (project) | <100ms | Measure with LSP handshake |
| Memory (idle, 10 buffers) | <50MB RSS | `ps` / `/proc/pid/status` |
| Memory (1GB file) | <1.5GB RSS | Rope overhead ≈ 1.5x file size |
| Binary size | <20MB | `ls -la target/release/rvim` |
| Supported languages | 100+ | Count shipped grammars |
| Shipped themes | 15+ | Count theme files |
