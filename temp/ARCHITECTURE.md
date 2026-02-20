# rvim — Architecture

> Technical design of the rvim editor: crate layout, data flow, dependency
> stack, and key design decisions.

---

## 1. High-Level Architecture

rvim follows a **layered architecture** with clear separation of concerns.
Lower layers are UI-agnostic and purely functional; upper layers are
imperative and terminal-specific.

```
┌─────────────────────────────────────────────────────┐
│                    rvim-term                         │
│          (Application, Event Loop, UI)              │
├──────────────┬──────────────┬───────────────────────┤
│  rvim-picker │  rvim-git    │   UI Components       │
│  (fuzzy find)│  (git ops)   │   (editor, popup,     │
│              │              │    prompt, menu, ...)  │
├──────────────┴──────────────┴───────────────────────┤
│                   rvim-view                          │
│     (Editor, Document, View, Tree, Theme)           │
├──────────────┬──────────────┬───────────────────────┤
│  rvim-lsp    │  rvim-dap    │   rvim-syntax         │
│  (LSP client)│  (DAP client)│   (Tree-sitter)       │
├──────────────┴──────────────┴───────────────────────┤
│                   rvim-core                          │
│  (Rope, Selection, Transaction, Vim Grammar,        │
│   Motions, Operators, Text Objects, Registers)      │
├─────────────────────────────────────────────────────┤
│                   rvim-tui                           │
│     (Terminal backend, Surface, Layout, Widgets)    │
└─────────────────────────────────────────────────────┘
```

**Dependency direction is strictly downward.** `rvim-core` and `rvim-tui`
depend on nothing internal. `rvim-view` depends on `rvim-core` and
`rvim-syntax`. `rvim-term` depends on everything.

---

## 2. Crate Workspace

```toml
# Cargo.toml (workspace root)
[workspace]
resolver = "2"
members = [
    "rvim-core",
    "rvim-syntax",
    "rvim-lsp",
    "rvim-dap",
    "rvim-view",
    "rvim-tui",
    "rvim-picker",
    "rvim-git",
    "rvim-term",
]
```

### 2.1 rvim-core — Editing Primitives

The functional heart of the editor. No I/O, no UI, no async. Pure data
transformations that are easy to test.

```
rvim-core/src/
├── lib.rs
├── rope.rs              # Rope type alias + buffer abstraction over ropey
├── selection.rs         # Selection (Vec<Range>), Range (anchor + head)
├── transaction.rs       # ChangeSet (insertions/deletions), Transaction
├── history.rs           # Undo tree with branching (not linear stack)
├── register.rs          # Named registers: ", +, *, 0-9, a-z, /
├── vim/
│   ├── mod.rs           # Vim grammar parser + state machine
│   ├── operator.rs      # d, c, y, >, <, gq, gu, gU, !, =
│   ├── motion.rs        # h,j,k,l, w,b,e, f,t, 0,$, gg,G, /,?, etc.
│   ├── text_object.rs   # iw, aw, i(, a", is, ip, it, + TS objects
│   ├── count.rs         # Numeric count accumulator
│   └── mode.rs          # Mode enum: Normal, Insert, Visual, etc.
├── search.rs            # Regex search, match navigation
├── indent.rs            # Indentation detection and computation
├── line_ending.rs       # LF / CRLF detection and normalization
├── chars.rs             # Character classification (word, whitespace, punct)
├── match_brackets.rs    # Bracket pair matching
├── surround.rs          # Surround operations: add, change, delete
├── comment.rs           # Line/block comment toggle
├── word.rs              # Word boundary detection (vim word vs WORD)
├── position.rs          # Line/column ↔ byte offset conversions
└── graphemes.rs         # Grapheme cluster iteration + width
```

**Key types:**

| Type | Role |
|------|------|
| `Rope` | Text buffer. Re-export of `ropey::Rope` with helper methods |
| `Selection` | Ordered set of `Range`s. Every document has one per view |
| `Range` | `{ anchor: usize, head: usize }`. Single cursor = anchor == head |
| `ChangeSet` | Sequence of Retain/Insert/Delete ops describing a text edit |
| `Transaction` | `ChangeSet` + optional `Selection` mapping. Atomic edit unit |
| `History` | Tree of `Transaction` snapshots. Supports undo branches |
| `VimState` | State machine tracking current mode, pending operator, count |
| `Operator` | Enum of composable operators (delete, change, yank, ...) |
| `Motion` | Enum of cursor movements that produce a `Range` |
| `TextObject` | Enum of text objects that produce a `Range` around cursor |

