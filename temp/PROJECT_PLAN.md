# rvim — Project Plan

> A Neovim-inspired terminal text editor built from scratch in Rust.
> Batteries-included. Vim-native. Blazingly fast.

---

## 1. Vision

**rvim** is a terminal-based modal text editor that brings the full power of
Neovim's editing model — composable operators, motions, and text objects — into
a single, self-contained Rust binary with batteries included.

Where Helix chose Kakoune's selection-first model, and Zed/Lapce target GUI
experiences, rvim occupies the gap: a **Neovim-compatible Vim grammar** in a
modern Rust editor with the features Neovim users currently assemble from 30+
plugins built natively into the editor.

Think of it as: *"What if Neovim were rewritten today in Rust, with everything
you need out of the box?"*

---

## 2. Goals

1. **True Vim grammar** — `[count][register][operator][count][motion|text-object]`
   composability as a first-class citizen, not a compatibility layer bolted on.

2. **Zero-config productivity** — Open rvim on any project and immediately have
   syntax highlighting, LSP intelligence, git integration, fuzzy finding, and
   debugging. No plugin manager, no configuration ritual.

3. **Snappy at all scales** — Sub-millisecond keypress-to-render latency. Handle
   gigabyte files and pathological inputs (single million-character lines)
   without flinching. Rope-based buffer, incremental parsing, async I/O.

4. **Neovim-familiar UX** — A Neovim user should feel at home immediately.
   Same keybindings, same `:` commands, same `/` search, same `g` and `z`
   prefixes, same register and macro system. Muscle memory transfers 1:1.

5. **Rich built-in features** — Fuzzy picker, git gutter/blame/status,
   diagnostics panel, surround/comment operators, which-key hints, auto-pairs,
   built-in terminal, indent guides — all native.

6. **Beautiful by default** — Ship with carefully crafted colorschemes
   (onedark, catppuccin, gruvbox, tokyonight, etc.) and a flexible theming
   engine. True-color, undercurl, bold/italic — out of the box.

7. **Single binary distribution** — One `rvim` binary. Runtime assets
   (grammars, themes, queries) either embedded or fetched on first run.
   Minimal external dependencies.

---

## 3. Non-Goals (at least initially)

- **GUI frontend** — rvim is terminal-first. No GPU rendering, no Electron, no
  native window toolkit. The terminal is the UI.

- **Full Neovim API compatibility** — We are *inspired by* Neovim, not a
  drop-in replacement. Vimscript and Neovim's RPC API are out of scope.

- **Lua scripting (initially)** — Extensibility will come later, likely via
  WASM plugins rather than embedding a Lua runtime. The goal is to make the
  built-in features good enough that most users don't *need* plugins.

- **Remote editing (initially)** — SSH-based remote development is a future
  consideration, not a launch feature.

- **Backward compatibility with Vim quirks** — We implement Vim's *useful*
  behaviors. Obscure corner cases, ex-mode, and historical baggage are
  intentionally omitted.

---

## 4. Competitive Differentiation

### vs. Neovim

| Aspect | Neovim | rvim |
|--------|--------|------|
| Language | C + Lua | Rust |
| Memory safety | Manual | Guaranteed |
| Features | Via plugins | Built-in |
| Startup | ~50ms + plugin load | Target <20ms |
| Configuration | Lua/Vimscript required | Works out of the box |
| Distribution | Multiple files + runtime | Single binary |

### vs. Helix

| Aspect | Helix | rvim |
|--------|-------|------|
| Editing model | Kakoune (select-then-act) | Vim (act-then-target) |
| Key grammar | `motion → operator` | `operator → motion` |
| Vim compatibility | None — intentionally different | Full Vim grammar |
| Plugin system | None (WIP) | Future WASM |
| Fuzzy finder | Built-in | Built-in |
| DAP | Experimental | First-class |
| Git | Gutter diff only | Full: gutter, blame, status, log |

### vs. Zed / Lapce

| Aspect | Zed / Lapce | rvim |
|--------|------------|------|
| UI | GPU-rendered GUI | Terminal |
| Vim mode | Add-on / toggle | Native, primary |
| Vim grammar depth | Surface level | Full composability |
| Resource usage | ~200-500MB RAM | Target <50MB |
| Platform | macOS-focused (Zed) | Anywhere with a terminal |

---

## 5. Target Users

1. **Neovim power users** tired of maintaining 50+ plugins and `init.lua`
   configs that break on update.

2. **Vim users** who want modern features (LSP, tree-sitter, fuzzy finding)
   without leaving the Vim editing model.

3. **Terminal-centric developers** who live in tmux/ssh and need a fast,
   capable editor that works over any connection.

4. **Helix-curious Vim users** who love Helix's batteries-included philosophy
   but can't rewire their Vim muscle memory.

---

## 6. Success Criteria

### v0.1 — "It Edits" (Phase 1 complete)
- [ ] Open, edit, and save files with basic Vim motions and operators
- [ ] Normal, Insert, Visual modes working
- [ ] Undo/redo
- [ ] Multiple buffers with `:bnext`/`:bprev`
- [ ] Syntax highlighting via Tree-sitter for 5+ languages

### v0.5 — "Daily Driver Candidate" (Phase 1-3 complete)
- [ ] Full Vim motion/operator/text-object grammar
- [ ] LSP: completion, diagnostics, go-to-definition, hover, rename
- [ ] Fuzzy picker for files, grep, buffers, symbols
- [ ] Split windows
- [ ] Search and replace with regex
- [ ] Registers and macros
- [ ] 3+ colorschemes shipping

### v1.0 — "Neovim Replacement" (All phases)
- [ ] DAP debugging
- [ ] Git integration (gutter, blame, status, log)
- [ ] Built-in terminal
- [ ] Surround and comment operators
- [ ] Which-key, auto-pairs, indent guides
- [ ] User configuration (config.toml, languages.toml)
- [ ] Keybinding customization
- [ ] 10+ colorschemes
- [ ] Stable, documented, and community-tested

---

## 7. Document Index

| Document | Purpose |
|----------|---------|
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Crate structure, data flow, dependency stack |
| [VIM_GRAMMAR.md](./VIM_GRAMMAR.md) | Operator/motion/text-object engine design |
| [FEATURES.md](./FEATURES.md) | Built-in features and Neovim plugin equivalents |
| [ROADMAP.md](./ROADMAP.md) | Phased development plan with milestones |
