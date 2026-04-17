# Prompt: Update Azure DevOps Work Items

## Context
You are applying controlled updates to Azure DevOps Work Items and must provide clear before/after traceability.

Fixed configuration:
- Organization URL: https://dev.azure.com/cat-digital
- Default project: Cat Digital
- Allowed projects: Cat Digital
- Output folder: outputs

## Inputs
- Project (must be: `Cat Digital`):
- Authentication mode: Entra token or PAT alias reference
- Work item IDs:
- Intended updates (field/value pairs):
- Update reason:
- Dry run: `true` or `false`
- Output file name (without extension):

## Constraints
- Never print credentials.
- Validate allowed fields before proposing update.
- Batch related field changes per work item.
- If any field is invalid, stop and report.
- Reject the request if `Project` is not `Cat Digital`.
- Final deliverable must be plain text content intended for a `.txt` file.
- Save output to `outputs/<output-file-name>.txt`.

## Task
1. Validate target IDs and fields.
2. Build per-item change plan.
3. If `dry run=true`, output planned changes only.
4. If execution is intended, return exact patch-intent structure and expected outcomes.
5. Generate a plain text report and save it as `.txt` in the output folder.

## Output Format
### Change Plan
| Work Item ID | Field | Old Value | New Value | Reason |
|---|---|---|---|---|

### Execution Notes
- Dry run:
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
