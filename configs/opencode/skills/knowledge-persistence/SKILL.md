---
name: knowledge-persistence
description: Persist reusable knowledge from the current session to structured Obsidian documents in `.knowledge/`. Use after solving non-trivial problems, discovering patterns, making technical decisions, or finding gotchas worth remembering.
---

# Knowledge Persistence Skill

Persist reusable, non-obvious knowledge to `.knowledge/` so future sessions can find it.

## Gate: Save or Skip?

Ask: **"Would finding this in 6 months save real time?"**

| Save | Skip |
|------|------|
| Non-trivial debugging solutions | Simple typos, syntax errors |
| Architectural decisions + rationale | Generic/Googleable info |
| Project-specific patterns, conventions | Temporary workarounds |
| Tech stack gotchas, library bugs | One-time fixes, session context |

If uncertain, skip. Only high-signal knowledge belongs here.

---

## Workflow

### 1. Check for Duplicates

```bash
rg -il "<topic keywords>" .knowledge
```

If a relevant file exists, **update it** instead of creating a new one.

### 2. Categorize

| Category | Purpose |
|----------|---------|
| `architecture/` | System design, structure |
| `patterns/` | Reusable code patterns |
| `solutions/` | Specific problem fixes |
| `learnings/` | Non-obvious concepts |
| `decisions/` | ADRs, technical choices |
| `gotchas/` | Pitfalls, edge cases |
| `references/` | Curated external resources |

### 3. Name the File

Format: `kebab-case-descriptive-name.md`
Path: `.knowledge/<category>/<name>.md`

Good: `solutions/cors-credential-mode-fix.md`
Bad: `solutions/fix.md`, `solutions/CORS Fix.md`

### 4. Write the Document

```markdown
---
title: <Clear, Searchable Title>
date: <YYYY-MM-DD>
tags: [<category>, <tech>, <project>]
related: ["[[category/filename]]"]
---

# <Title>

<One-line summary of the knowledge.>

## Context

<What situation or problem led to this.>

## Solution / Pattern / Finding

<The actual knowledge. Be specific — include code, commands, config.>

## Key Takeaway

<Why this matters. When to apply it.>
```

**See [`example.md`](./example.md) for a complete reference document.**

**Rules:**
- Frontmatter is required — `title`, `date`, `tags` always; `related` only if links exist (omit or use `[]` otherwise — never fabricate links)
- `related` uses wikilinks: `[[category/filename]]` (no extensions, no `../`)
- Keep content concise — facts and code, not narrative
- **Make it searchable:** embed the exact strings someone would `rg` for — error messages, CLI output, function names, config keys, package names. The search skill uses full-text search, so body content matters more than tags

### 5. Create Directory if Needed

Ensure the category directory exists before writing:

```bash
mkdir -p .knowledge/<category>
```

---

## Directory Structure

```
.knowledge/
├── architecture/
├── patterns/
├── solutions/
├── learnings/
├── decisions/
├── gotchas/
└── references/
```

---

> **Persist selectively.** A small, high-quality knowledge base beats a large, noisy one.
