# Create WebServices Test Cases from User Story

## Context
Generate Azure DevOps Test Cases from a webservices User Story.
Use the User Story as the source of truth for title, area, and iteration. Use an existing Requirement Based Suite as the target suite when the user provides its ID. If the user does not provide that suite ID, ask for the Test Plan ID and create a Requirement Based Suite for the User Story under that plan. The prompt must design the minimum viable set of Gherkin-style scenarios, create the Test Case work items, link them to the resolved or newly created suite, and link them back to the User Story.

## Inputs
- **User Story Work Item ID**: Numeric ID of the User Story for the current execution.
- **Requirement Based Suite ID**: Optional numeric ID of an existing Requirement Based Suite that will receive the generated test cases.
- **Test Plan ID**: Required only when the user does not provide `Requirement Based Suite ID`. This Test Plan will be used to create a new Requirement Based Suite for the User Story.
- **Webservice URL**: Full literal API URL under test (example: `https://host/api/resource`).
- **HTTPS Request Type**: Required HTTP method for the endpoint under test. Allowed values: `GET`, `POST`, `PUT`, `DELETE`.
- **Accept Header**: Required literal value for the `Accept` header sent with the request (example: `application/iecontentattribute-v4+json`).
- **Authorization Header**: Required literal value for the `Authorization` header sent with the request (example: `Bearer Token Dealer`). Suggestion: obtain the header from the browser network trace, then provide a masked or descriptive value instead of the real secret.
- **Response Attribute Verification**: Required expected attribute checks inside the response. Ask the user explicitly which objects and fields must be validated. Example: `medias must contain mediaNumber, revisionNumber, title, terminationDate; languages must contain availableLanguage, language, latest`.
- **Request Body**: Required only when `HTTPS Request Type` is `POST`, `PUT`, or `DELETE`. Use the literal payload that must be sent to the endpoint.
- **Discussion/Comments Scope**: Number of latest comments to evaluate. Default: `20`.

Input safety note:
- Example IDs shown in this file are illustrative only.
- Never reuse IDs from previous runs unless the user explicitly provides them again.
- If any required input is missing, stop and request it explicitly before generating or executing commands.

## Constraints
- **Language**: English for all prompt content, test case titles, steps, and expected results.
- **Organization URL**: `https://dev.azure.com/cat-digital`
- **Project**: `Cat Digital`
- **Execution Input Mode Rule**: During execution, ask required inputs one at a time and do not batch multiple questions in one message.
- **Terminology**: Use official Azure DevOps terms only: Work Item, ID, Requirement Based Suite, Test Case, Test Plan, WIQL.
- **ID Validation**: Validate every provided ID is numeric before any API call.
- **Source of Truth**:
  - Title comes from `System.Title` on the User Story.
  - Area comes from `System.AreaPath` on the User Story.
  - Iteration comes from `System.IterationPath` on the User Story.
  - Sprint label is always the last component of `System.IterationPath`.
