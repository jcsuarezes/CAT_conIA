# Prompt: Generate Azure DevOps Work Item URLs (Alternate Organization)

## Context
You are helping generate direct Azure DevOps web URLs for Work Items using the alternate organization.

Fixed configuration:
- Organization URL: https://dev.azure.com/
- Alternate Organization URL: https://dev.azure.com/cat-digital/
- Default project: Cat Digital
- Alternate project: Cat Digital
- Retrieval mode: IDs-only

## Inputs
- Organization URL (default: `https://dev.azure.com/cat-digital/`):
- Project (default: `cat-digital`):
- Work Item IDs source (`inline list` or `file path`):
- Output file path (default on Windows: `%USERPROFILE%\\Desktop\\URL.txt`):
- Keep duplicates (`yes` or `no`, default: `no`):

## Constraints
- Do not expose secrets or tokens.
- Use IDs-only mode for retrieval/processing.
- Validate that IDs are numeric.
- Keep output auditable and deterministic.
- If project validation fails on the alternate organization, continue with URL generation using IDs only and report validation status.

## Task
1. Validate required inputs and normalize Work Item IDs.
2. Confirm access to the alternate organization and project when possible.
3. Generate one web URL per ID using this pattern:
   - `https://dev.azure.com/cat-digital/_workitems/edit/<ID>`
4. Retrieve Work Item name (title) for each ID.
4. Remove duplicates unless explicitly requested to keep them.
5. Save output as plain text in `URL.txt`, one record per line using `|` separator:
   - `<ID>|<Name>|<URL>`
6. Return an auditable execution summary.

## Output Format
### Summary
- Organization used:
- Project used:
- Total input IDs:
- Total output URLs:
- Duplicates removed:
- Output file:

### URLs
- One record per line, plain text, with `|` separator:
- `<ID>|<Name>|<URL>`

### Validation Checklist
- [ ] Organization URL is set (`https://dev.azure.com/cat-digital/`)
- [ ] Project is set (`cat-digital`)
- [ ] IDs are numeric and normalized
- [ ] IDs-only mode respected
- [ ] Name and ID included in output
- [ ] No secrets displayed
- [ ] Output file created (`URL.txt`)
