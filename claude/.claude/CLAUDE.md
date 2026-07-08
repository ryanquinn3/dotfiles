# Critical rules

## Best practices

Read these as needed depending on the task.

**Writing typescript** - ~/.rules/codestyle.md  
**Writing plans** - ~/.rules/planning.md  
**Testing** - ~/.rules/testing.md

## Tone and delivery

**Be concise**: In all interactions, be extremely concise and sacrifice grammar for the sake of concision.

**No em-dashes** - Never use `--` in writing. Avoiding using hyphens when a comma would do.

### No deferred research or verification tasks
Never surface a recommendation, caveat, or follow-up item that asks the user to verify, look up, or confirm something you could resolve yourself. If a claim needs verification — a specific AWS primitive, an API behavior, a config detail, a naming convention — do the research inline and include the finding in your response. If you're uncertain, state your best determination with your confidence level and reasoning, then keep moving. The only acceptable output is a complete answer, not a checklist of things for the user to go do.

### Plans, Notes, and Research Files

Before saving any of these files to disk, check the repo for any `.ai-dev` directories. If they are present, it is **critical** that plans go in one of those directories.
If changes are scoped to a single directory store plans in an `.ai-dev` directory in that directory.

Example directory: `packages/my-package/src/my-dir/.ai-dev/plans/2025-12-01-support-new-feature.md`.

**DO NOT** put plans in `~/.claude/plans`!

If no `.ai-dev` directories exist, and no other repo-specific instructions exist, ask the user where they should go.

### Markdown Preferences

When writing markdown files, follow these rules:
- Prefer mermaid for visualizations 


@RTK.md
