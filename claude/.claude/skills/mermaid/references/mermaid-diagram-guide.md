# Mermaid Diagram Reference Guide

This reference provides comprehensive guidance on creating effective Mermaid diagrams for design documents.

---

## Diagram Type Selection Matrix

| When You Need To... | Use This Diagram | Best For |
|---------------------|------------------|----------|
| Show system boundaries and external actors | C4 Context | System context, stakeholder view |
| Document API calls and timing | Sequence Diagram | API flows, interactions, temporal behavior |
| Model object relationships and inheritance | Class Diagram | OOP design, code structure |
| Visualize database schema | ER Diagram | Data model, relationships |
| Show state transitions and lifecycle | State Diagram | Workflows, status changes |
| Document decision flows and algorithms | Flowchart | Business logic, processes |
| Map hierarchical concepts | Mind Map | Brainstorming, concept organization |
| Track project timeline | Gantt Chart | Project planning, milestones |
| Capture user experience | User Journey | UX flows, user interactions |
| Show infrastructure components | Architecture Diagram | Deployment, infrastructure |

---

## 1. C4 Context Diagrams

**Purpose:** Show system boundaries, users, and external dependencies

**When to use:**
- System overview
- Stakeholder presentations
- Architecture documentation

**Syntax:**
```mermaid
C4Context
    title System Context for [System Name]

    Person(personAlias, "Person Name", "Role description")
    System(systemAlias, "System Name", "System description")
    System_Ext(externalAlias, "External System", "External description")
    SystemDb(dbAlias, "Database", "Database description")

    Rel(personAlias, systemAlias, "Uses", "HTTPS")
    Rel(systemAlias, externalAlias, "Calls", "REST API")
    Rel(systemAlias, dbAlias, "Reads/Writes", "SQL")
```

**Best Practices:**
- Limit to 5-7 systems for clarity
- Focus on key external dependencies
- Use consistent naming (nouns for systems, verbs for relationships)
- Include protocol information in relationship labels

---

## 2. Sequence Diagrams

**Purpose:** Show interactions between components over time

**When to use:**
- API documentation
- Request/response flows
- Authentication flows
- Error scenarios

**Syntax:**
```mermaid
sequenceDiagram
    participant Client
    participant Server
    participant Database

    Client->>Server: POST /api/resource
    activate Server
    Server->>Database: INSERT query
    activate Database
    Database-->>Server: Success
    deactivate Database
    Server-->>Client: 201 Created
    deactivate Server

    Note over Client,Server: Authentication required

    alt Success Case
        Client->>Server: Valid Request
        Server-->>Client: 200 OK
    else Error Case
        Client->>Server: Invalid Request
        Server-->>Client: 400 Bad Request
    end
```

**Best Practices:**
- Order participants left-to-right by interaction flow
- Use activation boxes for processing time
- Include both happy path and error scenarios
- Add notes for important context
- Use alt/opt/loop for conditional logic

**Common Patterns:**
```mermaid
sequenceDiagram
    %% Request-Response
    A->>B: Request
    B-->>A: Response

    %% Synchronous
    A->>B: Sync Call
    activate B
    B-->>A: Result
    deactivate B

    %% Asynchronous
    A->>Queue: Publish Event
    Queue->>B: Consume Event
```

---

## 3. Class Diagrams

**Purpose:** Model object-oriented structure and relationships

**When to use:**
- OOP design documentation
- Code architecture
- Domain model

**Syntax:**
```mermaid
classDiagram
    class Animal {
        +String name
        +int age
        +makeSound() void
        -metabolize() void
    }

    class Dog {
        +String breed
        +bark() void
    }

    class Cat {
        +String color
        +meow() void
    }

    Animal <|-- Dog : inherits
    Animal <|-- Cat : inherits
    Dog "1" --> "*" Toy : has
    Cat "1" --> "1" Owner : belongs to

    <<interface>> Flyable
    Bird ..|> Flyable : implements
```

**Relationships:**
- `<|--` : Inheritance
- `*--` : Composition
- `o--` : Aggregation
- `-->` : Association
- `..>` : Dependency
- `..|>` : Realization

**Visibility:**
- `+` : Public
- `-` : Private
- `#` : Protected
- `~` : Package/Internal

---

## 4. ER Diagrams

**Purpose:** Model database schema and relationships

**When to use:**
- Database design
- Data architecture
- Schema documentation

