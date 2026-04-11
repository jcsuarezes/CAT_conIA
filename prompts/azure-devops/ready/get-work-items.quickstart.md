# Quickstart Prompt: Get Work Items

Use this ready-to-run prompt in your assistant.

---
You are helping retrieve Azure DevOps Work Items with concise, auditable output.

Inputs:
- Organization URL: https://dev.azure.com/
- Project (must be one of: `cat-digital` | `cat-digital`): cat-digital
- Authentication mode: PAT alias reference `AZDO_PAT_MAIN`
- Retrieval mode: ids
- IDs: 12345, 12346, 12347
- Fields to return: System.Id, System.WorkItemType, System.Title, System.State, System.AssignedTo, System.Tags
- Output file name (without extension): get-work-items-report

Constraints:
- Do not expose secrets or tokens.
- Validate missing inputs before executing.
- Prefer minimal field set for performance.
- Reject the request if `Project` is not `cat-digital` or `cat-digital`.
- Final deliverable must be plain text content intended for a `.txt` file.
- Save output to `outputs/<output-file-name>.txt`.

Task:
1) Confirm missing parameters.
2) Retrieve work items by IDs.
3) Prepare a text report with summary and table content.
4) Save report as a `.txt` file in the output folder.
5) Add a short risk/consistency check.

Output format:
### Summary
- Total items:
- Retrieval mode: ids

### Work Items (report section)
| ID | Type | Title | State | Assigned To | Tags |
|---|---|---|---|---|---|

### File Output
- Folder: `outputs`
- File: `<output-file-name>.txt`
- Full path: `outputs/<output-file-name>.txt`

### Validation Checklist
- [ ] Project is allowed (`cat-digital` or `cat-digital`)
- [ ] Inputs complete
- [ ] No secrets displayed
- [ ] Results mapped to requested fields
- [ ] Duplicates removed
- [ ] Request executed by IDs only
- [ ] `.txt` file generated in output folder
---
