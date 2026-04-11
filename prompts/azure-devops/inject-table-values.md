# Prompt: Inject Table Values into Work Items

## Context
You are formatting and injecting structured markdown content (tables/checklists) into Azure DevOps work item text fields.

Fixed configuration:
- Organization URL: https://dev.azure.com/
- Default project: Cat Digital
- Allowed projects: cat-digital, cat-digital
- Output folder: outputs

## Inputs
- Project (must be one of: `cat-digital` | `cat-digital`):
- Target work item IDs:
- Target field (for example: `System.Description` or comments):
- Table content (required, markdown table):
- Required columns:
- Include checklist: `yes/no`
- Style constraints (short, executive, technical):
- Output file name (without extension):

### Table Template (fill and paste)
```md
| Item | Status | Owner | Due Date |
|---|---|---|---|
| Example item | In progress | Name | 2026-03-01 |
```

## Constraints
- Output valid markdown only.
- Avoid HTML unless explicitly requested.
- Keep table width practical and readable.
- Reject the request if `Project` is not `cat-digital` or `cat-digital`.
- Reject the request if `Table content` is missing or not a valid markdown table.
- Final deliverable must be plain text content intended for a `.txt` file.
- Save output to `outputs/<output-file-name>.txt`.

## Task
1. Validate `Table content` structure (header row, separator row, and at least one data row).
2. Normalize table data into required columns.
3. Optionally append checklist.
4. Generate a plain text report and save it as a `.txt` file in the output folder.
5. Provide file path and a short preview.

## Output Format
### Normalized Data
| Column 1 | Column 2 | Column 3 |
|---|---|---|

### Text Report Content (`.txt`)
```text
Project: <project>
Work Item IDs: <ids>
Target Field: <field>

Table:
| ... |
| ... |

Checklist:
- [ ] ...
```

### File Output
- Folder: `outputs`
- File: `<output-file-name>.txt`
- Full path: `outputs/<output-file-name>.txt`

### Preview Guidance
- Where to insert:
- Expected rendering:
- Truncation risks:

### Validation Checklist
- [ ] Project is allowed (`cat-digital` or `cat-digital`)
- [ ] Table content provided
- [ ] Table markdown structure valid
- [ ] Required columns present
- [ ] Markdown syntax valid
- [ ] No sensitive data included
- [ ] `.txt` file generated in output folder
