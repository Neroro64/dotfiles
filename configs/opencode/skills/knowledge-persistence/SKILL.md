---
name: knowledge-persistence
description: Extract and persist knowledge, learnings, findings, and insights from the current session to structured Obsidian documents. Automatically organizes knowledge under project_root/.knowledge with proper frontmatter, wikilinks, and categorization. Use when you want to save session knowledge, create documentation from discoveries, or build a knowledge base from work done.
---

# Knowledge Persistence Skill

Extract knowledge from the current coding session and persist it to well-structured Obsidian documents. This skill helps build a cumulative knowledge base that survives across sessions.

## When to Use

- After discovering important patterns, solutions, or insights
- When documenting architectural decisions or technical findings
- To save learning outcomes from debugging or research
- When building project-specific knowledge bases
- After completing significant implementation work worth remembering

---

## ⚠️ Critical: What to Save vs. What to Skip

### ✅ SAVE: Reusable Knowledge

Only persist items that meet **ALL** of these criteria:

| Criterion | Question to Ask |
|-----------|-----------------|
| **Reusable** | Will this help solve future problems? |
| **Non-obvious** | Is this something not easily found via docs/Google? |
| **Project-specific** | Does this contain context unique to this codebase? |
| **Durable** | Will this remain relevant for months, not days? |

**Good candidates:**
- Non-trivial debugging solutions (not simple typos)
- Architectural decisions and their rationale
- Project-specific patterns and conventions
- Gotchas unique to this tech stack/configuration
- Workarounds for library bugs

### ❌ SKIP: Don't Save

| Skip These | Reason |
|------------|--------|
| One-time fixes | Not reusable |
| Simple typos/syntax errors | Self-evident |
| Generic documentation | Better sources exist |
| Temporary workarounds | Will become stale |
| Session-specific context | Won't apply later |
| Easily Googleable info | Redundant |

---

## Workflow

### 1. Filter Knowledge

Before saving, ask: **"Would I benefit from finding this in 6 months?"**

If no → Skip it.

### 2. Categorize

| Category | Use For | Example |
|----------|---------|---------|
| `architecture` | System design, structure decisions | `api-design.md` |
| `patterns` | Reusable code patterns | `error-handling.md` |
| `solutions` | Specific problem solutions | `cors-fix.md` |
| `learnings` | Non-obvious concepts discovered | `webgl-basics.md` |
| `decisions` | ADRs and technical choices | `0001-database-choice.md` |
| `gotchas` | Pitfalls and edge cases | `timezone-issues.md` |
| `references` | Curated external resources | `official-api-docs.md` |

### 3. Create Document

Use this exact format:

```yaml
---
title: Document Title
date: 2024-01-15
tags: [category, relevant-tags, project-name]
related:
  - "[[solutions/related-solution]]"
  - "[[gotchas/related-gotcha]]"
category: patterns
---

# Brief Summary

One sentence explaining what this is about.

## The Problem / Context

Brief description of the situation.

## The Solution / Pattern / Finding

The actual knowledge content.

## Why This Matters

Why this is useful to remember.
```

### 4. Wikilink Format

**Always use relative paths from `.knowledge/` root:**

```markdown
<!-- ✅ Correct -->
[[solutions/cors-fix]]
[[gotchas/credentials-mode]]
[[patterns/error-handling]]

<!-- ❌ Wrong -->
[[cors-fix]]           <!-- missing category -->
[[../solutions/cors-fix]]  <!-- no relative parent paths -->
[[CORS Fix]]           <!-- not a valid filename -->
```

---

## Storage Structure

```
project_root/.knowledge/
├── architecture/   # System design docs
├── patterns/       # Reusable patterns
├── solutions/      # Problem solutions
├── learnings/      # New concepts learned
├── decisions/      # ADRs and decisions
├── gotchas/        # Pitfalls and edge cases
└── references/     # External resources
```

---

## Quick Checklist Before Saving

- [ ] Is this reusable in future sessions?
- [ ] Is this non-obvious / hard to find elsewhere?
- [ ] Is the title clear and searchable?
- [ ] Are wikilinks using `[[category/filename]]` format?
- [ ] Is the content concise (not a brain dump)?
