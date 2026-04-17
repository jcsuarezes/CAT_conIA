# Prompt: Build WIQL Queries

## Context
You generate WIQL queries for operational reporting and targeted update workflows.

Fixed configuration:
- Organization URL: https://dev.azure.com/cat-digital
- Default project: Cat Digital
- Allowed projects: Cat Digital
- Output folder: outputs

## Inputs
- Project (must be: `Cat Digital`):
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
- Follow shared command guidance in `docs/validated-command-patterns.md`.
- Reject the request if `Project` is not `Cat Digital`.
- Final deliverable must be plain text content intended for a `.txt` file.
- Save output to `outputs/<output-file-name>.txt`.
- Do not generate ambiguous filters silently; if a filter can expand to multiple interpretations, return the primary WIQL plus an explicit alternate query.
- Prefer filters that are auditable from fields already named in the input set.

## Safe Query Design Rules
- Always include `[System.TeamProject] = @project`.
- Prefer explicit state lists over negative logic when the user names desired states.
- Prefer explicit `ORDER BY` clauses; default to `[System.ChangedDate] DESC` when the user does not provide a sort order.
- If Area Path or Iteration Path values may be partial or ambiguous, state the assumption explicitly and provide an alternate WIQL.
- If Assigned Users are supplied, normalize whether the intended operator is `=` or `IN` and document the choice.

## Validated WIQL Patterns

### Safe open-items pattern
```sql
SELECT [System.Id], [System.Title], [System.State]
FROM WorkItems
WHERE
	[System.TeamProject] = @project
	AND [System.State] IN ('New', 'Active', 'In Progress')
ORDER BY [System.ChangedDate] DESC
```

### Safe assignee pattern
```sql
SELECT [System.Id], [System.Title], [System.State]
FROM WorkItems
WHERE
	[System.TeamProject] = @project
	AND [System.AssignedTo] = 'user@cat.com'
	AND [System.State] IN ('New', 'Active', 'In Progress')
ORDER BY [System.ChangedDate] DESC
```

## Task
1. Convert filters into WIQL conditions.
2. Normalize ambiguous inputs before building the query, and document each assumption.
3. Produce final WIQL query.
4. Provide alternate query when constraints are ambiguous.
5. Generate a plain text report and save it as `.txt` in the output folder.

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
- Ambiguities resolved:
- Alternate query required: yes/no

### File Output
- Folder: `outputs`
- File: `<output-file-name>.txt`
- Full path: `outputs/<output-file-name>.txt`

### Validation Checklist
- [ ] Project is allowed (`Cat Digital`)
- [ ] Query syntactically valid
- [ ] Filters correctly mapped
- [ ] Sort/order included
- [ ] Ambiguous filters were documented or split into alternate WIQL
- [ ] Query follows validated WIQL patterns for this repo
- [ ] Safe for intended use
- [ ] `.txt` file generated in output folder
