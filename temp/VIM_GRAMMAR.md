# rvim — Vim Grammar Engine

> Design specification for rvim's composable Vim command parser — the
> operator/motion/text-object engine that is the editor's core differentiator.

---

## 1. Overview

Vim's editing language is a **composable grammar**:

```
[count] [register] operator [count] motion
[count] [register] operator [count] text-object
[count]            motion
```

This grammar is what makes Vim users productive: once you learn `d` (delete)
and `w` (word), you *automatically* know `dw` (delete word). Learn `c`
(change) and you already know `cw`. Learn `i(` (inside parens) and you know
`di(`, `ci(`, `yi(`, `>i(`, etc. — a combinatorial explosion of commands
from a small set of primitives.

**This composability is rvim's defining feature.** Helix intentionally chose
Kakoune's selection-first model (`w` selects a word, then `d` deletes the
selection). rvim implements Vim's original `d` → `w` order.

---

## 2. The Vim Command Grammar

### 2.1 Formal Grammar

```
command     ::= [count] [register] action
action      ::= operator [count] target
              | motion
              | standalone

target      ::= motion
              | text-object

count       ::= [1-9] [0-9]*
register    ::= '"' register-name
operator    ::= 'd' | 'c' | 'y' | '>' | '<' | 'g~' | 'gu' | 'gU'
              | 'gq' | 'g@' | '!' | '=' | 'zf'
motion      ::= (see Section 4)
text-object ::= ('i' | 'a') object-type
standalone  ::= 'x' | 'X' | 'p' | 'P' | 'J' | '~' | 'u' | 'C-r'
              | 'dd' | 'cc' | 'yy' | '>>' | '<<' | ...
```

**Example parses:**

| Input | Count | Register | Operator | Count2 | Target | Meaning |
|-------|-------|----------|----------|--------|--------|---------|
| `dw` | — | — | delete | — | word-fwd | Delete to next word |
| `3dw` | 3 | — | delete | — | word-fwd | Delete to next word, 3 times |
| `d3w` | — | — | delete | 3 | word-fwd | Delete 3 words forward |
| `"adiw` | — | a | delete | — | inner-word | Delete inner word into reg a |
| `2"ay3w` | 2 | a | yank | 3 | word-fwd | Yank 6 words into reg a |
| `gUiw` | — | — | uppercase | — | inner-word | Uppercase inner word |
| `>ip` | — | — | indent | — | inner-para | Indent inner paragraph |
| `dd` | — | — | delete | — | (linewise) | Delete current line |
| `5j` | 5 | — | — | — | down | Move 5 lines down |
| `f(` | — | — | — | — | find `(` | Move to next `(` |
| `ct"` | — | — | change | — | till `"` | Change up to (not including) `"` |

---

## 3. State Machine

The Vim grammar is parsed by a **state machine** that accumulates context
across keystrokes:

```rust
/// The Vim grammar parser / state machine.
///
/// Fed one key at a time via `feed_key()`. Transitions between states
/// and emits `VimAction`s when a complete command is recognized.
pub struct VimGrammar {
    state: VimParseState,
    count1: Option<usize>,          // First count prefix
    count2: Option<usize>,          // Count between operator and motion
    register: Option<char>,         // Target register
    operator: Option<Operator>,     // Pending operator
    last_command: Option<ReplayableCommand>,  // For dot-repeat
}
```

### 3.1 State Transitions

