# Prompt: Get Open Work Items (Table + Daily Snapshot)

## Context
You are helping retrieve Azure DevOps Work Items that are currently open, with concise and auditable output.

Fixed configuration:
- Organization URL: https://dev.azure.com/cat-digital
- Default project: Cat Digital
- Query mode: WIQL (explicitly requested non-IDs retrieval)
- Snapshot folder: outputs/daily

## Inputs
- Project (default: `Cat Digital`):
- Authentication mode: Entra token or PAT alias reference
- Assigned To filter (required prompt question, default: `profiles/default.md -> Username alias`, fallback: `@Me`):
- Additional filters (optional): Area Path, Iteration Path, Work Item Type
- Open states (default): `New`, `Active`, `In Progress`
- Snapshot date (default): current date in `YYYY-MM-DD`

## Constraints
- Do not expose secrets or tokens.
- Validate missing inputs before executing.
- Exclude closed states (`Closed`, `Done`, `Resolved`, `Removed`).
- Use only auditable fields in output.
- Render results as a markdown table.
- Save a persistent daily snapshot file using date suffix.
- If IDs are provided manually for any post-filtering step, validate they are numeric.

## Task
1. Ask explicitly: `Which assigned user should be used?`.
2. If no user is provided, use `profiles/default.md -> Username alias`.
3. If profile alias is empty, set `Assigned To = @Me`.
4. Validate required inputs and resolve defaults.
5. Build WIQL for open work items only.
6. Retrieve matching work items with fields:
   - `System.Id`
   - `System.WorkItemType`
   - `System.Title`
   - `System.State`
   - `System.AssignedTo`
   - `System.ChangedDate`
7. Render a markdown table sorted by `System.ChangedDate` descending.
8. Save the same content to a daily file:
   - `outputs/daily/open-work-items-<YYYY-MM-DD>.md`
9. Return summary counts and file path.

## Output Format
### Summary
- Project:
- Total open work items:
- States included:
- Generated at (UTC):

### Open Work Items
| ID | Type | Title | State | Assigned To | Changed Date |
|---|---|---|---|---|---|

### File Output
- Folder: `outputs/daily`
- File: `open-work-items-<YYYY-MM-DD>.md`
- Full path: `outputs/daily/open-work-items-<YYYY-MM-DD>.md`

## Validation Checklist
- [ ] Organization URL is `https://dev.azure.com/cat-digital`
- [ ] Project is `Cat Digital` (or explicitly provided)
- [ ] Assigned user was requested and defaulted to profile alias (or `@Me` fallback)
- [ ] Closed states are excluded
- [ ] Output is a markdown table
- [ ] Daily snapshot file was generated with today date
- [ ] No secrets were displayed
