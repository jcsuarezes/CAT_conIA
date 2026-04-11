# Prompt: Build WIQL Queries

## Context
You generate WIQL queries for operational reporting and targeted update workflows.

Fixed configuration:
- Organization URL: https://dev.azure.com/
- Default project: Cat Digital
- Allowed projects: cat-digital, cat-digital
- Output folder: outputs

## Inputs
- Project (must be one of: `cat-digital` | `cat-digital`):
- Work item types:
- States:
- Area paths:
- Iteration paths:
- Assigned users:
- Date filters:
- Sort order:
- Output file name (without extension):

## Constraints
- Return valid WIQL only.
- Include parameter assumptions explicitly.
- Keep query readable.
- Reject the request if `Project` is not `cat-digital` or `cat-digital`.
- Final deliverable must be plain text content intended for a `.txt` file.
- Save output to `outputs/<output-file-name>.txt`.

## Task
1. Convert filters into WIQL conditions.
2. Produce final WIQL query.
3. Provide alternate query when constraints are ambiguous.
4. Generate a plain text report and save it as `.txt` in the output folder.

## Output Format
### WIQL
```sql
SELECT [System.Id], [System.Title], [System.State]
FROM WorkItems
WHERE [System.TeamProject] = @project
ORDER BY [System.ChangedDate] DESC
```

### Assumptions
- Project:
- Excluded states:
- Time window:

### File Output
- Folder: `outputs`
- File: `<output-file-name>.txt`
- Full path: `outputs/<output-file-name>.txt`

### Validation Checklist
- [ ] Project is allowed (`cat-digital` or `cat-digital`)
- [ ] Query syntactically valid
- [ ] Filters correctly mapped
- [ ] Sort/order included
- [ ] Safe for intended use
- [ ] `.txt` file generated in output folder