**Syntax:**
```mermaid
erDiagram
    CUSTOMER ||--o{ ORDER : places
    CUSTOMER {
        int id PK "Primary key"
        string email UK "Unique constraint"
        string name
        date created_at
    }

    ORDER ||--|{ ORDER_ITEM : contains
    ORDER {
        int id PK
        int customer_id FK
        decimal total
        enum status "pending, shipped, delivered"
    }

    PRODUCT ||--o{ ORDER_ITEM : "ordered in"
    PRODUCT {
        int id PK
        string sku UK
        string name
        decimal price
    }

    ORDER_ITEM {
        int id PK
        int order_id FK
        int product_id FK
        int quantity
    }
```

**Cardinality:**
- `||--||` : One to one
- `||--o{` : One to zero or more
- `||--|{` : One to one or more
- `}o--o{` : Zero or more to zero or more

**Best Practices:**
- Mark primary keys with "PK"
- Mark foreign keys with "FK"
- Mark unique constraints with "UK"
- Add field descriptions for clarity
- Include enum values in descriptions

---

## 5. State Diagrams

**Purpose:** Model state transitions and lifecycles

**When to use:**
- Workflow documentation
- Status management
- Lifecycle modeling

**Syntax:**
```mermaid
stateDiagram-v2
    [*] --> Draft
    Draft --> Review : Submit
    Review --> Approved : Approve
    Review --> Draft : Reject
    Approved --> Published : Publish
    Published --> Archived : Archive
    Archived --> [*]

    state Review {
        [*] --> PendingReview
        PendingReview --> InReview : Assign
        InReview --> [*]
    }

    note right of Approved
        Requires admin approval
    end note
```

**Best Practices:**
- Start with `[*]` for initial state
- End with `[*]` for final state
- Use nested states for complex workflows
- Add notes for important transitions
- Keep transitions labeled with trigger events

---

## 6. Flowcharts

**Purpose:** Document processes, algorithms, and decision logic

**When to use:**
- Business logic documentation
- Process flows
- Algorithm explanation

**Syntax:**
```mermaid
flowchart TD
    Start([Start])
    Input[/User Input/]
    Process[Process Data]
    Decision{Valid?}
    Success[/Success Message/]
    Error[/Error Message/]
    End([End])

    Start --> Input
    Input --> Process
    Process --> Decision
    Decision -->|Yes| Success
    Decision -->|No| Error
    Success --> End
    Error --> Input

    subgraph "Validation"
        Decision
    end
```
**Node shape selection**
1. Check if the node has a semantic match to one of the new shapes in the table below.
2. If not, fallback to the Basic Node Shapes set.

**Basic Node Shapes (classic shorthand):**
- `[Text]` : Rectangle (process)
- `([Text])` : Stadium (start/end)
- `{Text}` : Diamond (decision)
- `[/Text/]` : Parallelogram (input/output)
- `[(Text)]` : Cylinder (database)
- `((Text))` : Circle
- `>Text]` : Asymmetric (flag)

**Complete List of New Shapes (v11.3.0+):**

Use the `@{ shape: <short-name> }` syntax, e.g. `A@{ shape: bolt, label: "Lightning" }`.

