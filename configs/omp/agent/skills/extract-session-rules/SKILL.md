---
name: extract-session-rules
description: "Extract failure-prevention rules from the current session's trial-and-error loop. The agent typically explores, attempts solutions, hits compilation/test failures or user corrections, then refines. This skill captures what would have prevented each failure so future sessions skip the loop. Use at session end or when the user says: 'save what we learned', 'extract rules', 'remember this', 'turn this into a rule', or 'capture this learning'."
---

# Extract Session Rules

At the end of a session, scan the conversation for failure arcs — moments where the agent tried something, hit a wall (compilation error, test failure, wrong approach, user correction), and had to course-correct. For each arc, extract what the agent could have known upfront to avoid the failure entirely.

## What to Look For

Scan the session for failure arcs — points where the agent hit a wall and had to course-correct. Each arc is a candidate for extraction.

Look for:

- **Compilation/type errors** that required multiple attempts to resolve (wrong API shape, missing import, wrong types)
- **Test failures** that revealed wrong assumptions about behavior or edge cases
- **Dead-end approaches** — paths the agent tried and abandoned (wrong abstraction, wrong dependency, wrong pattern)
- **User corrections** — moments where the user redirected the approach, rejected a solution, or said "not like that"
- **Non-obvious requirements** discovered only after a failure (ordering constraints, missing flags, undocumented behavior)
- **Tool/framework gotchas** where the obvious approach doesn't work and a specific workaround is needed

## Quality Gates

Every candidate must pass ALL five gates. The core question for each: **would this rule, if known at the start, have prevented the failure?**

- **Prevents a real failure?** This rule would have avoided a compilation error, test failure, dead-end approach, or user correction that actually happened.
- **Reusable?** The same failure could recur in future sessions. One-off typos and environment-specific issues do not qualify.
- **Non-obvious?** The model wouldn't avoid this failure from general knowledge alone. Standard library APIs, basic syntax, well-documented behavior don't need rules.
- **Actionable?** Tells the model exactly what to do differently, not just what went wrong.
- **Worth the cost?** Every rule adds to future sessions. A failure that wastes 2 minutes and is unlikely to recur doesn't justify a rule that costs tokens indefinitely.

If a session has no learnings that pass all five gates, extract zero rules. Producing no rules is correct — do not force generic advice into rules.

## Choosing the Rule Type

1. Can you write a regex that matches the model's output when it's about to repeat the mistake? **Yes → TTSR.**
2. Is the learning guidance the model should look up when working in a specific area? **Yes → Rulebook.**
3. Both apply? **TTSR wins** — catching the mistake mid-stream is strictly better than hoping the model reads a rulebook entry.

## TTSR Rules

TTSR rules fire when the model's output stream matches a regex mid-generation. The stream aborts, the rule injects as a system reminder, and the request retries. One-shot per session, no loops.

**Frontmatter key:** `ttsrTrigger` — a regex pattern matching text the model would emit when repeating the mistake.

When crafting the trigger:

- Anchor on specific identifiers — function names, import paths, API calls, config keys — not generic syntax.
- Ask: "Would this regex fire during a different task in this project?" If yes, narrow it.
- Escape regex special characters properly in YAML.
- Prefer narrow over broad. A trigger that misses sometimes is better than one that fires on unrelated output.

**Anti-patterns:**