- **Iteration Rule**: Never ask the user for iteration or sprint name. The iteration must always be the same as the User Story iteration.
- **Suite Resolution Rule**: If the user provides `Requirement Based Suite ID`, reuse it after validation and derive the plan from that suite.
- **Suite Creation Rule**: If the user does not provide `Requirement Based Suite ID`, ask for `Test Plan ID` and create a Requirement Based Suite for `<USER_STORY_ID>` under that plan.
- **Requirement Based Suite Rule**: Any target suite used by this prompt must resolve to exactly one suite and must be a Requirement Based Suite.
- **Suite Hierarchy Rule**: Never treat a container or parent suite as the execution target for this prompt. The resolved suite must be the direct Requirement Based Suite that will receive the created Test Cases.
- **Suite Resolution Reuse Rule**: Step 2 must use `prompts/azure-devops/resolve-or-create-requirement-based-suite.md` as the single source for suite resolution/creation behavior. Do not duplicate or override that logic in this prompt.
- **Requirement Mapping Rule**: If a provided suite is associated with a requirement/work item and that requirement ID is different from `<USER_STORY_ID>`, stop and request confirmation before continuing.
- **Case Ratio**: Target an overall 3:1 ratio of happy path scenarios to edge/error scenarios across the full test set when the story supports that balance.
- **Case Ratio Clarification**: This ratio is a suite-level guideline, not a rigid quota. Do not create extra negative or edge/error scenarios just to force the count, and never interpret the rule as 3 negative cases per happy path.
- **Priority Coverage Rule**: Ratios such as `4:1`, `5:1`, or `6:1` are valid only when the additional cases cover distinct high-priority behaviors, acceptance criteria, or business risks that add real value.
- **Minimum Coverage**: Generate only the minimum number of test cases needed to cover the acceptance criteria, core behavior, and distinct risks.
- **No Filler Rule**: Additional Test Cases are allowed only when they are priority-driven and non-duplicative. Do not add filler scenarios to satisfy a ratio, round number, or naming sequence.
- **Title Format**: `TC### - US<USER_STORY_ID> - <Abbreviated User Story Title> - <Short Significant Scenario>`.
- **Title Brevity Rule**: Abbreviate the User Story title to 3-6 words in Test Case titles, but never abbreviate the original User Story title in reporting.
- **Title Wording Rule**: Test Case titles and the `<Short Significant Scenario>` segment must be professional and behavior-specific. Do not include generic labels such as `Happy path`, `Happy Path`, `Edge case`, `Edge Case`, `Negative case`, or similar taxonomy terms in titles.
- **Scenario Wording Rule**: Reporting labels and scenario summaries must describe observable product behavior.
- **Step Limits**: Max 180 characters per step action; max 220 characters per expected result.
- **Step Count Rule**: Do not cap test cases at 3 steps. Use as many action/expected result pairs as needed to cover acceptance criteria and distinct risks without adding filler.
- **Mandatory Tooling Step**: The first step of every test case must open BRUNO or Swagger and set the request URL to `<WEBSERVICE_URL>`.
- **HTTP Method Rule**: Always request and use `<HTTPS_REQUEST_TYPE>` as one of `GET`, `POST`, `PUT`, or `DELETE`.
- **Accept Header Rule**: Always request and use `<ACCEPT_HEADER>` as the literal `Accept` header value for the endpoint under test.
- **Authorization Header Rule**: Always request and use `<AUTHORIZATION_HEADER>` as the literal `Authorization` header value for the endpoint under test.
- **Response Attribute Verification Rule**: Always ask for `<RESPONSE_ATTRIBUTE_VERIFICATION>` and use it to define the response field assertions that the generated test cases must validate.
- **Request Body Rule**: If `<HTTPS_REQUEST_TYPE>` is `POST`, `PUT`, or `DELETE`, require `<REQUEST_BODY>` before scenario design or execution. If `<HTTPS_REQUEST_TYPE>` is `GET`, do not request a body unless the user explicitly states the endpoint requires one.
- **Webservice URL Rule**: The URL must be complete and literal. If it contains template variables such as `{{url}}` or `${url}`, stop and request the real URL.
- **Secrets Rule**: Never include real tokens, PAT values, or secrets. If the user shares a real authorization token, ask for a masked placeholder instead before storing it in output. It is acceptable to remind the user to retrieve the original header from the browser network trace and then provide only a masked or descriptive representation.
- **Operational Safety Rule**: Follow the validated Azure DevOps CLI patterns documented in `docs/ai-known-failures.md`. If a command path is known to be fragile in this environment, use the documented workaround instead of retrying the same invalid pattern.

## Execution Safety Profile
- **Shared guidance source**: `docs/ai-known-failures.md`
- **Known fragile paths in this environment**:
  1. `az devops invoke --resource workitems` may fail with `KeyError: 'type'` in azure-devops CLI extension v1.0.2.
  2. `az devops invoke --http-method PATCH` for `Microsoft.VSTS.TCM.Steps` may fail with the same route bug.
  3. `wit/comments` with `api-version 7.1-preview.4` may fail in some environments.
  4. URLs containing `&` can be truncated if passed inline in shell commands.
  5. Azure Test Plans may not render the Steps grid if XML attributes are unquoted.
- **Validated patterns for this prompt**:
  1. Prefer `az boards work-item create` for Test Case creation.
  2. Prefer `az boards work-item update --field "Microsoft.VSTS.TCM.Steps=<xml>"` for step population.
  3. Use PowerShell variables or temp files for long URLs and XML payloads.
  4. Continue with Acceptance Criteria and Description if comments retrieval fails, and record `COMMENTS_STATUS=UNAVAILABLE`.
  5. Verify every write operation with an immediate read.

## Task

### Input Collection Mode
Before pre-flight validation, collect missing required inputs sequentially (one question at a time) and do not infer missing values.

