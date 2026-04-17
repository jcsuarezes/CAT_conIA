# Prompt Template: Azure DevOps

## Context
You are helping with Azure DevOps work item operations.

Fixed configuration:
- Organization URL: https://dev.azure.com/cat-digital
- Default project: Cat Digital

## Inputs
- Project:
- Authentication mode:
- Operation-specific inputs:
- User Story type (required for test case generation): Webservices | UI | Data

### Inputs by User Story Type
- Webservices:
	- User Story Work Item ID
	- Requirement Based Suite ID (optional when already known)
	- Test Plan ID (required only when Requirement Based Suite ID is not provided)
	- Webservice URL (mandatory)
	- API method and headers (if applicable)
- UI:
	- User Story Work Item ID
	- Requirement Based Suite ID (optional when already known)
	- Test Plan ID (required only when Requirement Based Suite ID is not provided)
	- Application URL
	- Browser/Device matrix (if applicable)
- Data:
	- User Story Work Item ID
	- Requirement Based Suite ID (optional when already known)
	- Test Plan ID (required only when Requirement Based Suite ID is not provided)
	- Source dataset/table
	- Validation rules and expected output dataset/table

## Constraints
- Do not expose secrets or tokens.
- Validate missing inputs before executing.
- Keep output concise and auditable.
- Follow shared command guidance in `docs/validated-command-patterns.md` before using Azure DevOps CLI shortcuts.
- When using Azure DevOps CLI retrieval commands, prefer validated command patterns over minimal-output shortcuts.
- For `az boards work-item show`, do not combine `--fields` with `--expand`; retrieve with `--expand fields -o json` and extract required values from the `fields` object.
- Treat empty stdout as unvalidated even when exit code is `0`; inspect the payload or query result before concluding success.
- Webservices-only rule for test case generation:
	- If the request is to create test cases for User Story type Webservices, require Webservice URL as mandatory input.
	- If Webservice URL is missing, stop and request it before creating suite/test cases.
	- For Webservices test cases, force Step 1 action/expected result to open BRUNO and load the Webservice URL.
	- Do not apply this BRUNO/URL rule to UI or Data test cases.
- Suite-resolution reuse rule for test case generation:
	- If the operation resolves, reuses, or creates Azure DevOps test suites, call `prompts/azure-devops/resolve-or-create-requirement-based-suite.md`.
	- Do not duplicate suite-resolution logic inside each test-case prompt.
	- Require output handoff contract: `Resolved Plan ID` and `Resolved Suite ID`.
	- Do not ask for sprint or iteration as direct input when a User Story is available; derive them from `System.IterationPath`.
- Test design prioritization rule:
	- Use the minimum viable number of test cases, but allow ratios such as 4:1, 5:1, or 6:1 only when additional cases cover distinct high-priority behaviors and add real value.
	- Do not create filler test cases to satisfy a numeric target.
	- If more priority test cases remain out of scope, state that explicitly in the final output.
- Test Steps reliability rule:
	- For Azure DevOps Test Case step population, use render-compatible `Microsoft.VSTS.TCM.Steps` XML with `ActionStep`, quoted attributes, and `<description/>`.
	- Materialize step collections in an explicit array variable before building XML in PowerShell.
	- After updating steps, read the field back and reject empty XML such as `<steps id='0' last='0'></steps>`.

## Task
1. Validate inputs.
2. If creating test cases, confirm User Story type is provided (Webservices/UI/Data).
3. If type is Webservices, validate Webservice URL is present before execution.
4. If type is Webservices, enforce Step 1 in all test cases: open BRUNO and load Webservice URL.
5. Execute requested operation.
6. Return structured output.
7. End with a final status message that clearly states completion state, blockers if any, and whether more priority test cases exist without adding filler.

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
- [ ] Azure DevOps CLI pattern validated for the requested operation

---

## Registration Checklist (Mandatory)
- [ ] Added this prompt to `catalog/index.md`
- [ ] Added changelog entry in `changelog/prompts-history.md`