```
                           ┌─────────────┐
                    ┌─────►│   Ground     │◄────────────────────┐
                    │      │ (idle/ready) │                     │
                    │      └──────┬───────┘                     │
                    │             │                              │
                    │    ┌────────┼──────────┐                  │
                    │    │        │          │                   │
                    │    ▼        ▼          ▼                   │
                    │ digit    '"'      operator                │
                    │    │        │      (d,c,y,>...)            │
                    │    ▼        ▼          │                   │
                    │ ┌──────┐ ┌──────┐     │                   │
                    │ │Count1│ │RegWait│     │                   │
                    │ └──┬───┘ └──┬───┘     │                   │
                    │    │        │          │                   │
                    │    │  ┌─────┘          │                   │
                    │    ▼  ▼                ▼                   │
                    │ (continue to     ┌──────────┐             │
                    │  next state)     │ OpPending │             │
                    │                  └─────┬────┘             │
                    │                        │                  │
                    │             ┌──────────┼────────┐         │
                    │             │          │        │         │
                    │             ▼          ▼        ▼         │
                    │          motion    text-obj   same-op     │
                    │             │          │     (dd,cc,yy)   │
                    │             │          │        │         │
                    │             ▼          ▼        ▼         │
                    │        ┌────────────────────────────┐     │
                    └────────│      Execute Action         │────┘
                             │  (compute range, apply op)  │
                             └─────────────────────────────┘
```

### 3.2 Parse States

```rust
enum VimParseState {
    /// Ready for input. No pending state.
    Ground,

    /// Accumulating first count prefix (e.g., "3" in "3dw").
    AccumulatingCount1,

    /// Waiting for register name after '"'.
    WaitingForRegister,

    /// Accumulating count between register and operator.
    /// e.g., after "a in "3"a — still accumulating count
    AccumulatingCountPostRegister,

    /// Operator received, waiting for motion or text-object.
    /// Also accumulates optional second count (e.g., "d3w").
    OperatorPending {
        accumulating_count2: bool,
    },

    /// Waiting for a character argument.
    /// Used by: f, F, t, T, r, m, ', `, @, q, z+char, g+char
    WaitingForChar {
        /// What to do with the character once received.
        action: CharWaitAction,
    },

    /// Inside a multi-key sequence (g_, z_, [_, ]_, etc.)
    /// Uses a KeyTrie for lookup.
    InKeyTrie {
        /// Reference to the trie node we're currently in.
        node_name: String,
    },
}
```

### 3.3 Feed Key Algorithm

```rust
impl VimGrammar {
    /// Process a single keypress. Returns the resulting action.
    pub fn feed_key(&mut self, key: KeyEvent, mode: Mode) -> VimResult {
        match self.state {
            Ground => {
                if key.is_digit() && key != '0' {
                    self.count1 = Some(key.to_digit());
                    self.state = AccumulatingCount1;
                    VimResult::Pending
                } else if key == '"' {
                    self.state = WaitingForRegister;
                    VimResult::Pending
                } else if let Some(op) = Operator::from_key(key) {
                    self.operator = Some(op);
                    self.state = OperatorPending { accumulating_count2: false };
                    VimResult::Pending
                } else if let Some(motion) = Motion::from_key(key) {
                    // Standalone motion (no operator)
                    self.reset();
                    VimResult::Motion(motion, self.effective_count())
                } else if is_key_trie_prefix(key) {
                    // g, z, [, ], leader, etc.
                    self.state = InKeyTrie { node_name: key.to_string() };
                    VimResult::Pending
                } else if let Some(standalone) = Standalone::from_key(key, mode) {
                    self.reset();
                    VimResult::Standalone(standalone, self.effective_count())
                } else {
                    self.reset();
                    VimResult::NotFound
                }
            },

            OperatorPending { accumulating_count2 } => {
                if key.is_digit() && (accumulating_count2 || key != '0') {
                    self.accumulate_count2(key.to_digit());
                    self.state = OperatorPending { accumulating_count2: true };
                    VimResult::Pending
                } else if let Some(motion) = Motion::from_key(key) {
                    let op = self.operator.take().unwrap();
                    let count = self.effective_count();
                    self.reset();
                    VimResult::OperatorMotion(op, motion, count)
                } else if key == 'i' || key == 'a' {
                    self.state = WaitingForTextObjectType {
                        inner: key == 'i'
                    };
                    VimResult::Pending
                } else if Operator::from_key(key) == self.operator {
                    // dd, cc, yy — linewise self-application
                    let op = self.operator.take().unwrap();
                    let count = self.effective_count();
                    self.reset();
                    VimResult::OperatorLine(op, count)
                } else {
                    self.reset();
                    VimResult::Cancelled
                }
            },

            // ... other states
        }
    }