### Pre-Flight Input Validation
Before starting any API calls:
1. Confirm `<USER_STORY_ID>`, `<WEBSERVICE_URL>`, `<HTTPS_REQUEST_TYPE>`, `<ACCEPT_HEADER>`, `<AUTHORIZATION_HEADER>`, and `<RESPONSE_ATTRIBUTE_VERIFICATION>` were explicitly provided for this run.
2. Validate `<HTTPS_REQUEST_TYPE>` is exactly one of `GET`, `POST`, `PUT`, or `DELETE`.
3. Validate `<ACCEPT_HEADER>` is a non-empty literal media type value, for example `application/iecontentattribute-v4+json`.
4. Validate `<AUTHORIZATION_HEADER>` is a non-empty literal authorization value, for example `Bearer Token Dealer`, and does not contain a real secret.
5. Validate `<RESPONSE_ATTRIBUTE_VERIFICATION>` is explicit and lists the response objects and fields that must be checked.
6. If `<HTTPS_REQUEST_TYPE>` is `POST`, `PUT`, or `DELETE`, require `<REQUEST_BODY>` before continuing.
7. If `<REQUIREMENT_BASED_SUITE_ID>` is provided, validate it is numeric.
8. If `<REQUIREMENT_BASED_SUITE_ID>` is not provided, require `<TEST_PLAN_ID>` and validate it is numeric.
9. Validate `<WEBSERVICE_URL>` is literal and does not contain template variables.
10. If `<COMMENTS_SCOPE>` is missing or empty, set it to `20`.
11. If `<WEBSERVICE_URL>` contains `&`, store it in a PowerShell variable before passing it to commands.

### Step 1: Retrieve User Story Details
```bash
az boards work-item show \
  --org https://dev.azure.com/cat-digital \
  --id <USER_STORY_ID> \
  --expand fields \
  --only-show-errors \
  --output json
```

Retrieval guardrail:
- Do not add `--fields` to this command when using `--expand`.
- Do not treat empty stdout as success; validate the returned JSON payload.

Retrieve discussion/comments as well:
```bash
az devops invoke \
  --org https://dev.azure.com/cat-digital \
  --area wit \
  --resource comments \
  --route-parameters project='Cat Digital' workItemId=<USER_STORY_ID> \
  --query-parameters '$top=<COMMENTS_SCOPE>' \
  --api-version 7.1-preview.4 \
  --only-show-errors \
  --output json
```

If this comments call fails:
- Set `COMMENTS_STATUS=UNAVAILABLE`.
- Continue execution with Acceptance Criteria and Description.
- Record the comments retrieval issue in the final assumptions section.

Extract and store:
- `System.Title`
- `System.AreaPath`
- `System.Description`
- `Microsoft.VSTS.Common.AcceptanceCriteria`
- `System.IterationPath`
- `<SPRINT_NAME>` = last component of `System.IterationPath`
- Latest discussion/comments

Source priority for test design:
1. Acceptance Criteria
2. Description
3. Discussion/Comments

Conflict rule:
- If Description or Discussion conflicts with Acceptance Criteria, follow Acceptance Criteria and record the conflict in output assumptions.

### Step 2: Resolve or Create the Requirement Based Suite
Execute `prompts/azure-devops/resolve-or-create-requirement-based-suite.md` with the same run inputs:
- `User Story Work Item ID = <USER_STORY_ID>`
- `Requirement Based Suite ID = <REQUIREMENT_BASED_SUITE_ID>` (if provided)
- `Test Plan ID = <TEST_PLAN_ID>` (if needed)

Required handoff contract from that prompt:
- `<PLAN_ID> = Resolved Plan ID`
- `<TARGET_SUITE_ID> = Resolved Suite ID`

Blocking rule:
- If suite resolution returns ambiguity, invalid suite type, requirement mismatch, or missing output contract values, stop and resolve the issue before continuing to Step 3.

### Step 3: Design Test Scenarios
From Acceptance Criteria first, then Description, then Discussion, design the minimum set of test cases needed.

Coverage rules:
- Start from the minimum viable set of scenarios needed for coverage.
- Prefer a suite that remains predominantly happy-path oriented, aiming for an overall 3:1 balance of happy path to edge/error scenarios when that matches the distinct behaviors under test.
- Ratios such as 4:1, 5:1, or 6:1 are acceptable only when the story has more distinct high-priority behaviors than edge/error behaviors and those additional cases add real value.
- Do not add negative or edge/error scenarios only to force a numeric ratio. Add them only when they validate a distinct rule, branch, risk, or observable outcome.
- Add more Test Cases only when they remain priority-driven, non-redundant, and auditable.
- Use `<RESPONSE_ATTRIBUTE_VERIFICATION>` as the source of truth for response field assertions.
- Set `<EXPECTED_TC_COUNT>` to the designed number of test cases.