**External dependencies:** `ropey`, `regex`, `unicode-segmentation`,
`unicode-width`, `smartstring`.

### 2.2 rvim-syntax — Tree-sitter Integration

Handles incremental parsing, syntax highlighting, indent computation, and
Tree-sitter-powered text objects.

```
rvim-syntax/src/
├── lib.rs
├── syntax.rs            # Syntax struct: wraps tree-sitter Parser + Tree
├── highlight.rs         # HighlightConfiguration, HighlightEvent iterator
├── indent.rs            # Indent queries (@indent, @dedent, @align)
├── textobject.rs        # @function.inner, @class.outer, @parameter.inner
├── injections.rs        # Language injections (markdown fenced blocks, etc.)
├── folding.rs           # Fold ranges from @fold captures
├── grammar.rs           # Grammar fetching, compilation, dynamic loading
└── query.rs             # Query file loading from runtime/queries/<lang>/
```

**Key design:**
- `Syntax` wraps a `tree_sitter::Parser` and the current `Tree`
- On every edit, `Syntax::update()` is called with the `Transaction` to
  perform an incremental re-parse (typically <1ms)
- Highlight queries map tree-sitter captures (`@keyword`, `@function`, etc.)
  to theme scope names
- Text object queries allow motions like `vaf` (select around function) using
  `@function.outer` captures

**External dependencies:** `tree-sitter` (official Rust bindings), compiled
grammar `.so` files in `runtime/grammars/`.

### 2.3 rvim-lsp — Language Server Protocol Client

Manages communication with external language servers over JSON-RPC.

```
rvim-lsp/src/
├── lib.rs
├── client.rs            # LspClient: per-server connection manager
├── transport.rs         # Framed JSON-RPC reader/writer over stdio/TCP
├── registry.rs          # Client registry: language → Vec<LspClient>
├── request.rs           # Outgoing request helpers with response futures
├── notification.rs      # Incoming notification handlers
├── types.rs             # Re-export / extension of lsp-types
├── capabilities.rs      # Server capability negotiation
└── util.rs              # Position/range conversions (LSP ↔ rvim-core)
```

**Protocol flow:**
```
rvim-term                    rvim-lsp                    Language Server
    │                            │                            │
    │── completion request ──►   │── textDocument/completion ──►│
    │                            │◄── completion response ──── │
    │◄── CompletionItems ──────  │                            │
    │                            │                            │
    │                            │◄── textDocument/publish ── │
    │◄── Diagnostics ────────── │     Diagnostics             │
```

**External dependencies:** `lsp-types`, `serde_json`, `tokio` (async I/O,
process spawning, channels).

### 2.4 rvim-dap — Debug Adapter Protocol Client

Manages communication with debug adapters for debugging support.

```
rvim-dap/src/
├── lib.rs
├── client.rs            # DapClient: per-adapter connection
├── transport.rs         # DAP message framing (Content-Length headers)
├── types.rs             # DAP type definitions (events, requests, responses)
├── breakpoint.rs        # Breakpoint state management
├── thread.rs            # Thread, stack frame, scope tracking
└── variables.rs         # Variable inspection and watch expressions
```

**Key design:**
- DAP uses the same Content-Length framed JSON transport as LSP
- Adapter configurations live in `languages.toml` under `[debugger]` sections
- Breakpoints are stored per-document and shown in the gutter
- When a session is active, a debug panel shows threads, stack, variables

**External dependencies:** `serde`, `serde_json`, `tokio`.

### 2.5 rvim-view — Editor State Layer

The imperative shell that ties together documents, views, and editor state.
This is where "the editor" lives as a concept, but without terminal specifics.

