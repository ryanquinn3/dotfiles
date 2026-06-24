---
name: user-input
description: Use when an opencode agent needs structured user input or a decision that is better handled in a tmux pane than plain chat, including multiple choice, multi-select, freeform text, or confirmation prompts.
---

# User Input

Use this skill when the user should answer through a small terminal UI instead of a plain chat question.

Good fits:

- Multiple choice with descriptions or context
- Multi-select choices
- Short freeform input
- Multi-line feedback
- Confirmation with supporting context

Do not use this for simple one-line questions you can ask directly in chat. Do not use it when `tmux` is unavailable.

## Overview

This skill uses a JSON manifest plus a helper script named `ask.sh` that lives next to this `SKILL.md` file.

The flow is:

1. Capture the current tmux pane ID.
2. Write a manifest JSON file describing one or more prompts.
3. Open a tmux split and run `ask.sh <pane_id> <manifest_path>`.
4. Wait for the user's answer message to arrive in the original pane.

The helper renders markdown with `glow`, collects answers with `gum`, and sends the final result back to the original pane as a single message.

## Manifest Format

Write a JSON array. Each item is one prompt.

```json
[
  {
    "markdown": "# Question title\nBody text with context.",
    "type": "choose",
    "options": ["Option A", "Option B", "Option C"]
  }
]
```

Supported prompt types:

| type | behavior | required fields |
|---|---|---|
| `choose` | single select | `options` |
| `checkbox` | multi-select | `options` |
| `input` | single-line text | none |
| `write` | multi-line text | none |
| `confirm` | yes/no | none |

Optional fields:

- `placeholder` for `input`
- `prompt` for `confirm`

## Invocation

### 1. Capture the current pane ID

```bash
tmux display-message -p '#{pane_id}'
```

Store this value. It is the return target for the final answer.

### 2. Create a manifest

Write the manifest into a temporary directory for the current workspace, for example `.tmp/ask/<slug>-manifest.json`.

Use a short slug that matches the decision being requested.

### 3. Run the helper in a split

Run the helper script from the directory that contains this skill:

```bash
tmux split-window -h './ask.sh <pane_id> <manifest_path>'
```

If you are not already in the skill directory, call the sibling `ask.sh` by path.

The split opens once, walks through all prompts in sequence, sends one final message back to the original pane, then closes itself.

### 4. Wait

Do not continue until the user response arrives in chat.

Do not poll tmux or inspect the split while waiting unless something failed.

## Answer Format

Single prompt:

```text
Observable field
```

Multiple prompts:

```text
1: Atom | 2: onChange,lazy eval | 3: all good | 4: no
```

Parse multi-prompt answers by splitting on ` | `, then stripping the `N: ` prefix from each segment.

For `checkbox`, multiple selections are comma-joined.

For `confirm`, the helper returns `yes` or `no`.

## Example Manifest

```json
[
  {
    "markdown": "# Naming\nWhat should the new module be called?",
    "type": "input",
    "placeholder": "e.g. event-bus"
  },
  {
    "markdown": "# Scope\nWhich layers should it touch?",
    "type": "checkbox",
    "options": ["model", "view", "runtime", "config"]
  },
  {
    "markdown": "# Breaking change\nWill this require migrating existing code?",
    "type": "confirm",
    "prompt": "Breaking change?"
  }
]
```

## Operational Notes

- Keep all prompts for one decision in one manifest so the user answers in a single pass.
- Put enough context in each `markdown` field that the user can answer without extra back-and-forth.
- Prefer `choose` over freeform text when the likely answers are already known.
- Prefer normal chat instead when the question is trivial.
- The helper expects `bash`, `tmux`, `jq`, `glow`, and `gum` on `PATH`.

## Failure Handling

If the split fails to open or the helper cannot run:

1. Check that `tmux` is active.
2. Check that `jq`, `glow`, and `gum` are installed.
3. Confirm the manifest path exists and contains valid JSON.
4. Fall back to a normal chat question if the terminal UI path is unavailable.

## Quality Bar

When using this skill:

- Ask only for decisions you genuinely need.
- Keep option labels concise and distinct.
- Make defaults and tradeoffs obvious in the markdown.
- Avoid project-specific hardcoded paths in commands or manifests.
- Batch related prompts together instead of interrupting repeatedly.
