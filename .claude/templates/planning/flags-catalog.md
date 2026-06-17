# Feature Flags & Config — {{Feature Name}}
feature: {{feature-slug}}  |  owner: config-manager  |  consumes: prd.md, design-doc.md
last-revised: {{YYYY-MM-DD}}
<!-- Flags, env, rollout. Secrets referenced by key name only — never values. -->

## Flags
| Flag | Default | Gates | Rollout plan |
|---|---|---|---|
| {{flag_name}} | {{off/on}} | {{what it gates}} | {{staged/canary/etc}} |

## Environment variables
| Var | Purpose | Secret? (key name) |
|---|---|---|
| {{VAR}} | {{}} | {{secrets-store key or "no"}} |

## Rollout status  <!-- updated during delivery -->
- {{flag}}: {{planned|enabled in <env>}}