```
rvim-view/src/
├── lib.rs
├── editor.rs            # Editor: global state container
├── document.rs          # Document: Rope + Selection(s) + Syntax + History
├── view.rs              # View: viewport into a document (scroll, gutter)
├── tree.rs              # Tree: binary split tree of Views
├── gutter.rs            # Gutter rendering data (line numbers, signs, etc.)
├── theme.rs             # Theme: scope → Style mapping, TOML loader
├── info.rs              # Info/which-key popup data
├── input.rs             # KeyEvent, key parsing ("C-a", "S-Tab", etc.)
├── annotations/
│   ├── diagnostics.rs   # Inline diagnostic annotations
│   └── inlay_hints.rs   # LSP inlay hint annotations
└── handlers/
    ├── completion.rs    # Completion trigger logic and state
    └── signature.rs     # Signature help trigger logic
```

**Key types:**

| Type | Role |
|------|------|
| `Editor` | Owns all `Document`s, the `Tree` of views, config, LSP registry, theme, jobs queue |
| `Document` | One open file. Owns `Rope`, `History`, per-view `Selection`s, `Syntax`, language server refs |
| `View` | One visible pane. Holds document ID, scroll offset, gutter config |
| `Tree` | Binary tree of `View`s representing the split layout |
| `Theme` | Maps highlight scope names to `Style` (fg, bg, modifiers) |

**External dependencies:** `rvim-core`, `rvim-syntax`, `rvim-lsp`, `rvim-dap`.

### 2.6 rvim-tui — Terminal Rendering

Low-level terminal abstraction. Forked/inspired by `tui-rs`/`ratatui` but
tailored for editor needs.

```
rvim-tui/src/
├── lib.rs
├── backend/
│   ├── mod.rs           # Backend trait
│   └── crossterm.rs     # Crossterm implementation
├── buffer.rs            # Cell grid (char + style per cell)
├── surface.rs           # Double-buffered surface with diff-based flushing
├── layout.rs            # Rect, constraint-based layout computation
├── style.rs             # Color (RGB, indexed, named), Modifier, Style
├── text.rs              # Span, Line, Text — styled text building blocks
└── widgets/
    ├── mod.rs           # Widget trait
    ├── block.rs         # Bordered block with title
    ├── paragraph.rs     # Multi-line text rendering
    ├── list.rs          # Selectable list
    ├── table.rs         # Column-aligned table
    └── scrollbar.rs     # Scrollbar indicator
```

**Key design:**
- `Surface` is a 2D grid of `Cell { symbol: String, style: Style }`
- Double-buffered: on each frame, components render to `Surface`, then
  `Surface::diff()` computes the minimal set of terminal commands to update
  from the previous frame
- This keeps flicker to zero and minimizes I/O over slow connections (SSH)

**External dependencies:** `crossterm`.

### 2.7 rvim-picker — Fuzzy Finder

Built-in telescope-like fuzzy picker with preview.

```
rvim-picker/src/
├── lib.rs
├── picker.rs            # Core Picker<T> — generic over item type
├── matcher.rs           # Fuzzy matching integration (nucleo)
├── source/
│   ├── file.rs          # File picker (ignore-aware directory walk)
│   ├── grep.rs          # Live grep (streaming results)
│   ├── buffer.rs        # Open buffer picker
│   ├── symbol.rs        # LSP document/workspace symbols
│   ├── diagnostic.rs    # Diagnostic list
│   ├── command.rs       # Command palette
│   └── help.rs          # Help tag picker
├── preview.rs           # Syntax-highlighted file preview
└── injector.rs          # Async item injection (streaming results in)
```

**Key design:**
- `Picker<T>` is generic: any source provides `Vec<T>` or a streaming
  `Injector<T>`, the picker handles fuzzy matching, rendering, and selection
- `nucleo` crate handles matching (same as Helix — extremely fast, streaming)
- Preview pane renders the selected item with syntax highlighting
- Results stream in asynchronously so the UI stays responsive during grep

**External dependencies:** `nucleo`, `ignore`, `rvim-syntax` (for preview
highlighting).

### 2.8 rvim-git — Git Integration

Pure-Rust git operations for gutter signs, blame, and status.

```
rvim-git/src/
├── lib.rs
├── diff.rs              # Line-level diff for gutter signs (add/change/delete)
├── blame.rs             # Line-by-line git blame
├── status.rs            # Working tree status (modified, staged, untracked)
├── hunk.rs              # Hunk navigation and staging
├── log.rs               # Commit log with diff
└── provider.rs          # Async diff provider (background updates)
```