For each test case:
- Use Gherkin thinking to define Given, When, Then. This is a behavior structure, not a limit of 3 total steps.
- The first action/expected result pair must be:
  - **Action**: Open BRUNO or Swagger, set the request URL to `<WEBSERVICE_URL>`, select `<HTTPS_REQUEST_TYPE>` as the request method, and set headers `Accept: <ACCEPT_HEADER>` and `Authorization: <AUTHORIZATION_HEADER>`.
  - **Expected Result**: BRUNO or Swagger is open, the endpoint URL is loaded correctly, the request method is set to `<HTTPS_REQUEST_TYPE>`, the `Accept` header is set to `<ACCEPT_HEADER>`, the `Authorization` header is set to `<AUTHORIZATION_HEADER>`, and the request is ready to execute.
- If `<HTTPS_REQUEST_TYPE>` is `POST`, `PUT`, or `DELETE`, add a step to paste `<REQUEST_BODY>` into the request body editor before execution.
- Add validation steps and expected results that explicitly check the response attributes defined in `<RESPONSE_ATTRIBUTE_VERIFICATION>`.
- Keep a traceability mapping to its source: `Acceptance Criteria`, `Description`, or `Discussion`.

### Step 4: Create Test Case Work Items
Preferred command pattern:
```bash
az boards work-item create \
  --org https://dev.azure.com/cat-digital \
  --project 'Cat Digital' \
  --type 'Test Case' \
  --title '<TC_TITLE>' \
  --area '<USER_STORY_AREA_PATH>' \
  --iteration '<USER_STORY_ITERATION_PATH>' \
  --only-show-errors \
  --output json
```

Creation rules:
- Create all Test Cases in `Design` state unless your process sets a different default automatically.
- Use `System.AreaPath` from the User Story.
- Use `System.IterationPath` from the User Story.
- Never ask the user for iteration or sprint.
- If automated creation fails because of known CLI limitations, stop the automation path and switch to documented manual UI creation for the pending test cases.

### Step 5: Populate Test Steps
Use this verified method in this environment:

```powershell
function EscHtml([string]$s) {
  return $s -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;' -replace "'", '&apos;'
}

function BuildStepsXml([array]$steps) {
  $last = $steps.Count + 1
  $xml = "<steps id='0' last='$last'>"
  $sid = 2
  foreach ($s in $steps) {
    $a = EscHtml $s.action
    $e = EscHtml $s.expected
    $xml += "<step id='$sid' type='ActionStep'>"
    $xml += "<parameterizedString isformatted='true'>$a</parameterizedString>"
    $xml += "<parameterizedString isformatted='true'>$e</parameterizedString>"
    $xml += "<description/></step>"
    $sid++
  }
  $xml += "</steps>"
  return $xml
}

$stepsXml = BuildStepsXml $stepList
az boards work-item update \
  --org https://dev.azure.com/cat-digital \
  --id <TC_ID> \
  --field "Microsoft.VSTS.TCM.Steps=$stepsXml" \
  --only-show-errors \
  --output json
```

Rules for reliable rendering in Azure Test Plans:
- Keep attributes quoted in XML, for example: `<steps id='0' ...>` and `<step id='2' type='ActionStep'>`.
- Materialize `$stepList` as an explicit array variable before calling `BuildStepsXml`; do not pass an indexed or lazily evaluated collection directly into the helper.
- Do not rely on `az devops invoke --http-method PATCH` for `Microsoft.VSTS.TCM.Steps` in this environment.
- After updating the field, read it back and reject values such as `<steps id='0' last='0'></steps>` even if the command exit code is `0`.
- Hard validation gate: parse the persisted XML and verify every `<step ...>` contains exactly two `<parameterizedString ...>` nodes (Action + Expected Result) and one `<description/>`. If any step fails, treat execution as failed.
- Minimum step gate: each created Test Case must have at least 4 steps. When `<HTTPS_REQUEST_TYPE>` is `POST`, `PUT`, or `DELETE`, each Test Case must have at least 5 steps including request body setup.
- False-positive prevention: do not report `COMPLETED` if validation only checks text markers. Structural per-step validation is mandatory.

