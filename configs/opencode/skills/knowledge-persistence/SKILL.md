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

## Workflow

### 1. Extract Knowledge

Analyze the current session to identify:

- **Solutions**: Problems solved and how they were resolved
- **Patterns**: Recurring patterns or best practices discovered
- **Learnings**: New concepts, APIs, or techniques learned
- **Decisions**: Technical or architectural decisions made
- **Gotchas**: Pitfalls, edge cases, or non-obvious behaviors found
- **References**: Useful resources, documentation, or code snippets

### 2. Categorize Knowledge

Determine the appropriate category for each knowledge item:

| Category | Description | Example Filename |
|----------|-------------|------------------|
| `architecture` | System design, structure decisions | `architecture/api-design.md` |
| `patterns` | Reusable code patterns | `patterns/error-handling.md` |
| `solutions` | Specific problem solutions | `solutions/cors-fix.md` |
| `learnings` | New concepts discovered | `learnings/webgl-basics.md` |
| `decisions` | ADRs and technical choices | `decisions/0001-database-choice.md` |
| `gotchas` | Pitfalls and edge cases | `gotchas/timezone-issues.md` |
| `references` | External resources and docs | `references/official-api-docs.md` |

### 3. Create/Update Documents

Create properly Obsidian formatted documents:

```yaml
---
title: Document Title
date: 2024-01-15
tags:
  - category
  - relevant-tags
  - project-name
related:
  - "[[related-note]]"
  - "[[another-note]]"
category: patterns
status: active
---
```

### 4. Storage Location

All knowledge documents are stored under:

```
project_root/.knowledge/
├── architecture/
├── patterns/
├── solutions/
├── learnings/
├── decisions/
├── gotchas/
└── references/
```

## Best Practices

### Document Quality

1. **Be Specific**: Include exact error messages, versions, and configurations
2. **Show Context**: Provide enough background for future understanding
3. **Link Generously**: Connect to related notes using wikilinks
4. **Keep Current**: Update documents when information becomes stale
5. **Tag Consistently**: Use consistent tag conventions across documents

### Organization

1. **One Concept Per Note**: Keep notes focused and atomic
2. **Use Categories**: Place documents in appropriate subdirectories
3. **Index Important Topics**: Create MOCs (Maps of Content) for large topics
4. **Cross-Reference**: Link related concepts together

### Naming Conventions

- Use kebab-case for filenames: `api-error-handling.md`
- Start with the core concept: `react-hooks-learnings.md`
- Include date for time-sensitive content: `2024-01-15-deployment-issue.md`
- Use ADR numbering for decisions: `0001-database-choice.md`

## Example Usage

After a session where you debugged a complex CORS issue:

1. Extract the knowledge: problem (CORS errors), solution (server config), gotcha (credentials mode)
2. Create/update documents:
   - `solutions/cors-configuration.md` - Full solution
   - `gotchas/credentials-mode.md` - Specific gotcha discovered
3. Link to related existing notes
4. Add appropriate tags for discoverability

## Quick Reference

```bash
# Directory structure
.knowledge/
├── architecture/   # System design docs
├── patterns/       # Reusable patterns
├── solutions/      # Problem solutions
├── learnings/      # New concepts learned
├── decisions/      # ADRs and decisions
├── gotchas/        # Pitfalls and edge cases
└── references/     # External resources
```
