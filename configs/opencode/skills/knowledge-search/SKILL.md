---
name: knowledge-search
description: Search the project's knowledge base (`.knowledge/`) before starting work. Finds existing solutions, patterns, gotchas, and architectural context from previous sessions. Use when starting a task, hitting an error, or making a technical decision.
---

# Knowledge Search Skill

Search `.knowledge/` before starting work to find existing solutions, patterns, and context.

## Workflow

### 1. Extract Search Terms

Pull concrete, searchable terms from the task:

| Task type | Extract these |
|-----------|---------------|
| Error / bug | Exact error message, error code, failing function |
| Feature | Technology names, component names, domain concepts |
| Decision | The area being decided on, alternatives considered |

### 2. Search (broad → narrow)

```bash
# Start broad — filenames matching the topic
rg -il "<term>" .knowledge

# Narrow to likely category (see routing table below)
rg -i "<term>" .knowledge/solutions

# Regex for related concepts
rg -i "auth.*token" .knowledge

# More context around matches
rg -C 3 "<term>" .knowledge
```

If `.knowledge/` doesn't exist or returns no results → proceed with the task. Persist discoveries afterward.

**Flags:** `-i` case-insensitive · `-l` filenames only · `-C N` context lines · `-w` whole word

**Category routing:**

| Task | Search first |
|------|-------------|
| Debugging | `solutions/` → `gotchas/` |
| New feature | `architecture/` → `patterns/` → `decisions/` |
| Technical decision | `decisions/` → `gotchas/` |
| Understanding code | `architecture/` → `patterns/` → `learnings/` |

### 3. Read and Apply

- Read matching files with the Read tool
- Follow `[[category/filename]]` wikilinks to related documents
- **Verify currency** — check that referenced code, config, or APIs still exist before applying
- Discard stale knowledge; flag it for update if significantly outdated

## Search Strategy

- **Try synonyms:** documents may use different terminology than the current task
- **Search error messages literally:** knowledge docs embed exact error strings for this reason
- **Start with `-l`:** get an overview of which files match before reading full content
- **Check multiple categories:** a CORS issue may appear in both `solutions/` and `gotchas/`

---

> **Search first.** Avoid duplicate work and leverage past learnings.