    /// Effective count = count1 * count2 (both default to 1)
    fn effective_count(&self) -> usize {
        self.count1.unwrap_or(1) * self.count2.unwrap_or(1)
    }
}
```

---

## 4. Motions

Motions move the cursor and define ranges for operators. Each motion has a
**direction** and an **inclusivity**:

```rust
pub struct MotionResult {
    /// The range of text affected (from cursor to destination)
    pub range: Range,
    /// Whether the motion is characterwise, linewise, or blockwise
    pub kind: MotionKind,
}

pub enum MotionKind {
    Characterwise { inclusive: bool },
    Linewise,
    Blockwise,
}
```

### 4.1 Motion Catalog

#### Character Motions
| Key | Motion | Inclusive | Kind |
|-----|--------|-----------|------|
| `h` | Left | — | Characterwise |
| `l` | Right | — | Characterwise |
| `j` | Down | — | Linewise |
| `k` | Up | — | Linewise |

#### Word Motions
| Key | Motion | Inclusive | Kind |
|-----|--------|-----------|------|
| `w` | Next word start | No | Characterwise |
| `W` | Next WORD start | No | Characterwise |
| `e` | Next word end | Yes | Characterwise |
| `E` | Next WORD end | Yes | Characterwise |
| `b` | Prev word start | No | Characterwise |
| `B` | Prev WORD start | No | Characterwise |
| `ge` | Prev word end | Yes | Characterwise |
| `gE` | Prev WORD end | Yes | Characterwise |

#### Find Motions (require char argument)
| Key | Motion | Inclusive | Kind |
|-----|--------|-----------|------|
| `f{c}` | Find char forward | Yes | Characterwise |
| `F{c}` | Find char backward | Yes | Characterwise |
| `t{c}` | Till char forward | No | Characterwise |
| `T{c}` | Till char backward | No | Characterwise |
| `;` | Repeat last f/F/t/T | (same) | Characterwise |
| `,` | Reverse last f/F/t/T | (same) | Characterwise |

#### Line Motions
| Key | Motion | Kind |
|-----|--------|------|
| `0` | Line start (col 0) | Characterwise |
| `^` | First non-blank | Characterwise |
| `$` | Line end | Characterwise (inclusive) |
| `g_` | Last non-blank | Characterwise (inclusive) |
| `+` / `<CR>` | Next line first non-blank | Linewise |
| `-` | Prev line first non-blank | Linewise |

#### Vertical Motions
| Key | Motion | Kind |
|-----|--------|------|
| `gg` | Go to first line (or line N) | Linewise |
| `G` | Go to last line (or line N) | Linewise |
| `H` | Screen top | Linewise |
| `M` | Screen middle | Linewise |
| `L` | Screen bottom | Linewise |
| `{` | Previous blank line | Characterwise |
| `}` | Next blank line | Characterwise |
| `(` | Previous sentence | Characterwise |
| `)` | Next sentence | Characterwise |
| `%` | Matching bracket | Characterwise |

#### Search Motions
| Key | Motion | Kind |
|-----|--------|------|
| `/{pattern}` | Search forward | Characterwise |
| `?{pattern}` | Search backward | Characterwise |
| `n` | Repeat last search | Characterwise |
| `N` | Repeat last search (reverse) | Characterwise |
| `*` | Search word under cursor (fwd) | Characterwise |
| `#` | Search word under cursor (bwd) | Characterwise |

#### Marks
| Key | Motion | Kind |
|-----|--------|------|
| `` `{m} `` | Go to mark (exact position) | Characterwise |
| `'{m}` | Go to mark (first non-blank) | Linewise |

---

## 5. Operators

Operators act on ranges defined by motions or text objects:

