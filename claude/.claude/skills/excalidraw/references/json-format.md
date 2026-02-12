# Excalidraw JSON Format Reference

## File Structure

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "claude-code-excalidraw-skill",
  "elements": [],
  "appState": {
    "gridSize": 20,
    "viewBackgroundColor": "#ffffff"
  },
  "files": {}
}
```

## Element Types

<table>
<tr><th>Type</th><th>Use For</th><th>Arrow Reliability</th></tr>
<tr><td><code>rectangle</code></td><td>Services, components, databases, containers, orchestrators, decision points</td><td>Excellent</td></tr>
<tr><td><code>ellipse</code></td><td>Users, external systems, start/end points</td><td>Good</td></tr>
<tr><td><code>text</code></td><td>Labels inside shapes, titles, annotations</td><td>N/A</td></tr>
<tr><td><code>arrow</code></td><td>Data flow, connections, dependencies</td><td>N/A</td></tr>
<tr><td><code>line</code></td><td>Grouping boundaries, separators</td><td>N/A</td></tr>
</table>

### BANNED: Diamond Shapes

**NEVER use `type: "diamond"` in generated diagrams.**

Diamond arrow connections are fundamentally broken in raw Excalidraw JSON:
- Excalidraw applies `roundness` to diamond vertices during rendering
- Visual edges appear offset from mathematical edge points
- No offset formula reliably compensates
- Arrows appear disconnected/floating

Use styled rectangles instead for visual distinction:

<table>
<tr><th>Semantic Meaning</th><th>Rectangle Style</th></tr>
<tr><td>Orchestrator/Hub</td><td>Coral (<code>#ffa8a8</code>/<code>#c92a2a</code>) + strokeWidth: 3</td></tr>
<tr><td>Decision Point</td><td>Orange (<code>#ffd8a8</code>/<code>#e8590c</code>) + dashed stroke</td></tr>
<tr><td>Central Router</td><td>Larger size + bold color</td></tr>
</table>

## Required Element Properties

Every element MUST have these properties:

```json
{
  "id": "unique-id-string",
  "type": "rectangle",
  "x": 100,
  "y": 100,
  "width": 200,
  "height": 80,
  "angle": 0,
  "strokeColor": "#1971c2",
  "backgroundColor": "#a5d8ff",
  "fillStyle": "solid",
  "strokeWidth": 2,
  "strokeStyle": "solid",
  "roughness": 1,
  "opacity": 100,
  "groupIds": [],
  "frameId": null,
  "roundness": { "type": 3 },
  "seed": 1,
  "version": 1,
  "versionNonce": 1,
  "isDeleted": false,
  "boundElements": null,
  "updated": 1,
  "link": null,
  "locked": false
}
```

## Text Inside Shapes (Labels)

**Every labeled shape requires TWO elements.**

### Shape with boundElements

```json
{
  "id": "{component-id}",
  "type": "rectangle",
  "x": 500,
  "y": 200,
  "width": 200,
  "height": 90,
  "strokeColor": "#1971c2",
  "backgroundColor": "#a5d8ff",
  "boundElements": [{ "type": "text", "id": "{component-id}-text" }]
  // ... other required properties
}
```

### Text with containerId

```json
{
  "id": "{component-id}-text",
  "type": "text",
  "x": 505,                          // shape.x + 5
  "y": 220,                          // shape.y + (shape.height - text.height) / 2
  "width": 190,                      // shape.width - 10
  "height": 50,
  "text": "{Component Name}\n{Subtitle}",
  "fontSize": 16,
  "fontFamily": 1,
  "textAlign": "center",
  "verticalAlign": "middle",
  "containerId": "{component-id}",
  "originalText": "{Component Name}\n{Subtitle}",
  "lineHeight": 1.25
  // ... other required properties
}
```

### DO NOT Use the `label` Property

```json
// WRONG - will show empty boxes
{ "type": "rectangle", "label": { "text": "My Label" } }

// CORRECT - requires TWO elements
// 1. Shape with boundElements reference
// 2. Separate text element with containerId
```

### Text Positioning

- Text `x` = shape `x` + 5
- Text `y` = shape `y` + (shape.height - text.height) / 2
- Text `width` = shape `width` - 10
- Use `\n` for multi-line labels
- Always use `textAlign: "center"` and `verticalAlign: "middle"`
- ID convention: `{shape-id}-text`

## Dynamic ID Generation

IDs and labels are generated from codebase analysis:

<table>
<tr><th>Discovered Component</th><th>Generated ID</th><th>Generated Label</th></tr>
<tr><td>Express API server</td><td><code>express-api</code></td><td><code>"API Server\nExpress.js"</code></td></tr>
<tr><td>PostgreSQL database</td><td><code>postgres-db</code></td><td><code>"PostgreSQL\nDatabase"</code></td></tr>
<tr><td>Redis cache</td><td><code>redis-cache</code></td><td><code>"Redis\nCache Layer"</code></td></tr>
<tr><td>S3 bucket for uploads</td><td><code>s3-uploads</code></td><td><code>"S3 Bucket\nuploads/"</code></td></tr>
<tr><td>Lambda function</td><td><code>lambda-processor</code></td><td><code>"Lambda\nProcessor"</code></td></tr>
<tr><td>React frontend</td><td><code>react-frontend</code></td><td><code>"React App\nFrontend"</code></td></tr>
</table>

## Grouping with Dashed Rectangles

For logical groupings (namespaces, VPCs, pipelines):

```json
{
  "id": "group-ai-pipeline",
  "type": "rectangle",
  "x": 100,
  "y": 500,
  "width": 1000,
  "height": 280,
  "strokeColor": "#9c36b5",
  "backgroundColor": "transparent",
  "strokeStyle": "dashed",
  "roughness": 0,
  "roundness": null,
  "boundElements": null
}
```

Group labels are standalone text (no containerId) at top-left:

```json
{
  "id": "group-ai-pipeline-label",
  "type": "text",
  "x": 120,
  "y": 510,
  "text": "AI Processing Pipeline (Cloud Run)",
  "textAlign": "left",
  "verticalAlign": "top",
  "containerId": null
}
```
