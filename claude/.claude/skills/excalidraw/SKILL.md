---
name: excalidraw
description: "Use when working with *.excalidraw or *.excalidraw.json files, user mentions diagrams/flowcharts, or requests architecture visualization - delegates all Excalidraw operations to subagents to prevent context exhaustion from verbose JSON (single files: 4k-22k tokens, can exceed read limits)"
---

# Excalidraw Subagent Delegation

## Iron Law

**Main agents NEVER read Excalidraw files. No exceptions. Always delegate via Task tool.**
Excalidraw JSON has extreme verbosity (4k-22k tokens per file) with <10% signal. Subagents isolate this cost.

## When to Use

**Trigger on ANY of these:**
- File path contains `.excalidraw` or `.excalidraw.json`
- User requests: "explain/update/create diagram", "show architecture", "visualize flow"
- User mentions: "flowchart", "architecture diagram", "Excalidraw file"
- Architecture/design documentation tasks involving visual artifacts

**Use delegation even for** "small" files (4k tokens minimum), "quick checks", single file ops, modifications.

## Critical Format Rules

Subagents must know these before writing/modifying Excalidraw JSON:

1. **Labels need TWO elements** - `label` property broken in raw JSON. Shape needs `boundElements: [{type:"text", id:"x-text"}]` + separate text element with `containerId: "x"`
2. **NEVER use diamond shapes** - Arrow connections broken in raw JSON. Use styled rectangles instead (coral for orchestrators, orange+dashed for decisions)
3. **Elbow arrows need THREE properties** - `roughness: 0`, `roundness: null`, `elbowed: true` for 90-degree corners
4. **Arrow x,y = source shape edge, not center** - Bottom: `(x + width/2, y + height)`, Right: `(x + width, y + height/2)`, etc.
5. **Arrow width/height = bounding box of points** - `width = max(abs(p[0]))`, `height = max(abs(p[1]))`
6. **Stagger multiple arrows from same edge** - Spread at 20%-80% across edge width

Default color palette (most common):

<table>
<tr><th>Type</th><th>BG</th><th>Stroke</th></tr>
<tr><td>Frontend</td><td><code>#a5d8ff</code></td><td><code>#1971c2</code></td></tr>
<tr><td>Backend/API</td><td><code>#d0bfff</code></td><td><code>#7048e8</code></td></tr>
<tr><td>Database</td><td><code>#b2f2bb</code></td><td><code>#2f9e44</code></td></tr>
<tr><td>Storage</td><td><code>#ffec99</code></td><td><code>#f08c00</code></td></tr>
<tr><td>External</td><td><code>#ffc9c9</code></td><td><code>#e03131</code></td></tr>
<tr><td>Orchestration</td><td><code>#ffa8a8</code></td><td><code>#c92a2a</code></td></tr>
</table>

## Reference Files

Subagents should read these before working on Excalidraw files:

<table>
<tr><th>File</th><th>Purpose</th><th>Used By</th></tr>
<tr><td><code>references/json-format.md</code></td><td>Element types, required properties, label binding, grouping</td><td>Create, Modify</td></tr>
<tr><td><code>references/arrows.md</code></td><td>Routing algorithm, edge formulas, patterns, staggering, bindings</td><td>Create, Modify</td></tr>
<tr><td><code>references/colors.md</code></td><td>Default + AWS/Azure/GCP/K8s palettes</td><td>Create</td></tr>
<tr><td><code>references/examples.md</code></td><td>Full 3-tier JSON example, layout patterns, complexity guidelines</td><td>Create</td></tr>
<tr><td><code>references/validation.md</code></td><td>Pre-flight algorithm, checklists, common bugs + fixes</td><td>Create, Modify</td></tr>
</table>

## Delegation Pattern

### Main Agent NEVER / ALWAYS

**NEVER:** Read .excalidraw files, parse Excalidraw JSON, load multiple diagrams, inspect files to "understand the format"

**ALWAYS:** Delegate via Task tool, provide clear task description, request text-only summaries (not raw JSON), keep diagram analysis isolated

### Subagent Templates

#### Create Operation
```
Task: Create new Excalidraw diagram showing [description]

Context: Excalidraw JSON requires TWO elements per label (shape + text), elbow arrows need roughness:0/roundness:null/elbowed:true, NEVER use diamonds. Arrow x,y starts at shape edge not center.

Steps:
1. Read references/json-format.md, references/arrows.md, references/colors.md, references/examples.md
2. Analyze codebase to identify components and relationships
3. Plan layout (vertical flow most common: rows at y=100,230,380,530,680)
4. Generate elements with proper label bindings and arrow routing
5. Validate against references/validation.md before writing
6. Write to [file.excalidraw.json]

Return: File location + component summary
```

#### Modify Operation
```
Task: Add/update [component] in [file.excalidraw.json]

Context: Excalidraw JSON requires TWO elements per label (shape + text), elbow arrows need roughness:0/roundness:null/elbowed:true, NEVER use diamonds. Arrow x,y starts at shape edge not center.

Steps:
1. Read references/json-format.md and references/arrows.md
2. Read existing file, identify elements and positions
3. Make changes preserving existing element structure
4. Validate against references/validation.md before writing
5. Write updated file

Return: Confirmation + changes made
```

#### Read/Understand Operation
```
Task: Extract and explain the components in [file.excalidraw.json]

Steps:
1. Read the Excalidraw JSON
2. Extract text elements (ignore positioning/styling)
3. Identify relationships between components
4. Summarize architecture/flow

Return: Component list + relationships. DO NOT return raw JSON.
```

#### Compare Operation
```
Task: Compare architecture in [file1] vs [file2]

Steps:
1. Read both files
2. Extract text labels from each
3. Identify structural differences
4. Compare component relationships

Return: Key differences only. DO NOT return raw element details.
```

## Anti-Rationalization

<table>
<tr><th>Thought</th><th>Reality</th></tr>
<tr><td>"Direct reading is most efficient"</td><td>Consumes 4k-22k tokens, use subagent</td></tr>
<tr><td>"It's a small file / quick check"</td><td>Minimum 4k tokens, still pollutes context</td></tr>
<tr><td>"I need to understand the format"</td><td>Format knowledge belongs in subagent, not main context</td></tr>
<tr><td>"The JSON is straightforward"</td><td>Problem is verbosity not complexity: 79 elements x ~280 tokens = 22k</td></tr>
<tr><td>"Just parsing text labels"</td><td>Still loads full JSON to extract 10% signal</td></tr>
<tr><td>"Within reasonable bounds"</td><td>"Reasonable" is rationalization. Hard rule: delegate</td></tr>
</table>

**All of these mean: use Task tool with subagent instead.**

## Token Analysis

<table>
<tr><th>Scenario</th><th>Without Delegation</th><th>With Delegation</th><th>Savings</th></tr>
<tr><td>Single large file</td><td>22k tokens (45% budget)</td><td>~500 tokens (summary)</td><td>98%</td></tr>
<tr><td>Two-file comparison</td><td>18k tokens</td><td>~800 tokens (diff)</td><td>96%</td></tr>
<tr><td>Modification task</td><td>14k tokens</td><td>~300 tokens (confirmation)</td><td>98%</td></tr>
<tr><td>All 7 project diagrams</td><td>67k tokens (33% budget)</td><td>~2k tokens</td><td>97%</td></tr>
</table>
