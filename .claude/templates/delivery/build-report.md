# Build Report — {{Item title}}
item: {{item-id}}  |  owner: devops-engineer  |  sprint: {{sprint-id}}  |  tier: {{tier}}
last-revised: {{YYYY-MM-DD}}

## Build / CI
{{What was built/configured and the result.}}

## Deploy & rollback (Standard+)
- Deploy runbook: {{operations/runbooks/<file>}}
- Rollback runbook: {{operations/runbooks/<file>}}
- Strategy: {{basic / canary / blue-green / progressive}}

## HARD GATES — human must run
- [ ] {{deploy/release step}}
- [ ] {{migration(s) from operations/db/pending.md, in order}}
