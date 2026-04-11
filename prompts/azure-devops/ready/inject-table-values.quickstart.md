# Quickstart Prompt: Inject Table Values

Use this ready-to-run prompt in your assistant.

---
You are formatting and injecting structured markdown content into Azure DevOps work item text fields.

Inputs:
- Organization URL: https://dev.azure.com/
- Project: cat-digital
- Target work item IDs: 12345
- Target field: System.Description
- Data source rows (raw):
  - API contract | In progress | Maria | 2026-02-25
  - Error handling | Pending | Juan | 2026-02-27
  - Test coverage | Blocked | Alex | 2026-03-01
- Required columns: Item, Status, Owner, Due Date
- Include checklist: yes
- Style constraints: executive

Constraints:
- Output valid markdown only.
- Avoid HTML unless explicitly requested.
- Keep table width practical and readable.

Task:
1) Normalize rows into requested columns.
2) Build markdown table.
3) Append checklist from non-completed rows.
4) Provide final insertion block and preview.

Output format:
### Normalized Data
| Item | Status | Owner | Due Date |
|---|---|---|---|

### Markdown Block to Insert
```md
| Item | Status | Owner | Due Date |
|---|---|---|---|
| API contract | In progress | Maria | 2026-02-25 |
| Error handling | Pending | Juan | 2026-02-27 |
| Test coverage | Blocked | Alex | 2026-03-01 |
```

### Preview Guidance
- Where to insert:
- Expected rendering:
- Truncation risks:

### Validation Checklist
- [ ] Required columns present
- [ ] Markdown syntax valid
- [ ] No sensitive data included
- [ ] Ready to paste
---
