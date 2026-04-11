# Quickstart Prompt: Generate Work Item URLs (Alternate Organization)

Use this ready-to-run prompt in your assistant.

---
## Context
You are generating Azure DevOps Work Item web URLs from IDs using the alternate organization.

Fixed configuration:
- Organization URL: https://dev.azure.com/
- Alternate Organization URL: https://dev.azure.com/cat-digital/
- Default project: Cat Digital
- Retrieval mode: IDs-only

## Inputs
- Organization URL: https://dev.azure.com/cat-digital/
- Project: cat-digital
- Work Item IDs source: file `url_work_items.txt`
- Keep duplicates: no
- Output file path (Windows): `%USERPROFILE%\\Desktop\\URL.txt`

## Constraints
- Do not expose secrets or tokens.
- Process IDs only; do not use WIQL for this flow.
- Validate IDs are numeric.
- If project validation fails, continue URL generation from IDs and report validation status.
- Final deliverable must be plain text content for a `.txt` file.

## Task
1) Read and normalize Work Item IDs from input source.
2) Validate access to alternate organization/project when possible.
3) Generate URLs using `https://dev.azure.com/cat-digital/_workitems/edit/<ID>`.
4) Retrieve Work Item name (title) for each ID.
4) Remove duplicates (`Keep duplicates: no`).
5) Save one record per line to `%USERPROFILE%\\Desktop\\URL.txt` using `|` separator:
	- `<ID>|<Name>|<URL>`
6) Return an auditable summary.

## Output Format
### Summary
- Organization used:
- Project used:
- Total input IDs:
- Total output URLs:
- Duplicates removed:
- Output file:

### URLs
- One record per line in plain text using `|` separator:
- `<ID>|<Name>|<URL>`

## Validation Checklist
- [ ] Organization URL is set (`https://dev.azure.com/cat-digital/`)
- [ ] Project is set (`cat-digital`)
- [ ] IDs are numeric and normalized
- [ ] IDs-only mode respected
- [ ] Name and ID included in output
- [ ] No secrets displayed
- [ ] `.txt` output file created
---