Manual option (only if update fails):
1. Open the Test Case work item in Azure DevOps.
2. Open the **Steps** section.
3. Add only the necessary steps and expected results.
4. Save the Test Case.

### Step 6: Link Test Cases to the Resolved Requirement Based Suite
Use the resolved `<PLAN_ID>` and `<TARGET_SUITE_ID>`:
```bash
az devops invoke \
  --org https://dev.azure.com/cat-digital \
  --area testplan \
  --resource suitetestcase \
  --route-parameters project='Cat Digital' planId=<PLAN_ID> suiteId=<TARGET_SUITE_ID> testCaseId=<TC_ID> \
  --http-method POST \
  --api-version 7.1-preview.4 \
  --only-show-errors \
  --output json
```

Repeat for each created Test Case ID.

### Step 7: Verify Suite Membership
```bash
az devops invoke \
  --org https://dev.azure.com/cat-digital \
  --area testplan \
  --resource suitetestcase \
  --route-parameters project='Cat Digital' planId=<PLAN_ID> suiteId=<TARGET_SUITE_ID> \
  --api-version 7.1-preview.4 \
  --only-show-errors \
  --output json
```

Validation rules:
- The suite membership count must equal `<EXPECTED_TC_COUNT>` plus any pre-existing cases already in the suite, if the suite is reused intentionally.
- Every newly created `TC###` item must be present in the returned membership list.
- If a POST returns success but the follow-up GET does not contain the Test Case, report a silent failure and retry or move to manual linking.

### Step 8: Validate Test Case Creation
For each created Test Case ID, verify:
```bash
az boards work-item show \
  --org https://dev.azure.com/cat-digital \
  --id <TC_ID> \
  --expand fields \
  --only-show-errors \
  --output json
```

Expected validation:
- Title starts with `TC###`.
- Title contains `US<USER_STORY_ID>`.
- Area equals the User Story area.
- Iteration equals the User Story iteration.
- State is valid for the chosen creation path.
- Steps are present only if a verified step population method was used.
- Stored steps XML uses quoted attributes and includes at least one `<step ...>` element.
- Stored steps XML has one Action and one Expected Result per step (exactly 2 `parameterizedString` nodes in each step) and includes `<description/>` in each step.
- Stored steps XML has at least 4 steps, or at least 5 for `POST`/`PUT`/`DELETE`.

### Step 9: Link the User Story to the Test Cases
For each Test Case ID:
```bash
az boards work-item relation add \
  --org https://dev.azure.com/cat-digital \
  --id <USER_STORY_ID> \
  --relation-type 'Tested By' \
  --target-id <TC_ID> \
  --only-show-errors \
  --output json
```

Then verify:
```bash
az boards work-item show \
  --org https://dev.azure.com/cat-digital \
  --id <USER_STORY_ID> \
  --expand relations \
  --only-show-errors \
  --output json
```

## Output Format

**Success Checklist:**
- [ ] User Story retrieved successfully.
- [ ] Requirement Based Suite resolved successfully from `<REQUIREMENT_BASED_SUITE_ID>` or created successfully under `<TEST_PLAN_ID>`.
- [ ] Test Plan resolved correctly for the final target suite.
- [ ] Iteration taken from the User Story, not from user input.
- [ ] All test cases created with `TC###` naming and the expected count.
- [ ] Step population status documented correctly.
- [ ] All generated Test Cases linked to the final Requirement Based Suite.
- [ ] All generated Test Cases linked back to the User Story with `Tested By`.

**Output:**
```text
USER STORY: <USER_STORY_ID> - <USER_STORY_TITLE>
PLAN: <PLAN_ID>
SUITE: <TARGET_SUITE_ID> - <SUITE_NAME>
ITERATION: <USER_STORY_ITERATION_PATH>
SPRINT LABEL: <SPRINT_NAME>
ACCEPT HEADER: <ACCEPT_HEADER>
AUTHORIZATION HEADER: <AUTHORIZATION_HEADER>
RESPONSE ATTRIBUTE VERIFICATION: <RESPONSE_ATTRIBUTE_VERIFICATION>
EXPECTED TC COUNT: <EXPECTED_TC_COUNT>
TEST CASES:
- TC001 ...
- TC002 ...
STEP VALIDATION EVIDENCE:
- <TC_ID> stepCount=<N> actionExpectedPairs=PASS|FAIL descriptionNodes=PASS|FAIL
- <TC_ID> stepCount=<N> actionExpectedPairs=PASS|FAIL descriptionNodes=PASS|FAIL
FINAL STATUS: COMPLETED | COMPLETED WITH ASSUMPTIONS | BLOCKED
PRIORITY FOLLOW-UP: <NONE or concise statement of additional high-priority Test Cases that would add value without filler>
```

