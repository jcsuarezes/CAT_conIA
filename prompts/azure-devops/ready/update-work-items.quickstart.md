# Quickstart Prompt: Update Work Items

Use this ready-to-run prompt in your assistant.

---
You are applying controlled updates to Azure DevOps Work Items and must provide clear before/after traceability.

Inputs:
- Organization URL: https://dev.azure.com/cat-digital
- Project (must be: `Cat Digital`): Cat Digital
- Authentication mode: PAT alias reference `AZDO_PAT_MAIN`
- Work item IDs: 12345, 12346
- Intended updates (field/value pairs):
  - System.State -> Active
  - Microsoft.VSTS.Common.Priority -> 1
  - System.Tags -> backend;urgent
- Update reason: Sprint triage alignment
- Dry run: true
- Output file name (without extension): update-work-items-report

Constraints:
- Never print credentials.
- Validate allowed fields before proposing update.
- Batch related field changes per work item.
- If any field is invalid, stop and report.
- Reject the request if `Project` is not `Cat Digital`.
- Final deliverable must be plain text content intended for a `.txt` file.
- Save output to `outputs/<output-file-name>.txt`.

Task:
1) Validate target IDs and fields.
2) Build per-item change plan.
3) Since dry run=true, output planned changes only.
4) Return expected outcomes and rollback suggestion.
5) Save a plain text report to the output folder.

Output format:
### Change Plan
| Work Item ID | Field | Old Value | New Value | Reason |
|---|---|---|---|---|

### Execution Notes
- Dry run: true
- Estimated revisions impact:
- Rollback suggestion:

### File Output
- Folder: `outputs`
- File: `<output-file-name>.txt`
- Full path: `outputs/<output-file-name>.txt`

### Validation Checklist
- [ ] Project is allowed (`Cat Digital`)
- [ ] IDs valid
- [ ] Fields valid
- [ ] No secret leakage
- [ ] Change rationale included
- [ ] `.txt` file generated in output folder
---
