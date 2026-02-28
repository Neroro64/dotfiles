---
name: knowledge-search
description: Search the project's knowledge base before starting work. Helps find relevant context, avoid repeating mistakes, and leverage accumulated learnings. Use when starting a new task, encountering an error, or needing context from previous sessions.
---

# Knowledge Search Skill

Search the knowledge base before starting work to leverage accumulated wisdom.

## When to Search

| Situation | Why Search |
|-----------|------------|
| New task | Check if similar work/solutions exist |
| Error encountered | Find existing fixes or gotchas |
| Technical decision | Find ADRs and prior decisions |
| Unfamiliar code | Find architecture context |

## Directory Structure

```
.knowledge/
├── architecture/   # System design
├── patterns/       # Reusable patterns
├── solutions/      # Problem solutions
├── learnings/      # Concepts learned
├── decisions/      # Architecture decisions (ADRs)
├── gotchas/        # Pitfalls and warnings
└── references/     # External resources
```

## Search Commands

```bash
# Broad search (start here)
rg -i "<term>" .knowledge

# By category
rg -i "<term>" .knowledge/solutions
rg -i "<term>" .knowledge/gotchas

# Find filenames
rg -l "<term>" .knowledge

# With context (2 lines before/after)
rg -C 2 "<term>" .knowledge
```

**Flags:** `-i` (case-insensitive), `-l` (filenames only), `-C N` (context), `-w` (whole word)

## Workflow

1. **Identify terms** → technologies, error messages, components
2. **Broad search** → `rg -i "<term>" .knowledge`
3. **Narrow** → search specific category if too many results
4. **Read** → use Read tool on relevant files
5. **Follow links** → check `[[category/filename]]` wikilinks in documents

## Search by Task Type

| Task | Priority Search |
|------|-----------------|
| Debugging | `solutions/` → `gotchas/` |
| New feature | `architecture/` → `patterns/` → `decisions/` |
| Technical decision | `decisions/` → `gotchas/` |

## Tips

- Try multiple search terms (different terminology may exist)
- Use regex for patterns: `rg "auth.*token" .knowledge`
- Nothing found? Proceed and document discoveries after

---

> **Search first.** Avoid duplicate work and leverage past learnings.
