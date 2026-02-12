---
name: gdrive-resolve-comments
description: Use when resolving Google Drive comments on markdown files with gdrive_file_id frontmatter - fetches comments, collaboratively plans changes, updates document with clean content and changelog
---

# Google Drive Comment Resolution

## Overview

Collaborative workflow for resolving Google Drive comments on markdown files. Fetches open comments from Google Drive, uses brainstorming to plan changes, applies updates section-by-section, and maintains a changelog. Keeps document content clean without inline comment references.

## When to Use This Skill

**DO use gdrive-resolve-comments:**
- User invokes `/gdrive:resolve-comments [path-to-markdown-file]`
- Markdown file has `gdrive_file_id` in frontmatter
- Need to address Google Drive comments collaboratively
- Want structured comment review before making changes

**DON'T use gdrive-resolve-comments:**
- Markdown file has no `gdrive_file_id` frontmatter
- Making changes unrelated to Drive comments
- Document has no associated Google Drive file

## Workflow

### 1. Fetch and Categorize Comments

**Invoke script:**
```bash
/workspaces/obsidian/.ryanquinn3/gdrive/list-comments.ts [markdown-path]
```

**Parse output** to extract:
- Comment number
- Author name
- Quoted text (document anchor)
- Comment content
- Replies

**Categorize by section:**
- Group by quoted text location (maps to document sections)
- General comments without quotes → "General/Document-wide" category
- Sort categories by document order (top-to-bottom)

**Present summary:**
```
Found 8 open comments on document.gdrive.md

## Architecture Section (3 comments)
- Comment #2 (Jane): "Consider using event sourcing pattern"
- Comment #5 (Bob): "This approach has scaling concerns"
...

## General/Document-wide (3 comments)
- Comment #1 (Alice): "Overall structure needs examples"
...
```

**Early exit:** If zero open comments, report "No open comments found" and stop.

### 2. Brainstorm Changes

**Automatic invocation:**
After presenting comments, immediately invoke:
```
/superpowers:brainstorm "Resolve Google Drive comments on [filename]"
```

**Context provided:**
- Full categorized comment list
- Current markdown file content
- Instruction: "Design changes to address comments while keeping document clean and adding summary to changelog"

**Brainstorming produces:**
- Validated change plan
- Section-by-section approach
- Agreed-upon content updates

### 3. Apply Changes Section-by-Section

**For each section:**

1. **Present proposal** with comment context:
```
Addressing comments #2, #5:
- Comment #2 (Jane): "Consider event sourcing pattern"
- Comment #5 (Bob): "Scaling concerns with current approach"

Proposed change to "Architecture" section:
[Show new/modified markdown content]
```

2. **Get approval**: "Does this look good?"

3. **Apply edit**: Use Edit tool to update markdown

4. **Confirm and continue**: "Updated Architecture section. Ready for next section?"

**Important:** Comment references appear in proposals but NEVER in final markdown content.

### 4. Update Changelog

**After all content changes:**

1. Check for existing `## Changelog` section
2. If missing, append new section at document bottom
3. Generate summary entry:
   - Current date
   - High-level description (2-4 sentences)
   - Focus on improvements, not attribution
   - No comment IDs or granular details

**Format:**
```markdown
## Changelog

**Iteration 2 (2026-01-30)**
Addressed feedback on architecture approach and testing strategy. Restructured deployment section for clarity and added concrete examples throughout. Enhanced error handling documentation based on security review.

**Iteration 1 (2026-01-15)**
Initial draft
```

**Prepend** new entries (most recent first).

**Final message:**
"Changelog updated. All changes applied to [filename]. Comments remain open in Google Drive for your manual review."

## Error Handling

| Error | Response |
|-------|----------|
| No `gdrive_file_id` in frontmatter | Error: "Markdown file missing gdrive_file_id in frontmatter. Add to frontmatter or run list-comments.ts manually." |
| list-comments.ts fails | Surface script error to user, don't proceed |
| Zero open comments | Message: "No open comments found. Document is up to date." Skip brainstorming. |
| User rejects proposal | Return to brainstorming, ask: "How should we revise this approach?" |
| Markdown file doesn't exist | Check file existence before invoking script, error early |

## Key Principles

- **Structured review**: Present all comments grouped by section before planning
- **Collaborative design**: Always use brainstorming to plan changes
- **Clean content**: Comment references in proposals only, never in final markdown
- **Summary changelog**: High-level iteration description, not granular attribution
- **Manual resolution**: Leave Drive comments open for user to resolve after review
- **Section-by-section**: Apply changes incrementally with approval at each step

## Quick Reference

**Skill invocation:**
```
/gdrive:resolve-comments path/to/document.md
```

**Required frontmatter:**
```yaml
---
gdrive_file_id: 1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms
---
```

**Script location:**
```
/workspaces/obsidian/.ryanquinn3/gdrive/list-comments.ts
```

**Workflow phases:**
1. Fetch/categorize → 2. Brainstorm → 3. Apply changes → 4. Update changelog

