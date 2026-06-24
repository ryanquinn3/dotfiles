# Skill: ask

Use when you need clarification or a decision from the user that would benefit from a structured prompt — multiple choice, multi-select, freeform text, or confirmation. Renders questions with `glow` and collects answers with `gum` in a tmux split. All answers are submitted in a single message at the end.

Do not use for simple yes/no questions you can ask inline. Do not use during the wave phase or any time a tmux session is not available.

## How to invoke

### 1. Get the current pane ID

```bash
tmux display-message -p '#{pane_id}'
```

Store this — it is the return address for the answers.

### 2. Write a manifest to `.tmp/`

Create a JSON file at `.tmp/<slug>-manifest.json`. Each entry is one question:

```json
[
  {
    "markdown": "# Question title\nBody text with context.",
    "type": "choose",
    "options": ["Option A", "Option B", "Option C"]
  }
]
```

**Types:**

| type | gum command | notes |
|---|---|---|
| `choose` | `gum choose` | single select; requires `options` |
| `checkbox` | `gum choose --no-limit` | multi-select; requires `options`; answers comma-joined |
| `input` | `gum input` | single-line freeform; optional `placeholder` |
| `write` | `gum write` | multi-line freeform |
| `confirm` | `gum confirm` | yes/no; optional `prompt` string |

### 3. Open the split and run

```bash
tmux split-window -h "/Users/ryanquinn/repos/castle/.tmp/ask.sh <pane_id> /Users/ryanquinn/repos/castle/.tmp/<slug>-manifest.json"
```

The split opens to the right. The user works through all questions in sequence. When finished, the pane closes and the answers arrive as a user message.

### 4. Wait for the answer message

Do not proceed until the answer message arrives. Do not poll or check the pane — just wait.

## Answer format

**Single question:** the raw answer, no prefix.

```
Observable field
```

**Multiple questions:** pipe-delimited, numbered.

```
1: Atom | 2: onChange,lazy eval | 3: all good | 4: no
```

Parse by splitting on ` | ` then stripping the `N: ` prefix from each segment.

## Example manifest

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
    "options": ["model", "view", "wave runtime", "config"]
  },
  {
    "markdown": "# Breaking change\nWill this require migrating existing code?",
    "type": "confirm",
    "prompt": "Breaking change?"
  }
]
```

## Notes

- Markdown is rendered inline via `glow -` (piped from the manifest field) — no separate `.md` files needed.
- The script lives at `.tmp/ask.sh` and is not committed. Recreate it if missing using the source in `.tmp/ask-skill.md`.
- The tmux split reuses a single pane for all questions — it does not open a new pane per question.
- `ask.sh` requires bash 3.2+ (macOS system bash is fine) and `glow`, `gum`, `jq`, and `tmux` on PATH.
