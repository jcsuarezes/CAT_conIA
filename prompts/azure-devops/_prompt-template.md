# Prompt Template: Azure DevOps

## Context
You are helping with Azure DevOps work item operations.

Fixed configuration:
- Organization URL: https://dev.azure.com/cat-digital
- Default project: Cat Digital

## Execution Mode
- When the user asks to execute or run the prompt, ask required inputs one at a time.
- Do not batch multiple input questions in a single message.
- Do not infer missing required inputs; collect each value explicitly before execution.

## Inputs
- Project:
- Authentication mode:
- Operation-specific inputs:
- Work Item input format (default): full Azure DevOps Work Item URL first; numeric ID accepted as fallback.
- User Story type (required for test case generation): Webservices | UI | Data
- Test Plans ID fragment input (when suites are involved): `planId=<PLAN_ID>&suiteId=<SUITE_ID>` (fragment only, never full URL)

### Inputs by User Story Type
- Webservices:
	- User Story Work Item URL (preferred) or numeric ID (fallback)
	- Requirement Based Suite ID *(child)* (optional when already known)
	- Test Plan ID *(parent container)* (required in ALL cases — both when reusing a suite and when creating one; the API needs planId for every suite operation)
	- Webservice URL (mandatory)
	- API method and headers (if applicable)
- UI:
	- User Story/Bug Work Item URL (preferred) or numeric ID (fallback)
	- Requirement Based Suite ID *(child)* (optional when already known)
	- Test Plan ID *(parent container)* (required in ALL cases)
	- Application URL
	- Browser/Device matrix (if applicable)
- Data:
	- User Story Work Item URL (preferred) or numeric ID (fallback)
	- Requirement Based Suite ID *(child)* (optional when already known)
	- Test Plan ID *(parent container)* (required in ALL cases)
	- Source dataset/table
	- Validation rules and expected output dataset/table

## Constraints
- Do not expose secrets or tokens.
- Validate missing inputs before executing.
- Keep output concise and auditable.
- Request Work Item URL first and extract numeric ID internally; accept raw numeric ID only when URL is unavailable.
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
	- When asking users for existing plan/suite values, ask for the Test Plans URL fragment only: `planId=<PLAN_ID>&suiteId=<SUITE_ID>`.
	- Do not request or store the full URL when fragment values are sufficient.
	- Do not ask for sprint or iteration as direct input when a User Story is available; derive them from `System.IterationPath`.
- Test design prioritization rule:
	- Use the minimum viable number of test cases, with a default pattern of 1 happy path plus up to 3 negative/edge/boundary scenarios per core behavior when those scenarios add distinct coverage value.
	- If no meaningful negative, edge, or boundary coverage exists, do not invent scenarios just to reach four test cases.
	- If more than 3 distinct negative/edge/boundary scenarios add real coverage value, allow up to 5 per happy path.
	- Do not create filler test cases to satisfy a numeric target.
	- If more priority test cases remain out of scope, state that explicitly in the final output.
	- Do not impose a fixed three-step cap in test cases. Given/When/Then is a behavior structure, and actions/expected results can include as many steps as needed for complete coverage.
- Test Steps reliability rule:
	- For Azure DevOps Test Case step population, use render-compatible `Microsoft.VSTS.TCM.Steps` XML with `ActionStep`, quoted attributes, and `<description/>`.
	- Materialize step collections in an explicit array variable before building XML in PowerShell.
	- After updating steps, read the field back and reject empty XML such as `<steps id='0' last='0'></steps>`.

## Task
1. Collect required inputs sequentially, one question at a time.
2. Validate inputs.
3. If creating test cases, confirm User Story type is provided (Webservices/UI/Data).
4. If type is Webservices, validate Webservice URL is present before execution.
5. If type is Webservices, enforce Step 1 in all test cases: open BRUNO and load Webservice URL.
6. Execute requested operation.
7. Return structured output.
8. End with a final status message that clearly states completion state, blockers if any, and whether more priority test cases exist without adding filler.

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
