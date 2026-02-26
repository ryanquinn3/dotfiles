
## Critical rules

### Be concise
In all interactions, be extremely concise and sacrifice grammar for the sake of concision.

### Never use em-dashes


### Prefer LSP
When doing code navigation in typescript, if an LSP is available it prefer that to manually grepping.

### Plan Files

**CRITICAL**: When developing plans or proposals, if changes are scoped to a single directory store plans in an `.ai-dev` directory in that directory.

Example directory: `packages/my-package/src/my-dir/.ai-dev/plans/2025-12-01-support-new-feature.md`.

**DO NOT** put plans in `~/.claude/plans`!!

### Markdown Preferences

When writing markdown files, follow these rules:

- Prefer mermaid for visualizations 
- Use HTML table syntax instead of markdown tables

### Notes and research

For all other markdown files (proposals, explorations, research, diagrams), use the top level `.ryanquinn3` directory. Find an appropriate sub-directory based on the context of the conversation.

### Other Preferences
- prefer flatten function styles. return early and keep the else branch flatter.