**External dependencies:** `gix` (gitoxide — pure-Rust Git implementation).

### 2.9 rvim-term — Application Binary

The top-level crate that assembles everything into a running editor.

```
rvim-term/src/
├── main.rs              # Entry point: CLI args, tokio runtime, Application
├── application.rs       # Event loop: terminal events, LSP events, jobs, render
├── compositor.rs        # Component stack: push/pop layers, event routing
├── commands.rs          # All command implementations (500+ functions)
├── commands/
│   ├── movement.rs      # Cursor movement commands
│   ├── edit.rs          # Insert, delete, change, yank, paste
│   ├── search.rs        # /, ?, *, #, :substitute
│   ├── lsp.rs           # LSP-related commands
│   ├── dap.rs           # DAP-related commands
│   ├── typed.rs         # : commands (:w, :q, :e, :set, etc.)
│   └── shell.rs         # Shell / pipe commands
├── keymap/
│   ├── mod.rs           # KeyTrie, Keymaps, KeymapResult
│   └── default.rs       # Default Vim keybindings
├── ui/
│   ├── editor.rs        # Main editor view (text, gutter, statusline)
│   ├── picker.rs        # Picker UI component
│   ├── prompt.rs        # Command-line (: / ? prompts)
│   ├── popup.rs         # Floating windows (hover, signature)
│   ├── menu.rs          # Completion menu
│   ├── terminal.rs      # Built-in terminal emulator
│   ├── which_key.rs     # Key hint popup (after leader / prefix keys)
│   ├── diagnostics.rs   # Diagnostics panel (trouble-like)
│   ├── git_status.rs    # Git status panel
│   └── explorer.rs      # File explorer tree
├── config.rs            # Config loading and merging
└── jobs.rs              # Background job queue
```

---

## 3. Core Data Flow

### 3.1 Keypress → Screen Update Pipeline

```
Terminal Event (crossterm)
    │
    ▼
Application::handle_terminal_events()
    │
    ▼
Compositor::handle_event()
    │ routes to top Component on the stack
    ▼
EditorView::handle_event()
    │
    ├── on_next_key_callback? → invoke callback, done
    │
    ├── Insert mode? → insert char or lookup insert keymap
    │
    └── Normal/Visual mode:
        │
        ▼
    VimGrammar::feed_key(key)
        │
        ├── Accumulating count? → store digit, wait
        ├── Pending register? → store register, wait
        ├── Pending operator? → now expecting motion/text-object
        │   │
        │   ├── Got motion → compute Range, apply operator
        │   └── Got text-object → compute Range, apply operator
        │
        ├── Standalone motion? → move cursor
        │
        └── KeyTrie lookup (g, z, [, ] prefixes)
            │
            ├── Pending → show which-key, wait for next key
            ├── Matched → execute MappableCommand
            └── NotFound → ignore
                │
                ▼
        Command::execute(Context)
            │
            ▼
        Transaction::new(changeset, selection)
            │
            ▼
        Document::apply(transaction)
            │ updates Rope, pushes to History, remaps Selections
            ▼
        Syntax::update(transaction)
            │ incremental tree-sitter re-parse
            ▼
        Render cycle
            │ components render to Surface
            │ Surface::diff() → minimal terminal writes
            ▼
        Terminal output
```

### 3.2 Document Modification (Transaction Model)

Inspired by CodeMirror 6's operational transformation model (same as Helix):

```rust
// A Transaction describes an atomic edit
struct Transaction {
    changes: ChangeSet,             // What text changed
    selection: Option<Selection>,   // Where cursors end up
}

// A ChangeSet is a sequence of operations
enum Operation {
    Retain(usize),                  // Keep N characters unchanged
    Delete(usize),                  // Delete N characters
    Insert(Tendril),                // Insert text
}

// Applying a transaction:
// 1. Apply ChangeSet to Rope → new Rope
// 2. Map all Selections through ChangeSet → adjusted positions
// 3. Push Transaction to History (for undo)
// 4. Notify Syntax of the edit ranges (for incremental re-parse)
// 5. Notify LSP of the edit (textDocument/didChange)
```

