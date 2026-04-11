# Prompt Template: Azure DevOps

## Context
You are helping with Azure DevOps work item operations.

Fixed configuration:
- Organization URL: https://dev.azure.com/
- Default project: Cat Digital

## Inputs
- Project:
- Authentication mode:
- Operation-specific inputs:

## Constraints
- Do not expose secrets or tokens.
- Validate missing inputs before executing.
- Keep output concise and auditable.

## Task
1. Validate inputs.
2. Execute requested operation.
3. Return structured output.

## Output Format
### Summary
- Operation:
- Total items:

### Results
| Field | Value |
|---|---|

### Validation Checklist
- [ ] Inputs complete
- [ ] No secrets displayed
- [ ] Output validated

---

## Registration Checklist (Mandatory)
- [ ] Added this prompt to `catalog/index.md`
- [ ] Added changelog entry in `changelog/prompts-history.md`
