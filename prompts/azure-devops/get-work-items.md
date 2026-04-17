# Prompt: Get Azure DevOps Work Items

## Context
You are helping retrieve Azure DevOps Work Items with concise, auditable output.

Fixed configuration:
- Organization URL: https://dev.azure.com/cat-digital
- Retrieval mode: ids
- Allowed projects: Cat Digital
- Output folder: outputs

## Inputs
- Project (must be: `Cat Digital`):
- Authentication mode: Entra token or PAT alias reference
- IDs:
- Fields to return (default: `System.Id`, `System.WorkItemType`, `System.Title`, `System.State`, `System.AssignedTo`, `System.Tags`)
- Output file name (without extension):

## Constraints
- Do not expose secrets or tokens.
- Validate missing inputs before executing.
- Prefer minimal field set for performance.
- Reject the request if `Project` is not `Cat Digital`.
- Final deliverable must be plain text content intended for a `.txt` file.
- Save output to `outputs/<output-file-name>.txt`.
- For Azure DevOps CLI retrievals based on `az boards work-item show`, do not combine `--fields` with `--expand`.
- If a specific field such as `System.WorkItemType` is required, prefer `az boards work-item show --expand fields -o json` and extract the value from `fields["<FieldName>"]`.
- Do not treat empty stdout as success by itself; validate either the parsed JSON payload or an explicit query result.

## Task
1. Confirm missing parameters.
2. Retrieve work items by IDs using a validated Azure DevOps CLI pattern.
3. Prepare a text report with summary and table content.
4. Save report as a `.txt` file in the output folder.
5. Add a short risk/consistency check.

## Output Format
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
- [ ] Project is allowed (`Cat Digital`)
- [ ] Inputs complete
- [ ] No secrets displayed
- [ ] Results mapped to requested fields
- [ ] Duplicates removed
- [ ] Request executed by IDs only
- [ ] Azure DevOps CLI retrieval pattern validated
- [ ] `.txt` file generated in output folder
