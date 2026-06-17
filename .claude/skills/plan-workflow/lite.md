# Plan profile — Lite

Small feature or internal tool.

**Planners that fire:** `product-manager` (◐ short PRD + stories), `solution-architect`
(◐ implementation notes only — no formal design-doc, but an ADR if a real decision is made),
`config-manager` (◐ env vars inline if needed), `backlog-planner` (✅ items + DoR).
**Skipped:** business-analyst, ux-researcher, ux-designer, security (inline self-check only),
data-analyst, data-engineer.

**Depth:**
- product-manager writes a short PRD and user stories.
- solution-architect writes implementation notes (not a full design-doc); records an ADR only for
  a genuinely durable decision. Security is a one-paragraph OWASP self-check folded into the notes.
- backlog-planner produces items with a full Definition of Ready.

**Gate:** default `review-on-open-issues`. One advisory checkpoint after the architecture notes.
