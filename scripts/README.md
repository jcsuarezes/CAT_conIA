# Scripts Policy (Support/Legacy)

This folder is treated as operational support or legacy automation.

## Policy
- The framework is prompt-first: `prompts/azure-devops/` is the primary source of process logic.
- Do not add one-off scripts per story, issue, or user story type unless explicitly requested.
- Prefer reusable prompt guidance first; add automation only when prompts are not sufficient.
- If automation is required, prefer one reusable flow over multiple scenario-specific scripts.
- Every new script or major script change must be logged in `changelog/prompts-history.md` with:
  - reason,
  - owner,
  - expected retirement date.

## Maintenance
- If a script conflicts with prompt guidance, prompt guidance wins.
- Refactor or retire scripts that duplicate stable prompt behavior.
- Keep script output auditable and avoid secrets in files.
