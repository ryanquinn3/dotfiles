---
name: Jira Project Manager
description: Workflows for creating jira tickets 
tags: [jira, ticket, adf, formatting]
---

# Jira Project Manager

Create professional Jira tickets with rich formatting (code blocks, links, headings) using Atlassian Document Format (ADF).

## Input

Accept ticket description in one of these forms:
1. Path to a markdown/text file containing the description
2. Direct text input from the user
3. Reference to an existing description file

## Workflow Steps

### 1. Understand the Schema

First, run this command to see the exact JSON structure needed:

```bash
acli jira workitem create --generate-json
```

This shows all available fields including the ADF structure for descriptions. Save this template for reference.

### 2. Gather Required Information

Ask the user for missing information (use AskUserQuestion tool if multiple items needed):

**Required:**
- Project key (e.g., PROD, ENG)
- Issue type (Story, Task, Bug, Epic)
- Summary/Title (short, descriptive)

**Optional but recommended:**
- Parent epic ID (e.g., PROD-4584)
- Assignee email/ID. Default to `--assignee @me`.

### 3. Parse the Description Content

Read and understand the ticket description:
- Extract the main problem statement
- Identify code examples, schemas, or technical details
- Note any questions, ideas, or open issues
- Preserve links to GitHub, documentation, etc.

### 4. Convert to Atlassian Document Format (ADF)

Create a properly structured ADF JSON with these patterns:

**Text formatting:**
```json
{
  "type": "text",
  "text": "regular text"
}
```

**Inline code:**
```json
{
  "type": "text",
  "text": "Viewer",
  "marks": [{"type": "code"}]
}
```

**Code blocks:**
```json
{
  "type": "codeBlock",
  "attrs": {"language": "graphql"},
  "content": [{"type": "text", "text": "code here"}]
}
```

**Links:**
```json
{
  "type": "text",
  "text": "link text",
  "marks": [
    {
      "type": "link",
      "attrs": {"href": "https://example.com"}
    }
  ]
}
```

**Bold text:**
```json
{
  "type": "text",
  "text": "bold text",
  "marks": [{"type": "strong"}]
}
```

**Headings:**
```json
{
  "type": "heading",
  "attrs": {"level": 3},
  "content": [{"type": "text", "text": "Heading text"}]
}
```

**Paragraphs:**
```json
{
  "type": "paragraph",
  "content": [/* text nodes */]
}
```

### 5. Create Complete Ticket JSON

Build a complete creation JSON with all fields populated:

```json
{
  "project": "PROJ",
  "summary": "Ticket title here",
  "type": "Story",
  "parent": "PROJ-123",
  "assignee": "user@company.com", /* you should default this to "@me" unless otherwise specified */
  "labels": ["feature", "backend"],
  "description": {
    "version": 1,
    "type": "doc",
    "content": [
      /* Your ADF nodes here */
    ]
  }
}
```

Save this to a file like `.ryanquinn3/{project}-ticket-create.json`

### 6. Create the Ticket

Create the ticket in one operation using the complete JSON:

```bash
acli jira workitem create --from-json "/path/to/{project}-ticket-create.json"
```

Capture the ticket ID from the output (e.g., PROD-4634) then remove the ticket-create.json file.

### 7. Confirm and Provide Links

Report success with:
- Ticket ID and URL (e.g., https://vanta.atlassian.net/browse/PROD-4634)
- Summary of what was created
- Location of saved files for future reference

## Common Patterns to Recognize

When parsing descriptions, look for these markdown patterns and convert to ADF:

| Markdown | ADF Node Type |
|----------|---------------|
| `` `code` `` | text with code mark |
| ` ```lang ` | codeBlock with language attr |
| `**bold**` or `*italic*` (wiki) | text with strong mark |
| `[text](url)` or `[text\|url]` (wiki) | text with link mark |
| `# Heading` or `h3.` (wiki) | heading node (level based on # count or h-number) |
| `{{code}}` (wiki) | text with code mark |
| `{code:lang}...{code}` (wiki) | codeBlock with language attr |
| File paths | Often should be inline code |
| Class/variable names | Inline code |
| GitHub URLs | Links with descriptive text |

## Error Handling

If ticket creation fails:
1. Check project key is valid
2. Verify user has permissions in that project
3. Ensure parent epic exists (if provided)
4. Validate JSON structure matches the schema from `--generate-json`
5. Check that all required fields are present
6. Verify ADF structure is properly formatted

## Example Interaction

```
User: Create a ticket from .ryanquinn3/feature-description.md

Agent: I'll help create a Jira ticket from that file. First, let me understand the schema.

[Runs: acli jira workitem create --generate-json]

Agent: Got it. Now let me read your description file.

[Reads .ryanquinn3/feature-description.md]

Agent: I see this is about supporting anonymous user client targeting for Fedramp. I need some information:

[Uses AskUserQuestion to gather]
- What project should this go in? (e.g., PROD, ENG)
- What's the parent epic ID? (if any)
- Should this be a Story, Task, or Bug?
- Any assignee or labels?

User: PROD project, parent is PROD-4584, make it a Story, no assignee yet

Agent: Perfect. I'll now:
1. Convert the markdown description to ADF format
2. Build the complete ticket creation JSON with all fields
3. Create the ticket in one operation
4. Save reference files

[Converts description to ADF, creates complete JSON]
[Runs: acli jira workitem create --from-json ...]
[Captures ticket ID: PROD-4634]
[Creates reference files]

Agent: Done! Created ticket PROD-4634:
- URL: https://vanta.atlassian.net/browse/PROD-4634

The ticket has rich formatting with code blocks, links, and proper headings.
```

## Tips for Best Results

1. **Preserve technical details**: Code snippets, file paths, and class names should be formatted as inline code
2. **Structure with headings**: Use h3/h4 for sections like "Open Questions", "Implementation", "Testing"
3. **Link to code**: Convert GitHub URLs to proper links with descriptive text
4. **Use code blocks**: For schemas, examples, or multi-line code with appropriate language syntax
5. **Save all reference files**: Keep both create and edit versions for future use
6. **Single operation**: Create the ticket with full formatting in one step using `--from-json`
7. **Validate schema**: Always start by checking the current schema with `--generate-json`