<table>
<tr><th>Semantic Name</th><th>Shape Name</th><th>Short Name</th><th>Description</th></tr>
<tr><td>Bang</td><td>Bang</td><td><code>bang</code></td><td>Bang</td></tr>
<tr><td>Card</td><td>Notched Rectangle</td><td><code>notch-rect</code></td><td>Represents a card</td></tr>
<tr><td>Cloud</td><td>Cloud</td><td><code>cloud</code></td><td>Cloud</td></tr>
<tr><td>Collate</td><td>Hourglass</td><td><code>hourglass</code></td><td>Collate operation</td></tr>
<tr><td>Com Link</td><td>Lightning Bolt</td><td><code>bolt</code></td><td>Communication link</td></tr>
<tr><td>Comment</td><td>Curly Brace</td><td><code>brace</code></td><td>Adds a comment</td></tr>
<tr><td>Comment Right</td><td>Curly Brace</td><td><code>brace-r</code></td><td>Adds a comment (right)</td></tr>
<tr><td>Comment (both)</td><td>Curly Braces</td><td><code>braces</code></td><td>Adds a comment (both sides)</td></tr>
<tr><td>Data Input/Output</td><td>Lean Right</td><td><code>lean-r</code></td><td>Input or output</td></tr>
<tr><td>Data Input/Output</td><td>Lean Left</td><td><code>lean-l</code></td><td>Output or input</td></tr>
<tr><td>Database</td><td>Cylinder</td><td><code>cyl</code></td><td>Database storage</td></tr>
<tr><td>Decision</td><td>Diamond</td><td><code>diam</code></td><td>Decision-making step</td></tr>
<tr><td>Delay</td><td>Half-Rounded Rectangle</td><td><code>delay</code></td><td>Represents a delay</td></tr>
<tr><td>Direct Access Storage</td><td>Horizontal Cylinder</td><td><code>h-cyl</code></td><td>Direct access storage, queues</td></tr>
<tr><td>Disk Storage</td><td>Lined Cylinder</td><td><code>lin-cyl</code></td><td>Disk storage</td></tr>
<tr><td>Display</td><td>Curved Trapezoid</td><td><code>curv-trap</code></td><td>Represents a display</td></tr>
<tr><td>Divided Process</td><td>Divided Rectangle</td><td><code>div-rect</code></td><td>Divided process</td></tr>
<tr><td>Document</td><td>Document</td><td><code>doc</code></td><td>Represents a document</td></tr>
<tr><td>Event</td><td>Rounded Rectangle</td><td><code>rounded</code></td><td>Represents an event</td></tr>
<tr><td>Extract</td><td>Triangle</td><td><code>tri</code></td><td>Extraction process</td></tr>
<tr><td>Fork/Join</td><td>Filled Rectangle</td><td><code>fork</code></td><td>Fork or join in process flow</td></tr>
<tr><td>Internal Storage</td><td>Window Pane</td><td><code>win-pane</code></td><td>Internal storage</td></tr>
<tr><td>Junction</td><td>Filled Circle</td><td><code>f-circ</code></td><td>Junction point</td></tr>
<tr><td>Lined Document</td><td>Lined Document</td><td><code>lin-doc</code></td><td>Lined document</td></tr>
<tr><td>Lined/Shaded Process</td><td>Lined Rectangle</td><td><code>lin-rect</code></td><td>Lined process</td></tr>
<tr><td>Loop Limit</td><td>Trapezoidal Pentagon</td><td><code>notch-pent</code></td><td>Loop limit step</td></tr>
<tr><td>Manual File</td><td>Flipped Triangle</td><td><code>flip-tri</code></td><td>Manual file operation</td></tr>
<tr><td>Manual Input</td><td>Sloped Rectangle</td><td><code>sl-rect</code></td><td>Manual input step</td></tr>
<tr><td>Manual Operation</td><td>Trapezoid Base Top</td><td><code>trap-t</code></td><td>Represents a manual task</td></tr>
<tr><td>Multi-Document</td><td>Stacked Document</td><td><code>docs</code></td><td>Multiple documents</td></tr>
<tr><td>Multi-Process</td><td>Stacked Rectangle</td><td><code>st-rect</code></td><td>Multiple processes</td></tr>
<tr><td>Odd</td><td>Odd</td><td><code>odd</code></td><td>Odd shape</td></tr>
<tr><td>Paper Tape</td><td>Flag</td><td><code>flag</code></td><td>Paper tape</td></tr>
<tr><td>Prepare Conditional</td><td>Hexagon</td><td><code>hex</code></td><td>Preparation or condition step</td></tr>
<tr><td>Priority Action</td><td>Trapezoid Base Bottom</td><td><code>trap-b</code></td><td>Priority action</td></tr>
<tr><td>Process</td><td>Rectangle</td><td><code>rect</code></td><td>Standard process</td></tr>
<tr><td>Start</td><td>Circle</td><td><code>circle</code></td><td>Starting point</td></tr>
<tr><td>Start (small)</td><td>Small Circle</td><td><code>sm-circ</code></td><td>Small starting point</td></tr>
<tr><td>Stop</td><td>Double Circle</td><td><code>dbl-circ</code></td><td>Stop point</td></tr>
<tr><td>Stop</td><td>Framed Circle</td><td><code>fr-circ</code></td><td>Stop point (framed)</td></tr>
<tr><td>Stored Data</td><td>Bow Tie Rectangle</td><td><code>bow-rect</code></td><td>Stored data</td></tr>
<tr><td>Subprocess</td><td>Framed Rectangle</td><td><code>fr-rect</code></td><td>Subprocess</td></tr>
<tr><td>Summary</td><td>Crossed Circle</td><td><code>cross-circ</code></td><td>Summary</td></tr>
<tr><td>Tagged Document</td><td>Tagged Document</td><td><code>tag-doc</code></td><td>Tagged document</td></tr>
<tr><td>Tagged Process</td><td>Tagged Rectangle</td><td><code>tag-rect</code></td><td>Tagged process</td></tr>
<tr><td>Terminal Point</td><td>Stadium</td><td><code>stadium</code></td><td>Terminal point</td></tr>
<tr><td>Text Block</td><td>Text Block</td><td><code>text</code></td><td>Text block</td></tr>
</table>