```rust
pub enum Operator {
    Delete,         // d — delete and yank
    Change,         // c — delete, yank, enter insert mode
    Yank,           // y — copy to register
    Indent,         // > — shift right
    Dedent,         // < — shift left
    AutoIndent,     // = — auto-indent
    Format,         // gq — format (by textwidth or LSP)
    Uppercase,      // gU — convert to uppercase
    Lowercase,      // gu — convert to lowercase
    ToggleCase,     // g~ — toggle case
    Filter,         // ! — filter through external command
    Fold,           // zf — create fold
    Comment,        // gc — toggle comment (built-in, not vim-standard)
    Surround,       // ys — add surround (built-in, not vim-standard)
}
```

### 5.1 Operator Execution

```rust
/// Execute an operator on a computed range.
pub fn execute_operator(
    op: Operator,
    range: Range,
    kind: MotionKind,
    count: usize,
    register: Option<char>,
    doc: &mut Document,
    editor: &mut Editor,
) -> Transaction {
    // 1. Adjust range based on MotionKind
    let adjusted = match kind {
        MotionKind::Linewise => range.extend_to_full_lines(doc.rope()),
        MotionKind::Characterwise { inclusive: true } => range.extend_end_by(1),
        MotionKind::Characterwise { inclusive: false } => range,
        MotionKind::Blockwise => range, // handled specially
    };

    // 2. Extract text for register (if operator yanks)
    if op.yanks() {
        let text = doc.rope().slice(adjusted.start..adjusted.end);
        editor.registers.write(register.unwrap_or('"'), text, kind);
    }

    // 3. Build transaction
    match op {
        Operator::Delete => {
            Transaction::delete(doc.rope(), adjusted)
        }
        Operator::Change => {
            let tx = Transaction::delete(doc.rope(), adjusted);
            // Mode change to Insert is handled by the caller
            tx
        }
        Operator::Yank => {
            // Already yanked in step 2, no text change
            Transaction::identity(doc.rope())
        }
        Operator::Indent => {
            Transaction::indent_lines(doc.rope(), adjusted, count, doc.indent_unit())
        }
        Operator::Comment => {
            // Use tree-sitter to determine comment style
            Transaction::toggle_comment(doc.rope(), adjusted, doc.syntax())
        }
        // ...
    }
}
```

### 5.2 Linewise Self-Application (dd, cc, yy, >>, <<)

When an operator key is pressed twice (`dd`, `yy`, etc.), it applies to the
current line(s):

```rust
if key == operator_key {
    // "dd" = delete [count] lines
    let line = doc.cursor_line();
    let range = Range::new(
        doc.rope().line_to_char(line),
        doc.rope().line_to_char(line + count),
    );
    execute_operator(op, range, MotionKind::Linewise, 1, register, doc, editor)
}
```

---

## 6. Text Objects

Text objects define regions around the cursor. They come in two flavors:
- **Inner** (`i`): the content without delimiters
- **Around** (`a`): the content including delimiters and surrounding whitespace

