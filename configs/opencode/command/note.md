---
description: Extract and persist key insights from the current conversation using qmd
---
Extract and persist key insights, observations, and learnings from the current conversation.

## Task

1. **Gather insights** - Review the conversation and identify:
   - Key decisions made and their rationale
   - Problems solved and the solutions used
   - Insights or learnings discovered
   - Observations about code, architecture, or patterns
   - Useful commands, configurations, or techniques

2. **Check qmd index status** - Use `qmd_status` MCP tool to see available collections and their health.

3. **Ensure a collection exists** for the current project:
   - Check if a collection already exists for the current project directory via `qmd_status` or `qmd collection list`
   - If not, create one: `qmd collection add . --name <project-name>` where `<project-name>` is derived from the directory name

4. **Search for existing related notes** using qmd MCP tools:
   - `qmd_query` - Best quality: hybrid search with query expansion + LLM re-ranking (use for important searches)
   - `qmd_search` - Fast: BM25 keyword search (use when you know exact terminology)
   - `qmd_vsearch` - Semantic: vector similarity search (use for conceptual/meaning-based searches)

5. **Retrieve and review** existing notes if found (score > 0.3):
   - `qmd_get` - Retrieve single document by filepath or docid (e.g., `notes/topic.md` or `#abc123`)
   - `qmd_multi_get` - Retrieve multiple documents by glob pattern (e.g., `notes/*.md`)

6. **Write or update notes**:
   - Update existing notes if they cover the same topic
   - Create new markdown notes if no relevant notes exist
   - Use clear, descriptive filenames that capture the main topic
   - Organize into appropriate folders (e.g., `notes/decisions/`, `notes/insights/`, `notes/til/`, `notes/troubleshooting/`)

7. **Structure note content** with:
   - Clear title as H1 heading
   - Date in frontmatter or header (format: YYYY-MM-DD)
   - Context section explaining the background
   - Main content with the insight/decision/learning
   - Related topics or links where relevant
   - Tags for categorization (optional)

8. **Update the qmd index** after writing notes:
   - Run `qmd update` to re-index new/changed documents
   - Run `qmd embed` if semantic search is needed for new content

## Search Strategy (MCP Tools)

| Tool | Best For | Speed | Quality |
|------|----------|-------|---------|
| `qmd_search` | Exact keywords, known terminology | Fast | Good |
| `qmd_vsearch` | Concepts, semantic similarity | Medium | Better |
| `qmd_query` | Important searches, best matches | Slower | Best |

All search tools accept:
- `query`: The search string
- `collection`: Filter to specific collection (optional)
- `limit`: Max results (default: 10)
- `minScore`: Minimum relevance score 0-1

## Retrieval Tools

| Tool | Usage | Example |
|------|-------|---------|
| `qmd_get` | Single document | `file: "notes/api-design.md"` or `file: "#abc123"` |
| `qmd_multi_get` | Multiple documents | `pattern: "notes/decisions/*.md"` |

Options:
- `lineNumbers`: Add line numbers to output
- `maxLines`: Limit lines returned
- `fromLine`: Start from specific line (qmd_get only)
- `maxBytes`: Skip large files (qmd_multi_get only, default: 10KB)

## Note Template

```markdown
# [Descriptive Title]

**Date:** YYYY-MM-DD
**Tags:** #tag1 #tag2

## Context

[Brief background on why this is relevant]

## Insight/Decision/Learning

[Main content - what was learned, decided, or observed]

## Details

[Supporting information, code examples, or elaboration]

## Related

- [Links to related notes or resources]
```

## Output Summary

After completing the task, report:
- **Notes created**: Count and list of new note paths
- **Notes updated**: Count and list of updated note paths
- **Related notes found**: Links to existing notes on similar topics (with docids)
- **Index updated**: Confirmation that `qmd update` was run