**Directions:**
- `TD` / `TB` : Top to bottom
- `BT` : Bottom to top
- `LR` : Left to right
- `RL` : Right to left

---

## 7. Gantt Charts

**Purpose:** Project planning and timeline visualization

**When to use:**
- Project schedules
- Milestone tracking
- Roadmap planning

**Syntax:**
```mermaid
gantt
    title Project Roadmap
    dateFormat YYYY-MM-DD
    section Phase 1
    Research           :done, r1, 2025-01-01, 30d
    Design            :active, d1, 2025-01-15, 45d
    section Phase 2
    Development       :dev1, after d1, 60d
    Testing          :test1, after dev1, 30d
    section Phase 3
    Deployment       :crit, deploy1, after test1, 15d
    Monitoring       :monitor1, after deploy1, 30d
```

**Keywords:**
- `done` : Completed task
- `active` : Currently in progress
- `crit` : Critical path
- `after [id]` : Dependency

---

## 8. User Journey Maps

**Purpose:** Document user experience and interactions

**When to use:**
- UX documentation
- User story mapping
- Experience design

**Syntax:**
```mermaid
journey
    title User Purchase Journey
    section Discovery
      Search for product: 5: User
      View details: 4: User
      Read reviews: 3: User
    section Decision
      Compare options: 3: User
      Add to cart: 5: User
    section Purchase
      Enter payment: 2: User
      Confirm order: 5: User
      Receive confirmation: 5: User, System
```

**Satisfaction Scores:**
- 5: Very satisfied
- 4: Satisfied
- 3: Neutral
- 2: Unsatisfied
- 1: Very unsatisfied

---

## Common Styling Patterns

### Subgraphs for Organization

```mermaid
graph TB
    subgraph "Frontend"
        UI[User Interface]
        Components[Components]
    end

    subgraph "Backend"
        API[API Layer]
        Database[(Database)]
    end

    UI --> API
    API --> Database
```

### Color Coding with High Contrast

**CRITICAL**: All Mermaid diagram styles MUST use high-contrast colors for accessibility.

**Rule**: Light backgrounds require dark text, dark backgrounds require light text.

✅ **Correct - High Contrast**:

```mermaid
graph LR
    A[Normal]
    B[Success]
    C[Warning]
    D[Error]

    style A fill:#F0F0F0,stroke:#333,color:black
    style B fill:#90EE90,stroke:#333,color:darkgreen
    style C fill:#FFD700,stroke:#333,color:black
    style D fill:#FF6B6B,stroke:#8B0000,color:white
```

**Using classDef (Recommended for consistency)**:

```mermaid
graph LR
    A[Normal]
    B[Success]
    C[Warning]
    D[Error]

    classDef normalStyle fill:#F0F0F0,stroke:#333,stroke-width:2px,color:black
    classDef successStyle fill:#90EE90,stroke:#2E7D2E,stroke-width:2px,color:darkgreen
    classDef warningStyle fill:#FFD700,stroke:#B8860B,stroke-width:2px,color:black
    classDef errorStyle fill:#FFB6C1,stroke:#DC143C,stroke-width:2px,color:black

    class A normalStyle
    class B successStyle
    class C warningStyle
    class D errorStyle
```

❌ **Incorrect - Poor Contrast**:

```mermaid
graph LR
    %% Missing color property - may be unreadable
    style B fill:#90EE90
    style C fill:#FFD700
    style D fill:#FF6B6B
```

**High-Contrast Color Palette**:

| State | Background Fill | Text Color | Stroke |
|-------|----------------|------------|--------|
| Normal | `#F0F0F0` | `color:black` | `#333` |
| Success | `#90EE90` | `color:darkgreen` | `#2E7D2E` |
| Warning | `#FFD700` | `color:black` | `#B8860B` |
| Error | `#FFB6C1` | `color:black` | `#DC143C` |
| Info | `#87CEEB` | `color:darkblue` | `#4682B4` |
| Public | `#FFE4B5` | `color:black` | `#FF8C00` |
| Private | `#E6E6FA` | `color:darkblue` | `#8A2BE2` |
| Dark | `#2C3E50` | `color:white` | `#34495E` |

### Link Styles

```mermaid
graph LR
    A --> B
    A -.-> C
    A ==> D

    linkStyle 0 stroke:#00ff00,stroke-width:2px
    linkStyle 1 stroke:#0000ff,stroke-width:2px
    linkStyle 2 stroke:#ff0000,stroke-width:4px
```

---

## Best Practices for Design Docs

### 1. Choose the Right Diagram

**Don't use:**
- Class diagrams for infrastructure
- Sequence diagrams for data models
- ER diagrams for workflows