### 3.3 Async Event Sources

The main event loop multiplexes these sources via `tokio::select!`:

```
tokio::select! {
    // 1. Terminal input (keyboard, mouse, resize)
    event = terminal_events.next() => { ... }

    // 2. LSP responses and notifications
    msg = lsp_rx.recv() => { ... }

    // 3. DAP events
    msg = dap_rx.recv() => { ... }

    // 4. Background job completions (git diff, grammar fetch, etc.)
    result = jobs.next() => { ... }

    // 5. Timers (debounced saves, completion delay, etc.)
    _ = debounce_timer.tick() => { ... }
}
```

---

## 4. Dependency Stack

### 4.1 Core Dependencies

| Crate | Version | Purpose | Used By |
|-------|---------|---------|---------|
| `ropey` | 1.x | Rope data structure (text buffer) | rvim-core |
| `regex` | 1.x | Regular expressions for search | rvim-core |
| `unicode-segmentation` | 1.x | Grapheme cluster boundaries | rvim-core |
| `unicode-width` | 0.2.x | Display width calculation | rvim-core |
| `smartstring` | 1.x | Small-string optimization | rvim-core |
| `tree-sitter` | 0.24.x | Incremental parser (Rust bindings) | rvim-syntax |
| `lsp-types` | 0.97.x | LSP type definitions | rvim-lsp |
| `serde` | 1.x | Serialization framework | All crates |
| `serde_json` | 1.x | JSON for LSP/DAP transport | rvim-lsp, rvim-dap |
| `toml` | 0.8.x | Config file parsing | rvim-view, rvim-term |
| `tokio` | 1.x | Async runtime | rvim-lsp, rvim-dap, rvim-term |
| `crossterm` | 0.28.x | Terminal I/O | rvim-tui |
| `nucleo` | 0.5.x | Fuzzy matching engine | rvim-picker |
| `ignore` | 0.4.x | .gitignore-aware file walking | rvim-picker |
| `gix` | 0.68.x | Pure-Rust Git operations | rvim-git |
| `log` / `tracing` | — | Structured logging | All crates |
| `once_cell` | 1.x | Lazy statics | Various |
| `thiserror` / `anyhow` | — | Error handling | Various |

### 4.2 Dependency Rules

1. **rvim-core** has zero async dependencies. No `tokio`, no I/O. Pure logic.
2. **rvim-tui** depends only on `crossterm`. No editor logic.
3. **rvim-syntax** depends on `rvim-core` (for Rope type) and `tree-sitter`.
4. **rvim-lsp** and **rvim-dap** depend on `tokio` for async I/O, and
   `rvim-core` for position types.
5. **rvim-view** is the integration layer: depends on core, syntax, lsp, dap.
6. **rvim-term** depends on everything and is the only binary crate.

```
rvim-term
├── rvim-view
│   ├── rvim-core
│   ├── rvim-syntax ── rvim-core
│   ├── rvim-lsp ──── rvim-core
│   └── rvim-dap ──── rvim-core
├── rvim-tui
├── rvim-picker ───── rvim-core, rvim-syntax
└── rvim-git
```

---

## 5. Key Design Decisions

### 5.1 Why Ropey (Not Crop, Not Gap Buffer)

| Factor | Ropey | Crop | Gap Buffer |
|--------|-------|------|------------|
| Maturity | Battle-tested (Helix) | Newer | Simplest |
| Clone cost | O(1) (cheap snapshots) | O(1) | O(n) |
| Edit perf | O(log n) | O(log n) | O(1) amortized |
| Large files | Excellent | Excellent | Degrades |
| Undo snapshots | Cheap clone = easy | Cheap clone = easy | Must copy |
| Ecosystem | Widely used | Less adoption | N/A |

**Decision:** `ropey`. The cheap clone enables trivial undo snapshots, and
it's proven at scale in Helix. If profiling later shows bottlenecks, `crop`
is a drop-in alternative.

### 5.2 Why Custom TUI (Not Ratatui Directly)

Editors need rendering control that general-purpose TUI frameworks don't
optimize for:
- Cell-level styling (each character may have a unique highlight)
- Gutter rendering interleaved with text
- Cursor-precise positioning across Unicode grapheme clusters
- Minimal diff-based terminal writes for SSH performance