```rust
pub enum TextObjectType {
    // Vim built-in
    Word,           // w — vim word
    BigWord,        // W — vim WORD
    Sentence,       // s
    Paragraph,      // p
    Pair(char),     // (, ), {, }, [, ], <, >, ", ', `
    Tag,            // t — XML/HTML tag
    BacktickBlock,  // ` — backtick pair

    // Tree-sitter powered (rvim extensions)
    Function,       // f — @function.inner / @function.outer
    Class,          // c — @class.inner / @class.outer
    Parameter,      // a — @parameter.inner / @parameter.outer
    Conditional,    // i — @conditional.inner / @conditional.outer (if/else)
    Loop,           // l — @loop.inner / @loop.outer
    Comment,        // / — @comment.inner / @comment.outer
    Block,          // b — @block.inner / @block.outer (generic scope)
    Call,           // m — @call.inner / @call.outer (function call)
}
```

### 6.1 Text Object Resolution

```rust
pub fn resolve_text_object(
    kind: InnerOrAround,  // 'i' or 'a'
    obj: TextObjectType,
    pos: usize,           // cursor position
    rope: &Rope,
    syntax: Option<&Syntax>,
    count: usize,
) -> Option<Range> {
    match obj {
        TextObjectType::Word => {
            // Find word boundaries around cursor
            let (start, end) = find_word_at(rope, pos);
            match kind {
                Inner => Some(Range::new(start, end)),
                Around => {
                    // Include trailing whitespace (or leading if at end)
                    let end = skip_whitespace_forward(rope, end);
                    Some(Range::new(start, end))
                }
            }
        }
        TextObjectType::Pair(open) => {
            let close = matching_bracket(open);
            let (start, end) = find_matching_pair(rope, pos, open, close, count)?;
            match kind {
                Inner => Some(Range::new(start + 1, end)),
                Around => Some(Range::new(start, end + 1)),
            }
        }
        TextObjectType::Function => {
            // Use tree-sitter @function.inner / @function.outer queries
            let query_name = match kind {
                Inner => "function.inner",
                Around => "function.outer",
            };
            syntax?.query_textobject(query_name, pos, count)
        }
        // ...
    }
}
```

### 6.2 Tree-sitter Text Object Queries

Text object queries are defined in `runtime/queries/<lang>/textobjects.scm`:

```scheme
;; runtime/queries/rust/textobjects.scm

;; Function
(function_item
  body: (block . "{" _ @function.inner "}" .)) @function.outer

;; Method
(function_item
  body: (block . "{" _ @function.inner "}" .)) @function.outer

;; Class (impl block in Rust)
(impl_item
  body: (declaration_list . "{" _ @class.inner "}" .)) @class.outer

;; Parameter
(parameters
  (parameter) @parameter.inner) @parameter.outer

;; Conditional
(if_expression
  consequence: (block . "{" _ @conditional.inner "}" .)) @conditional.outer

;; Loop
(loop_expression
  body: (block . "{" _ @loop.inner "}" .)) @loop.outer

(for_expression
  body: (block . "{" _ @loop.inner "}" .)) @loop.outer

;; Comment
(line_comment) @comment.inner @comment.outer
(block_comment) @comment.inner @comment.outer
```

---

## 7. Dot Repeat

The `.` command repeats the last change. This requires recording:

```rust
pub struct ReplayableCommand {
    /// The complete key sequence that made the change
    keys: Vec<KeyEvent>,
    /// Or, a structured representation:
    operator: Option<Operator>,
    motion_or_textobj: Option<Target>,
    count: usize,
    register: Option<char>,
    /// For insert mode: the text that was typed
    inserted_text: Option<String>,
}
```

**What counts as a "change" for dot repeat:**
- Any operator + target: `dw`, `ci"`, `>ip`
- Insert mode session: everything from `i`/`a`/`o`/... to `<Esc>`
- Standalone changes: `x`, `X`, `J`, `~`, `p`, `P`, `r{char}`

