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
	- Test Plan ID
	- Root Suite ID
	- Sprint Name
	- Webservice URL (mandatory)
	- API method and headers (if applicable)
- UI:
	- User Story Work Item ID
	- Test Plan ID
	- Root Suite ID
	- Sprint Name
	- Application URL
	- Browser/Device matrix (if applicable)
- Data:
	- User Story Work Item ID
	- Test Plan ID
	- Root Suite ID
	- Sprint Name
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

## Task
1. Validate inputs.
2. If creating test cases, confirm User Story type is provided (Webservices/UI/Data).
3. If type is Webservices, validate Webservice URL is present before execution.
4. If type is Webservices, enforce Step 1 in all test cases: open BRUNO and load Webservice URL.
5. Execute requested operation.
6. Return structured output.

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