We build a thin TUI layer inspired by ratatui/tui-rs, taking the
`Surface`/`Buffer`/`Widget` concepts but stripping everything else.

### 5.3 Why Undo Tree (Not Linear Undo Stack)

Vim's undo model is a **tree**, not a stack. If you:
1. Type "hello"
2. Undo
3. Type "world"

A linear stack loses "hello" forever. An undo tree preserves both branches,
navigable with `g-` / `g+` (by timestamp) or `:earlier` / `:later`.

```
        ┌── "world" (current)
root ───┤
        └── "hello" (still accessible via g-)
```

### 5.4 Why Not Embed Neovim

Embedding Neovim's C core or using its RPC API would provide instant
compatibility but defeats the purpose:
- Brings C's safety issues along
- Neovim's architecture isn't designed for embedding as a library
- Plugin ecosystem dependency would make "batteries-included" impossible
- Can't optimize the data flow end-to-end

### 5.5 Configuration Format: TOML

```
~/.config/rvim/
├── config.toml            # Editor settings, keybindings
├── languages.toml         # Language server + formatter + debugger config
└── themes/                # Custom themes (optional)
    └── mytheme.toml

.rvim/                     # Project-local overrides (in workspace root)
├── config.toml
└── languages.toml
```

Merge order: built-in defaults → user config → project config.

---

## 6. Runtime Assets

```
runtime/
├── queries/               # Tree-sitter query files
│   ├── rust/
│   │   ├── highlights.scm
│   │   ├── indents.scm
│   │   ├── textobjects.scm
│   │   ├── injections.scm
│   │   └── folds.scm
│   ├── python/
│   ├── javascript/
│   ├── typescript/
│   ├── go/
│   ├── c/
│   ├── cpp/
│   └── ... (100+ languages)
│
├── themes/
│   ├── onedark.toml
│   ├── catppuccin_mocha.toml
│   ├── gruvbox_dark.toml
│   ├── tokyonight.toml
│   ├── rose_pine.toml
│   ├── kanagawa.toml
│   ├── nord.toml
│   ├── dracula.toml
│   ├── solarized_dark.toml
│   └── default.toml
│
├── grammars/              # Compiled tree-sitter grammars (.so / .dylib)
│   ├── rust.so
│   ├── python.so
│   └── ...
│
└── languages.toml         # Default language configurations
```

Grammars can be:
1. **Pre-compiled** and bundled with release builds
2. **Fetched and compiled** on first run (`rvim --grammar fetch && rvim --grammar build`)
3. **Embedded** in the binary via `include_bytes!` for a true single-binary distribution

---

## 7. Threading Model

```
┌─────────────────────────────────────────────┐
│              Main Thread (tokio)             │
│  ┌────────────────────────────────────────┐  │
│  │  Event Loop (select!)                  │  │
│  │  ├── Terminal I/O                      │  │
│  │  ├── Render cycle                      │  │
│  │  ├── LSP message dispatch              │  │
│  │  ├── DAP message dispatch              │  │
│  │  └── Timer ticks                       │  │
│  └────────────────────────────────────────┘  │
├─────────────────────────────────────────────┤
│            Tokio Thread Pool                 │
│  ┌──────────┐ ┌──────────┐ ┌─────────────┐  │
│  │ LSP I/O  │ │ DAP I/O  │ │ Background  │  │
│  │ (per     │ │ (per     │ │ Jobs:       │  │
│  │  server) │ │  adapter) │ │ - git diff  │  │
│  │          │ │          │ │ - file walk  │  │
│  │          │ │          │ │ - grep       │  │
│  │          │ │          │ │ - grammar    │  │
│  │          │ │          │ │   compile    │  │
│  └──────────┘ └──────────┘ └─────────────┘  │
└─────────────────────────────────────────────┘
```

- **Rendering is always on the main thread** — no concurrent access to
  `Surface` or terminal state
- LSP and DAP each run their transport I/O on tokio tasks, communicating
  with the main loop via channels
- CPU-heavy work (grep, file walking, grammar compilation) runs on the
  tokio blocking pool or `rayon` for parallelism
- The main loop never blocks: if an operation would take >1ms, it goes async
