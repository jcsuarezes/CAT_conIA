# Quickstart Prompt: Get Open Work Items (Daily Table)

Use this ready-to-run prompt in your assistant.

---
You are helping retrieve Azure DevOps Work Items that are currently open, with concise and auditable output.

Inputs:
- Organization URL: https://dev.azure.com/cat-digital
- Project: Cat Digital
- Authentication mode: PAT alias reference `AZDO_PAT_MAIN`
- Query mode: WIQL (open items only)
- Open states: New, Active, In Progress
- Assigned To filter: suarez.juan@cat.com (from `profiles/default.md`)
- Snapshot date: current date (YYYY-MM-DD)

Constraints:
- Do not expose secrets or tokens.
- Follow shared command guidance in `docs/validated-command-patterns.md`.
- Exclude closed states (Closed, Done, Resolved, Removed).
- Render results as a markdown table.
- Save output to `outputs/daily/open-work-items-<YYYY-MM-DD>.md`.
- Do not treat empty stdout as success by itself; validate the WIQL result set and the returned work item payload.

Task:
1) Ask: `Which assigned user should be used?`.
2) If omitted, use `profiles/default.md -> Username alias`.
3) If profile alias is empty, use `Assigned To = @Me`.
4) Validate inputs.
5) Execute WIQL and validate whether it returned zero or more IDs explicitly.
6) Retrieve open Work Items and validate that item count matches the resolved ID set.
7) Render a markdown table.
8) Save a daily snapshot file.

Output format:
### Summary
- Total open work items:
- Generated at (UTC):

### Open Work Items
| ID | Type | Title | State | Assigned To | Changed Date |
|---|---|---|---|---|---|

### File Output
- Folder: `outputs/daily`
- File: `open-work-items-<YYYY-MM-DD>.md`
- Full path: `outputs/daily/open-work-items-<YYYY-MM-DD>.md`

### Validation Checklist
- [ ] Organization URL is `https://dev.azure.com/cat-digital`
- [ ] Assigned user was requested and defaulted to profile alias (or `@Me` fallback)
- [ ] Closed states are excluded
- [ ] WIQL result was validated explicitly, including zero-result cases
- [ ] Retrieved item count matches the resolved ID set
- [ ] Table generated
- [ ] Daily file generated
- [ ] No secrets displayed
