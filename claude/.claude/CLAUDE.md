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

### Plans, Notes, and Research Files
Before saving any of these files to disk, check the repo for any `.ai-dev` directories. If they are present, it is **critical** that plans go in one of those directories.
If changes are scoped to a single directory store plans in an `.ai-dev` directory in that directory.

Example directory: `packages/my-package/src/my-dir/.ai-dev/plans/2025-12-01-support-new-feature.md`.

**DO NOT** put plans in `~/.claude/plans`!

If no `.ai-dev` directories exist, and no other repo-specific instructions exist, ask the user where they should go.

### Markdown Preferences

When writing markdown files, follow these rules:
- Prefer mermaid for visualizations 

### Notes and research



### No deferred research or verification tasks
Never surface a recommendation, caveat, or follow-up item that asks the user to verify, look up, or confirm something you could resolve yourself. If a claim needs verification — a specific AWS primitive, an API behavior, a config detail, a naming convention — do the research inline and include the finding in your response. If you're uncertain, state your best determination with your confidence level and reasoning, then keep moving. The only acceptable output is a complete answer, not a checklist of things for the user to go do.

@RTK.md
