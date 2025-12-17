---
description: Persist extracted knowledge from the current conversation into Basic Memory
agent: note-taker
---
Save the current conversation as a structured note inside the **current project** (the directory where Opencode is being run).  
Use `$ARGUMENTS` as the title of the note. If empty, create an appropriate sumamry for the note.

The command will automatically:
1. Gather all relevant key insights from the conversation.
2. Create a new Basic Memory note with that content.
3. Store it under the project matching your present working directory.

Note: The script should:
1. Search Basic Memory for a note titled `$ARGUMENTS`.
2. If found, update its content; otherwise create a new note.
   Use `basic_memory_write_note` with title `$ARGUMENTS`, updated content, folder and project "$(pwd)".
