# Color Palette & Brand Style

**This is the single source of truth for all colors and brand-specific styles.** To customize diagrams for your own brand, edit this file — everything else in the skill is universal.

---

## Brand Palette Reference

| Name | Hex | Use |
|------|-----|-----|
| Vanta Purple | `#AC55FF` | Primary brand color — dominant fills, key nodes |
| Vanta Dark Purple | `#240642` | Strokes, headings, text on light backgrounds |
| Vanta White | `#F8F4F3` | Canvas background, text on dark fills |
| Vanta Red | `#F45B5B` | Errors, warnings, destructive paths |
| Vanta Yellow | `#FFBE0F` | Decisions, triggers, caution states |
| Vanta Green | `#09C639` | Success, end states, positive outcomes |

---

## Shape Colors (Semantic)

Colors encode meaning, not decoration. Each semantic purpose has a fill/stroke pair.

| Semantic Purpose | Fill | Stroke |
|------------------|------|--------|
| Primary/Neutral | `#AC55FF` | `#240642` |
| Secondary | `#D4AAFF` | `#240642` |
| Tertiary | `#E8D5FF` | `#7A3BB5` |
| Start/Trigger | `#FFF4CC` | `#CC9400` |
| End/Success | `#CDFADE` | `#057A25` |
| Warning/Reset | `#FDDFDF` | `#F45B5B` |
| Decision | `#FFF4CC` | `#CC9400` |
| AI/LLM | `#E8D5FF` | `#AC55FF` |
| Inactive/Disabled | `#F8F4F3` | `#7A3BB5` (use dashed stroke) |
| Error | `#F45B5B` | `#C02828` |

**Rule**: Always pair a darker stroke with a lighter fill for contrast.

---

## Text Colors (Hierarchy)

Use color on free-floating text to create visual hierarchy without containers.

| Level | Color | Use For |
|-------|-------|---------|
| Title | `#240642` | Section headings, major labels |
| Subtitle | `#7A3BB5` | Subheadings, secondary labels |
| Body/Detail | `#64748b` | Descriptions, annotations, metadata |
| On light fills | `#240642` | Text inside light-colored shapes |
| On dark fills | `#F8F4F3` | Text inside dark-colored shapes |

---

## Evidence Artifact Colors

Used for code snippets, data examples, and other concrete evidence inside technical diagrams.

| Artifact | Background | Text Color |
|----------|-----------|------------|
| Code snippet | `#240642` | Syntax-colored (language-appropriate) |
| JSON/data example | `#240642` | `#09C639` (Vanta Green) |

---

## Default Stroke & Line Colors

| Element | Color |
|---------|-------|
| Arrows | Use the stroke color of the source element's semantic purpose |
| Structural lines (dividers, trees, timelines) | `#240642` or `#64748b` |
| Marker dots (fill + stroke) | `#AC55FF` |

---

## Background

| Property | Value |
|----------|-------|
| Canvas background | `#F8F4F3` |
