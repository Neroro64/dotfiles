---
description: Extract and persist key insights from the current conversation using qmd
---
Extract and persist key insights from the current conversation.

## Task

1. Gather all relevant key insights, decisions, observations and learnings from the conversation.
2. Determine the appropriate qmd collection for the current working directory:
   - Check if a collection already exists for the current project directory using `qmd collection list`
   - If not, create a collection with `qmd collection add . --name <project-name>` where `<project-name>` is derived from the current directory
3. Use qmd to search for existing notes on related topics:
   - `qmd query "keywords from insight" -n 10 --json` - Hybrid search with re-ranking for best results
   - OR `qmd search "exact keywords" -n 10 --json` - Fast keyword search
   - OR `qmd vsearch "semantic meaning" -n 10 --json` - Pure semantic search
4. If relevant notes exist (score > 0.3), retrieve them with `qmd get <filepath>` or `qmd multi-get <pattern>` to read their content.
5. Update existing notes with new insights, or create new markdown notes if no relevant notes exist.
6. Determine an appropriate folder structure within the collection (e.g., "notes/insights", "notes/decisions", "notes/meetings", "notes/projects").
7. Write the notes using clear, descriptive titles that capture the main topic.
8. Include context like date, related topics where relevant.
9. Store notes in a location that is part of the qmd-indexed collection.
10. After adding or modifying notes, update the qmd index with `qmd update` to ensure new/changed documents are searchable.

## Search Strategy

Choose the appropriate qmd search command based on your need:

- **`qmd search`**: Fast BM25 full-text search. Use for exact keyword matches and when you know the terminology.
- **`qmd vsearch`**: Vector semantic search. Use when searching for concepts, even if different words are used.
- **`qmd query`**: Hybrid search with LLM re-ranking. Best quality search for finding the most relevant results across keywords and meaning.

## Retrieval Options

- `qmd get <filepath>`: Retrieve a specific document by its collection-relative path
- `qmd get #docid`: Retrieve a document by its docid (shown in search results)
- `qmd multi-get "pattern*.md"`: Retrieve multiple documents matching a glob pattern
- Use `--full` flag to get complete document content
- Use `-l <num>` to limit line count

## Output Format

Return a summary of what was captured:
- Number of notes created/updated
- List of note titles and their locations (collection-relative paths)
- Any links to related notes found (docids from search results)
- Confirmation that `qmd update` was run to index the changes
