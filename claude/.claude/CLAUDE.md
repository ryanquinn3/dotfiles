
## Critical rules

### Be concise
In all interactions, be extremely concise and sacrifice grammar for the sake of concision.

### Never use em-dashes


### Code Intelligence

Prefer LSP over Grep/Read for code navigation — it's faster, precise, and avoids reading entire files:
- `workspaceSymbol` to find where something is defined
- `findReferences` to see all usages across the codebase
- `goToDefinition` / `goToImplementation` to jump to source
- `hover` for type info without reading the file

Use Grep only when LSP isn't available or for text/pattern searches (comments, strings, config).

After writing or editing code, check LSP diagnostics and fix errors before proceeding.

### Plan Files

**CRITICAL**: When developing plans or proposals, if changes are scoped to a single directory store plans in an `.ai-dev` directory in that directory.

Example directory: `packages/my-package/src/my-dir/.ai-dev/plans/2025-12-01-support-new-feature.md`.

**DO NOT** put plans in `~/.claude/plans`!!

### Markdown Preferences

When writing markdown files, follow these rules:
- Prefer mermaid for visualizations 

### Notes and research

For all other markdown files (proposals, explorations, research, diagrams), use the top level `.ai-dev` directory. Find an appropriate sub-directory based on the context of the conversation.

### Other Preferences
- prefer flatten function styles. return early and keep the else branch flatter.
