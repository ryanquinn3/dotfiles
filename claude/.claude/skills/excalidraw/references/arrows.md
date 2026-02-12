# Arrow Routing Reference

## Critical: Elbow Arrow Properties

Three required properties for 90-degree corners:

```json
{
  "type": "arrow",
  "roughness": 0,
  "roundness": null,
  "elbowed": true
}
```

**Without these, arrows will be curved, not 90-degree elbows.**

## Edge Calculation Formulas

<table>
<tr><th>Shape Type</th><th>Edge</th><th>Formula</th></tr>
<tr><td>Rectangle</td><td>Top</td><td><code>(x + width/2, y)</code></td></tr>
<tr><td>Rectangle</td><td>Bottom</td><td><code>(x + width/2, y + height)</code></td></tr>
<tr><td>Rectangle</td><td>Left</td><td><code>(x, y + height/2)</code></td></tr>
<tr><td>Rectangle</td><td>Right</td><td><code>(x + width, y + height/2)</code></td></tr>
<tr><td>Ellipse</td><td>Top</td><td><code>(x + width/2, y)</code></td></tr>
<tr><td>Ellipse</td><td>Bottom</td><td><code>(x + width/2, y + height)</code></td></tr>
</table>

## Universal Arrow Routing Algorithm

```
FUNCTION createArrow(source, target, sourceEdge, targetEdge):
  sourcePoint = getEdgePoint(source, sourceEdge)
  targetPoint = getEdgePoint(target, targetEdge)

  dx = targetPoint.x - sourcePoint.x
  dy = targetPoint.y - sourcePoint.y

  IF sourceEdge == "bottom" AND targetEdge == "top":
    IF abs(dx) < 10:  // Nearly aligned
      points = [[0, 0], [0, dy]]
    ELSE:  // Need L-shape
      points = [[0, 0], [dx, 0], [dx, dy]]

  ELSE IF sourceEdge == "right" AND targetEdge == "left":
    IF abs(dy) < 10:
      points = [[0, 0], [dx, 0]]
    ELSE:
      points = [[0, 0], [0, dy], [dx, dy]]

  ELSE IF sourceEdge == targetEdge:  // U-turn
    clearance = 50
    IF sourceEdge == "right":
      points = [[0, 0], [clearance, 0], [clearance, dy], [dx, dy]]
    ELSE IF sourceEdge == "bottom":
      points = [[0, 0], [0, clearance], [dx, clearance], [dx, dy]]

  width = max(abs(p[0]) for p in points)
  height = max(abs(p[1]) for p in points)

  RETURN {x: sourcePoint.x, y: sourcePoint.y, points, width, height}

FUNCTION getEdgePoint(shape, edge):
  SWITCH edge:
    "top":    RETURN (shape.x + shape.width/2, shape.y)
    "bottom": RETURN (shape.x + shape.width/2, shape.y + shape.height)
    "left":   RETURN (shape.x, shape.y + shape.height/2)
    "right":  RETURN (shape.x + shape.width, shape.y + shape.height/2)
```

## Arrow Patterns

<table>
<tr><th>Pattern</th><th>Points</th><th>Use Case</th></tr>
<tr><td>Down</td><td><code>[[0,0], [0,h]]</code></td><td>Vertical connection</td></tr>
<tr><td>Right</td><td><code>[[0,0], [w,0]]</code></td><td>Horizontal connection</td></tr>
<tr><td>L-left-down</td><td><code>[[0,0], [-w,0], [-w,h]]</code></td><td>Go left, then down</td></tr>
<tr><td>L-right-down</td><td><code>[[0,0], [w,0], [w,h]]</code></td><td>Go right, then down</td></tr>
<tr><td>L-down-left</td><td><code>[[0,0], [0,h], [-w,h]]</code></td><td>Go down, then left</td></tr>
<tr><td>L-down-right</td><td><code>[[0,0], [0,h], [w,h]]</code></td><td>Go down, then right</td></tr>
<tr><td>S-shape</td><td><code>[[0,0], [0,h1], [w,h1], [w,h2]]</code></td><td>Navigate around obstacles</td></tr>
<tr><td>U-turn</td><td><code>[[0,0], [w,0], [w,-h], [0,-h]]</code></td><td>Callback/return arrows</td></tr>
</table>

## Worked Examples

### Vertical Connection (Bottom to Top)