- `import .* from` — matches every import
- `function` — matches any function definition
- `TODO` — matches any comment
- Triggers that match user input (user input is not the model's output stream)

## Rulebook Rules

Rulebook rules are listed in the system prompt by description. Content is read on demand via `rule://`. Use when the learning is contextual guidance without a clear output-stream pattern.

**Frontmatter keys:**
- `description` (required) — one sentence stating when this rule applies. This is what the model sees in the system prompt to decide whether to read the full rule.
- `globs` (optional) — file patterns to scope the rule, e.g. `["vite.config.*"]`. Omit when the rule applies project-wide.

Do not use `alwaysApply: true`. Always-apply rules inject their full content into every system prompt — a perpetual token tax on sessions where the rule isn't relevant.

## Rule Content Guidelines

The rule body (below frontmatter) should be:

1. A brief title stating the problem
2. 2-3 sentences: what goes wrong, why, and what to do instead
3. No preamble, no generic advice, no "best practices", no "note that"
4. Specific enough that a future session can follow it without context

Every token in a rule is a token paid for each time the rule is loaded. Prefer "use X instead" over full code examples. Prefer naming the correct approach over showing syntax — the model reading the rule knows the language.

## The Extraction Process

### Autonomous Mode

When the user says "save what we learned", "extract rules from this session", or similar:

1. **Scan for failure arcs.** Walk through the session looking for the trial-and-error loop: attempts that failed, approaches that were abandoned, errors that took multiple tries to resolve. For each arc, note: what was tried, what failed, and what eventually worked.
2. **Filter through quality gates.** For each failure arc, ask: would a rule have prevented this? Check all five gates. Discard arcs where the answer is no.
3. **If zero candidates remain,** say so. "I reviewed the session and didn't find learnings that meet the bar for rules." Do not produce low-quality rules.
4. **For each surviving candidate:**
   a. Determine rule type using the decision heuristic.
   b. Craft the trigger (TTSR) or description (Rulebook).
   c. Write the rule body following the content guidelines.
   d. Choose a kebab-case filename (e.g., `no-deprecated-fetch-api.md`).
5. **Present each rule to the user** showing:
   - What happened in the session (the learning source)
   - The proposed rule file content (complete frontmatter + body)
   - Why this rule type (TTSR vs Rulebook)
6. **Get approval per rule.** User approves, edits, or rejects each one individually.
7. **Save approved rules** to `.omp/rules/<name>.md`. Create `.omp/rules/` if it doesn't exist.

### Directed Mode

When the user says "turn this into a rule" or describes a specific learning:

1. Clarify the problem and solution if ambiguous. Ask one focused question, not a questionnaire.
2. Determine rule type.
3. Craft trigger and content.
4. Present for approval.
5. Save to `.omp/rules/<name>.md`.

## Anti-Patterns

Do not extract rules for:

- One-off issues that won't recur (a typo, a misconfigured local environment)
- Workarounds for bugs that have been fixed (the rule becomes stale immediately)
- Things that belong in a code comment (if it's about one specific line in one specific file, put a comment there)

## Examples

### Example 1: TTSR rule from compilation failure arc

The agent tried `import { AuthClient } from '@company/sdk/auth'`, got a runtime error (silently returned `undefined`), spent 10 minutes debugging, discovered the import moved in v3.

```markdown
---
ttsrTrigger: "from ['\"]@company/sdk/auth['\"]"
---

# `AuthClient` moved in `@company/sdk` v3

`@company/sdk/auth` no longer exports `AuthClient` as of v3 — it silently returns
`undefined` instead of throwing an error. Import from `@company/sdk/clients` instead.
```

Saved as `.omp/rules/auth-client-import-path.md`.

### Example 2: Rulebook rule from build failure arc

The agent wrote a Vite config with `plugins` before `define`, builds silently produced `undefined` for env vars, agent spent time tracing through plugin initialization to find the ordering dependency.

```markdown
---
description: "Vite config ordering: define must precede plugins"
globs: ["vite.config.*"]
---

# Vite config field ordering

In this project's Vite config, the `define` field MUST appear before `plugins`. If
`plugins` comes first, environment variable substitution in plugin initialization
receives `undefined` instead of the defined values.
```

Saved as `.omp/rules/vite-config-define-ordering.md`.

### Example 3: Zero-rule session

A session involved routine feature development: adding a form field, writing validation, updating tests. First attempt compiled, tests passed, no user corrections needed.

Correct output: "I reviewed the session and didn't find failure arcs worth capturing as rules. Everything worked on the first attempt — no compilation errors, test failures, or wrong approaches to extract from."
