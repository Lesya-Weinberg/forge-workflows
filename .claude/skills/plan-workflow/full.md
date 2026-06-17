# Plan profile — Full

New product, new subsystem, or regulatory scope. Maximum depth.

**Every planner fires at full depth.** product-manager adds compliance hooks and a dependency map;
business-analyst adds compliance mapping; ux-researcher includes primary research artifacts;
ux-designer adds a usability test plan; solution-architect runs a formal architecture review and
records ADRs for every significant decision; security-engineer produces a pen-test plan and
incident playbooks; data-analyst defines ML/BI requirements; data-engineer builds the full
pipeline + data catalog; config-manager defines compliance-grade access controls.

**Gate policy is typically `review-all`** for the first pass of a new subsystem. Treat ADRs and
compliance findings as the highest-scrutiny artifacts. All schema work is queued as migrations for
human execution. Expect this plan to span multiple sessions — close each with a full state rewrite.