```
Source: x=500, y=200, width=180, height=90
Target: x=500, y=400, width=180, height=90

source_bottom = (500 + 90, 200 + 90) = (590, 290)
target_top    = (500 + 90, 400)       = (590, 400)

Arrow x=590, y=290
Points = [[0, 0], [0, 110]]
```

### Fan-out (One to Many)

```
Orchestrator: x=570, y=400, width=140, height=80
Target:       x=120, y=550, width=160, height=80

orch_bottom  = (570 + 70, 400 + 80)  = (640, 480)
target_top   = (120 + 80, 550)       = (200, 550)

Arrow x=640, y=480
Points = [[0, 0], [-440, 0], [-440, 70]]
```

### U-turn (Callback)

```
Source: x=570, y=400, width=140, height=80
Target: x=550, y=270, width=180, height=90

source_right = (710, 440)
target_right = (730, 315)

Arrow x=710, y=440
Points = [[0, 0], [50, 0], [50, -125], [20, -125]]
```

## Staggering Multiple Arrows

When N arrows leave from same edge, spread evenly:

```
FUNCTION getStaggeredPositions(shape, edge, numArrows):
  positions = []
  FOR i FROM 0 TO numArrows-1:
    percentage = 0.2 + (0.6 * i / (numArrows - 1))

    IF edge == "bottom" OR edge == "top":
      x = shape.x + shape.width * percentage
      y = (edge == "bottom") ? shape.y + shape.height : shape.y
    ELSE:
      x = (edge == "right") ? shape.x + shape.width : shape.x
      y = shape.y + shape.height * percentage

    positions.append({x, y})
  RETURN positions

// Examples: 2 arrows: 20%, 80%  |  3: 20%, 50%, 80%  |  5: 20%, 35%, 50%, 65%, 80%
```

## Arrow Bindings

For better visual attachment, use `startBinding` and `endBinding`:

```json
{
  "id": "arrow-workflow-convert",
  "type": "arrow",
  "x": 525,
  "y": 420,
  "width": 325,
  "height": 125,
  "points": [[0, 0], [-325, 0], [-325, 125]],
  "roughness": 0,
  "roundness": null,
  "elbowed": true,
  "startBinding": {
    "elementId": "cloud-workflows",
    "focus": 0,
    "gap": 1,
    "fixedPoint": [0.5, 1]
  },
  "endBinding": {
    "elementId": "convert-pdf-service",
    "focus": 0,
    "gap": 1,
    "fixedPoint": [0.5, 0]
  },
  "startArrowhead": null,
  "endArrowhead": "arrow"
}
```

### fixedPoint Values

<table>
<tr><th>Position</th><th>fixedPoint</th></tr>
<tr><td>Top center</td><td><code>[0.5, 0]</code></td></tr>
<tr><td>Bottom center</td><td><code>[0.5, 1]</code></td></tr>
<tr><td>Left center</td><td><code>[0, 0.5]</code></td></tr>
<tr><td>Right center</td><td><code>[1, 0.5]</code></td></tr>
</table>

### Update Shape boundElements

Shapes must list arrows in their `boundElements` alongside text:

```json
{
  "id": "cloud-workflows",
  "boundElements": [
    { "type": "text", "id": "cloud-workflows-text" },
    { "type": "arrow", "id": "arrow-workflow-convert" }
  ]
}
```

## Bidirectional Arrows

```json
{
  "type": "arrow",
  "startArrowhead": "arrow",
  "endArrowhead": "arrow"
}
```

Arrowhead options: `null`, `"arrow"`, `"bar"`, `"dot"`, `"triangle"`

## Arrow Labels

Position standalone text near arrow midpoint:

```json
{
  "id": "arrow-api-db-label",
  "type": "text",
  "x": 305,
  "y": 245,
  "text": "SQL",
  "fontSize": 12,
  "containerId": null,
  "backgroundColor": "#ffffff"
}
```

**Positioning:** Vertical: `label.y = arrow.y + (total_height / 2)`. Horizontal: `label.x = arrow.x + (total_width / 2)`. L-shaped: position at corner or longest segment midpoint.

## Width/Height Calculation

Arrow `width` and `height` = bounding box of path:

```
points = [[0, 0], [-440, 0], [-440, 70]]  -> width=440, height=70
points = [[0, 0], [50, 0], [50, -125], [20, -125]]  -> width=50, height=125
```