## Validation Checklist
- [ ] `<USER_STORY_ID>` is numeric and retrievable.
- [ ] If provided, `<REQUIREMENT_BASED_SUITE_ID>` is numeric and resolves to exactly one suite.
- [ ] If `<REQUIREMENT_BASED_SUITE_ID>` is not provided, `<TEST_PLAN_ID>` was explicitly requested and validated.
- [ ] The final target suite belongs to a Test Plan and `<PLAN_ID>` is known.
- [ ] The final target suite is a Requirement Based Suite.
- [ ] If the suite is mapped to a requirement, that mapping is aligned with `<USER_STORY_ID>` or explicitly confirmed.
- [ ] `System.AreaPath` and `System.IterationPath` were taken from the User Story.
- [ ] No iteration or sprint name was requested from the user.
- [ ] `Test Plan ID` was requested only when `Requirement Based Suite ID` was missing.
- [ ] The Webservice URL is literal and valid for execution.
- [ ] `<HTTPS_REQUEST_TYPE>` was explicitly requested and validated as `GET`, `POST`, `PUT`, or `DELETE`.
- [ ] `<ACCEPT_HEADER>` was explicitly requested and validated as a literal `Accept` header value.
- [ ] `<AUTHORIZATION_HEADER>` was explicitly requested and validated as a literal `Authorization` header value without exposing a real secret.
- [ ] `<RESPONSE_ATTRIBUTE_VERIFICATION>` was explicitly requested and validated before test design.
- [ ] `<REQUEST_BODY>` was explicitly requested when `<HTTPS_REQUEST_TYPE>` was `POST`, `PUT`, or `DELETE`.
- [ ] If comments retrieval failed, `COMMENTS_STATUS=UNAVAILABLE` was recorded and execution continued with Acceptance Criteria and Description.
- [ ] Test design priority was Acceptance Criteria > Description > Discussion.
- [ ] Every Test Case title starts with `TC###` and includes `US<USER_STORY_ID>`.
- [ ] Every Test Case uses the User Story iteration.
- [ ] Every Test Case uses the User Story area.
- [ ] Every Test Case contains only the minimum necessary steps.
- [ ] Test steps explicitly validate the response attributes requested in `<RESPONSE_ATTRIBUTE_VERIFICATION>`.
- [ ] Step XML was stored with quoted attributes and renders in Azure Test Plans.
- [ ] Every persisted `<step ...>` has exactly 2 `parameterizedString` nodes (Action + Expected Result) and `<description/>`.
- [ ] Step count validation passed for each Test Case (>=4 or >=5 for `POST`/`PUT`/`DELETE`).
- [ ] Final status was not marked `COMPLETED` when structural step validation failed.
- [ ] All created Test Cases are present in the target suite membership query.
- [ ] The User Story has `Tested By` links to all generated Test Case IDs.

## Notes
- **Reusability**: This prompt accepts any User Story ID, any literal URL, and either a Requirement Based Suite ID or, if that suite ID is omitted, a Test Plan ID.
- **Rate Limiting**: Space out write operations by 1-2 seconds if multiple Test Cases are being created.
- **Silent Failures**: Treat HTTP 200 as insufficient proof for write operations. Always verify with a read.
- **Manual Fallback**: If automation fails because of Azure DevOps CLI limitations, continue with documented manual UI steps instead of inventing unsupported commands.

## Implementation Guardrails
- **JSON Temp Files**: Use `[System.IO.File]::WriteAllText($path, $content, [System.Text.UTF8Encoding]::new($false))` for JSON payloads to avoid UTF-8 BOM issues.
- **Error Handling**: Check both command failure and response content.
- **Verification**: Immediately run a GET after every POST or PATCH.
- **Output Management**: Redirect large command output to files when needed to avoid terminal truncation.
- **Known Route Bugs**: Do not rely on `az devops invoke --resource workitems` or steps PATCH when the environment reproduces `KeyError: 'type'`.
