# [Project / feature name] — Recon

**Problem:** [one or two sentences — the problem, not the solution. If it can't be said this tightly, the scope is still tangled; say so rather than accepting a paragraph.]

**Explorability:** `settled ●───────○ wide open` [drop the dot where this sits; it can differ per thread and can drift over time]

**Started:** [date] · **Updated:** [date]

---

## Known Knowns — confirmed facts & constraints
> RFC → *Context & Constraints*

| Fact / constraint | Durability | As of | Notes |
|---|---|---|---|
| | durable · perishable · code-derived | date, or commit SHA if code-derived | |

## Known Unknowns — open questions
> RFC → *Open Questions* · spike backlog

| Question | Why it matters (what it blocks / decides) | How we'll resolve | Owner | Status |
|---|---|---|---|---|
| | | spike · research · ask [who] | | open · resolving · resolved → [answer] |

## Unknown Knowns — surfaced assumptions
> RFC → *Explicit premises* · monitoring

| Assumption (your words) | Holds while… (validity condition) | Revisit if… (tripwire) | Confidence |
|---|---|---|---|
| | | | high · medium · low |

## Unknown Unknowns — surfaced blind spots
> pre-mortem · risk register · monitoring

| Blind spot / failure class | How surfaced (specimen / prior art) | Watch signal | Severity if it lands |
|---|---|---|---|
| | observation, with provenance | | |

## Roads Not Taken — rejected options
> RFC → *Alternatives Considered* · **durable — persist across sessions**

| Option | Why rejected (your words) | What would make us revisit |
|---|---|---|
| | | |

---

## Changelog
> Every reopen leaves a trace here. The *Why* is the load-bearing column — it's what lets a future read pick up the thread. Session ID when the harness exposes it; the human-readable summary always.

| When | What changed | Why | Session | Commit |
|---|---|---|---|---|
| [date] | [e.g. port-collision Q resolved → moved to Known Knowns] | [the reasoning] | [`sess_…` if available] | [`a3f9c21` if code-related] |
