# Prompt: Get Open Work Items By Assignee (Daily Snapshot)

## Context
You are helping retrieve Azure DevOps Work Items assigned to a specific user, excluding closed states, with auditable output and a daily persistent snapshot file.

Fixed configuration:
- Organization URL: `https://dev.azure.com/cat-digital`
- Default project: `Cat Digital`
- Output folder: `outputs/daily`

## Inputs
- Project (default: `Cat Digital`)
- Authentication mode: Entra token or PAT alias reference
- Assigned To (required question; if omitted use `profiles/default.md -> Username alias`)
- Snapshot date (default: current date in `YYYY-MM-DD`)
- Fields (default): `System.Id`, `System.WorkItemType`, `System.Title`, `System.State`, `System.AssignedTo`, `System.ChangedDate`

## Constraints
- Do not expose secrets or tokens.
- Do not assume missing required inputs; ask explicitly.
- Use official Azure DevOps terminology.
- Retrieval mode exception: WIQL is allowed for this prompt because filtering by assignee and open states is explicitly required.
- Exclude closed states: `Closed`, `Done`, `Resolved`, `Removed`.
- Render output as a markdown table.
- Save the same output to `outputs/daily/open-work-items-<assignee-slug>-<YYYY-MM-DD>.md`.

## Task
1. Ask: `Which assigned user should be used?`
2. If no value is provided, use `profiles/default.md -> Username alias`.
3. If profile alias is empty, ask again and do not continue until a value is provided.
4. Build WIQL using project, assignee, and open-state filters only.
5. Retrieve matching Work Items and map only requested fields.
6. Sort by `System.ChangedDate` descending.
7. Return results in a markdown table.
8. Save a daily snapshot file with a normalized assignee slug.
9. Return summary + file path.

## Output Format
### Summary
- Organization URL: `https://dev.azure.com/cat-digital`
- Project:
- Assigned To:
- Total open work items:
- Generated at (UTC):

### Open Work Items
| ID | Type | Title | State | Assigned To | Changed Date |
|---:|---|---|---|---|---|

### File Output
- Folder: `outputs/daily`
- File: `open-work-items-<assignee-slug>-<YYYY-MM-DD>.md`
- Full path: `outputs/daily/open-work-items-<assignee-slug>-<YYYY-MM-DD>.md`

## Validation Checklist
- [ ] Organization URL is `https://dev.azure.com/cat-digital`
- [ ] Project is resolved (default `Cat Digital` if omitted)
- [ ] Assigned user was explicitly requested
- [ ] Closed states were excluded (`Closed`, `Done`, `Resolved`, `Removed`)
- [ ] Output is a markdown table
- [ ] Daily snapshot file was generated
- [ ] No secrets were displayed