**Do use:**
- The diagram type that best communicates your intent
- Multiple diagram types for different aspects
- Simpler diagrams over complex ones

### 2. Keep Diagrams Focused

**Bad:** One giant diagram showing everything
**Good:** Multiple focused diagrams showing specific aspects

**Guidelines:**
- Max 10-12 nodes per diagram
- Max 3-4 levels of nesting
- Break complex diagrams into multiple views

### 3. Use Consistent Naming

**Bad:**
```mermaid
graph LR
    usr --> sys
    system --> db1
```

**Good:**
```mermaid
graph LR
    User --> System
    System --> Database
```

### 4. Add Context

```mermaid
sequenceDiagram
    Note over Client,Server: OAuth 2.0 Authentication Flow

    Client->>AuthServer: Request Access Token
    Note right of AuthServer: Validates client credentials
    AuthServer-->>Client: Access Token (JWT)
```

### 5. Document Technical Decisions

```mermaid
graph TB
    A[Option A: REST API]
    B[Option B: GraphQL]
    C[Decision: REST API]

    note1[Pros: Simple, cacheable]
    note2[Cons: Over-fetching]

    C --> note1
    B --> note2
```

### 6. CRITICAL - Ensure High-Contrast Accessibility

**MANDATORY for ALL diagrams**:

Every diagram with custom styling MUST use high-contrast colors:

```mermaid
graph LR
    A[Component A]
    B[Component B]
    C[Component C]

    classDef primary fill:#90EE90,stroke:#333,stroke-width:2px,color:darkgreen
    classDef secondary fill:#FFD700,stroke:#333,stroke-width:2px,color:black
    classDef accent fill:#87CEEB,stroke:#333,stroke-width:2px,color:darkblue

    class A primary
    class B secondary
    class C accent
```

**Quick Accessibility Test**:
1. Can you easily read the text on each background color?
2. Would the diagram be readable if printed in grayscale?
3. Does every `classDef` include a `color:` property?

If answer is NO to any → Fix the contrast!

**Common Mistakes to Avoid**:
- ❌ `classDef myStyle fill:#FFD700` (missing `color:`)
- ❌ `style A fill:#F0F0F0,color:#E0E0E0` (light on light)
- ❌ `style B fill:#333,color:#222` (dark on dark)

**Always Include**:
- ✅ Explicit `color:` property in all `classDef` statements
- ✅ Explicit `color:` property in all `style` statements
- ✅ High-contrast combinations (see Color Coding section above)

---

## Syntax Validation Checklist

Before including a diagram, verify:

- [ ] All node IDs are unique
- [ ] All relationships use valid syntax
- [ ] Quotes are balanced in labels
- [ ] Special characters are escaped
- [ ] Subgraph syntax is correct
- [ ] No trailing commas
- [ ] Direction is specified (for flowcharts)
- [ ] Date format matches (for Gantt)
- [ ] **All `classDef` statements include `color:` property for high contrast**
- [ ] **All `style` statements include `color:` property for high contrast**
- [ ] **Text is readable on all background colors (accessibility test)**

---

## Common Errors and Fixes

### Error: "Parse error on line X"

**Cause:** Syntax error in Mermaid code

**Fix:**
- Check for missing quotes
- Verify relationship syntax
- Ensure all braces/parentheses match
- Remove trailing commas

### Error: Diagram doesn't render

**Cause:** Invalid node IDs or special characters

**Fix:**
- Use alphanumeric IDs (avoid spaces)
- Escape special characters in labels
- Use quotes for multi-word labels

### Error: Arrows pointing wrong direction

**Cause:** Wrong relationship syntax

**Fix:**
- `A-->B` : A to B
- `B<--A` : A to B (same as above)
- `A<-->B` : Bidirectional

---

## Quick Reference: When to Use Each Diagram

```mermaid
graph TB
    Start{What are you documenting?}
    Start -->|System boundaries| C4[C4 Context Diagram]
    Start -->|API interactions| Seq[Sequence Diagram]
    Start -->|Code structure| Class[Class Diagram]
    Start -->|Database| ER[ER Diagram]
    Start -->|Workflow/Status| State[State Diagram]
    Start -->|Process flow| Flow[Flowchart]
    Start -->|Timeline| Gantt[Gantt Chart]
    Start -->|User experience| Journey[User Journey]
    Start -->|Infrastructure| Arch[Architecture Diagram]
```

---

## Resources

- [Mermaid Official Docs](https://mermaid.js.org/)
- [Mermaid Live Editor](https://mermaid.live/)
- [C4 Model](https://c4model.com/)