**What does NOT count:**
- Pure motions (moving cursor)
- Yanking (`y` — doesn't modify text)
- Undo/redo
- Search

---

## 8. Visual Mode Integration

Visual mode converts the Vim grammar:

```
Normal:   d + motion   →  delete range computed by motion
Visual:   (select)     →  d  →  delete visual selection
```

In visual mode:
1. Motions **extend the selection** rather than moving the cursor
2. When an operator is pressed, it applies to the **current visual selection**
   — no motion needed
3. The grammar simplifies to: `[register] operator` (the target is implicit)

```rust
// In visual mode, operator doesn't need a motion
VimParseState::Ground if mode.is_visual() => {
    if let Some(op) = Operator::from_key(key) {
        let range = doc.selection().primary();
        execute_operator(op, range, visual_motion_kind(mode), 1, register, doc, editor);
        // Return to normal mode
        VimResult::Standalone(Standalone::ExitVisual, 1)
    }
}
```

Visual sub-modes:

| Key | Mode | Selection behavior |
|-----|------|--------------------|
| `v` | Visual (charwise) | Character-by-character selection |
| `V` | Visual Line | Whole lines |
| `Ctrl-v` | Visual Block | Rectangular block |

---

## 9. Register System

```rust
pub struct Registers {
    named: HashMap<char, RegisterEntry>,
}

pub struct RegisterEntry {
    pub content: Vec<String>,   // Multiple lines for linewise
    pub kind: RegisterKind,     // Characterwise, Linewise, Blockwise
}

pub enum RegisterKind {
    Characterwise,
    Linewise,
    Blockwise,
}
```

### 9.1 Special Registers

| Register | Name | Behavior |
|----------|------|----------|
| `"` | Unnamed | Default for d, c, y, p. Always written. |
| `0` | Yank | Last yank (not delete). `y` writes here. |
| `1`-`9` | Delete history | Ring buffer. `d`/`c` shift into these. |
| `a`-`z` | Named | User-named storage. |
| `A`-`Z` | Named (append) | Append to corresponding lowercase register. |
| `+` | System clipboard | Uses OS clipboard (xclip / pbcopy / wl-copy). |
| `*` | Primary selection | X11 primary selection (Linux). |
| `/` | Search | Last search pattern. |
| `:` | Command | Last `:` command. |
| `.` | Insert | Last inserted text. |
| `%` | Filename | Current filename (read-only). |
| `#` | Alternate | Alternate filename (read-only). |
| `_` | Black hole | Discards text (no register write). |
| `=` | Expression | Evaluate expression (future). |

---

## 10. Macro System

```rust
pub struct MacroSystem {
    /// Currently recording? If Some, which register.
    recording: Option<char>,
    /// Keys accumulated during recording.
    buffer: Vec<KeyEvent>,
    /// Stored macros (register → key sequence).
    macros: HashMap<char, Vec<KeyEvent>>,
}
```

| Key | Action |
|-----|--------|
| `q{a-z}` | Start recording macro into register |
| `q` (while recording) | Stop recording |
| `@{a-z}` | Play macro from register |
| `@@` | Repeat last played macro |
| `5@a` | Play macro `a` five times |

**Guard against infinite recursion:** maintain a recursion depth counter,
abort if it exceeds a threshold (e.g., 1000).

---

## 11. Counts Interaction

Counts multiply:

```
3d2w  →  delete 6 words (3 × 2)
2yy   →  yank 2 lines
5j    →  move 5 lines down
```

The effective count is `count1 * count2`, where both default to 1 if absent.

Counts also interact with other features:
- `3p` — paste 3 times
- `5i-<Esc>` — insert "-" repeated 5 times
- `2.` — repeat last change 2 times (overrides the original count)

---

## 12. Implementation Priorities

### Phase 1 (MVP)
- [x] State machine: Ground, OperatorPending, WaitingForChar
- [x] Basic operators: `d`, `c`, `y`
- [x] Character motions: `h`, `j`, `k`, `l`
- [x] Word motions: `w`, `b`, `e`, `W`, `B`, `E`
- [x] Line motions: `0`, `^`, `$`, `gg`, `G`
- [x] Find motions: `f`, `F`, `t`, `T`, `;`, `,`
- [x] Linewise doubling: `dd`, `cc`, `yy`
- [x] Count support
- [x] Basic text objects: `iw`, `aw`, `i(`, `a(`, `i"`, `a"`

### Phase 2
- [ ] All remaining motions (see catalog above)
- [ ] All remaining operators (`>`, `<`, `=`, `gq`, `gu`, `gU`, `g~`)
- [ ] Visual mode (v, V, Ctrl-v)
- [ ] Named registers (`"a`-`"z`)
- [ ] Clipboard registers (`"+`, `"*`)
- [ ] Dot repeat (`.`)
- [ ] Macros (`q`, `@`)

### Phase 3
- [ ] Tree-sitter text objects (`vaf`, `cic`, `dap`)
- [ ] Surround operator (`ys`, `cs`, `ds`)
- [ ] Comment operator (`gc`)
- [ ] Expression register (`"=`)
- [ ] Jump list (`Ctrl-o`, `Ctrl-i`)
- [ ] Change list (`g;`, `g,`)
