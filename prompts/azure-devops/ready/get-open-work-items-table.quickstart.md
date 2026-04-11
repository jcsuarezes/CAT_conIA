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
- Exclude closed states (Closed, Done, Resolved, Removed).
- Render results as a markdown table.
- Save output to `outputs/daily/open-work-items-<YYYY-MM-DD>.md`.

Task:
1) Ask: `Which assigned user should be used?`.
2) If omitted, use `profiles/default.md -> Username alias`.
3) If profile alias is empty, use `Assigned To = @Me`.
4) Validate inputs.
5) Query open Work Items only.
6) Render a markdown table.
7) Save a daily snapshot file.

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
- [ ] Table generated
- [ ] Daily file generated
- [ ] No secrets displayed
---
