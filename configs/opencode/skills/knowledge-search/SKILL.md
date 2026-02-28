---
name: knowledge-search
description: Search and retrieve existing knowledge, patterns, solutions, and insights from the project's knowledge base before starting work. Helps agents find relevant context, avoid repeating past mistakes, and leverage accumulated learnings. Use when starting a new task, encountering an error, or needing context from previous sessions.
---

# Knowledge Search Skill

Search the project's knowledge base before starting work to leverage accumulated wisdom.

## When to Use

- **New task** → Check if similar work exists
- **Error encountered** → Find existing solutions/gotchas
- **Technical decision** → Find ADRs and decisions
- **Unsure approach** → Find patterns and best practices

## Knowledge Base Structure

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

## Search Commands (use `rg` via Bash)

| Need | Command |
|------|---------|
| Broad search | `rg -i "<term>" .knowledge` |
| By category | `rg -i "<term>" .knowledge/<category>` |
| Filenames only | `rg -l "<term>" .knowledge` |
| With context | `rg -C 2 "<term>" .knowledge` |
| Markdown only | `rg -t md "<term>" .knowledge` |

**Common flags:** `-i` (case-insensitive), `-l` (filenames), `-C N` (context), `-w` (whole word)

## Search Workflow

1. **Identify terms** → technologies, concepts, error patterns, components
2. **Broad search** → `rg -i "<term>" .knowledge`
3. **Narrow if needed** → search specific category
4. **Read files** → use Read tool
5. **Follow connections** → check `related:` and `[[wikilinks]]`

## Quick Reference by Task

| Task | Search Order |
|------|--------------|
| **Debugging** | `solutions/` → `gotchas/` → `learnings/` |
| **New feature** | `architecture/` → `patterns/` → `decisions/` |
| **Unfamiliar code** | `architecture/` → `learnings/` → `references/` |
| **Technical decision** | `decisions/` → `patterns/` → `gotchas/` |

## Tips

- Use multiple search terms (different terminology may exist)
- Try partial matches: `rg "auth.*token" .knowledge`
- If nothing found, proceed and document findings afterward
- Always search before asking user for context

---

> **Remember:** Search first to avoid duplicate work and leverage past learnings.
