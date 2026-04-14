# Create WebServices Test Cases from User Story

## Context
Generate Azure DevOps Test Cases from a webservices User Story.
Use the User Story as the source of truth for title, area, and iteration. Use an existing Requirement Based Suite as the target suite when the user provides its ID. If the user does not provide that suite ID, ask for the Test Plan ID and create a Requirement Based Suite for the User Story under that plan. The prompt must design the minimum viable set of Gherkin-style scenarios, create the Test Case work items, link them to the resolved or newly created suite, and link them back to the User Story.

## Inputs
- **User Story Work Item ID**: Numeric ID of the User Story for the current execution.
- **Requirement Based Suite ID**: Optional numeric ID of an existing Requirement Based Suite that will receive the generated test cases.
- **Test Plan ID**: Required only when the user does not provide `Requirement Based Suite ID`. This Test Plan will be used to create a new Requirement Based Suite for the User Story.
- **Webservice URL**: Full literal API URL under test (example: `https://host/api/resource`).
- **Discussion/Comments Scope**: Number of latest comments to evaluate. Default: `20`.

Input safety note:
- Example IDs shown in this file are illustrative only.
- Never reuse IDs from previous runs unless the user explicitly provides them again.
- If any required input is missing, stop and request it explicitly before generating or executing commands.

## Constraints
- **Language**: English for all prompt content, test case titles, steps, and expected results.
- **Organization URL**: `https://dev.azure.com/cat-digital`
- **Project**: `Cat Digital`
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
- **Requirement Mapping Rule**: If a provided suite is associated with a requirement/work item and that requirement ID is different from `<USER_STORY_ID>`, stop and request confirmation before continuing.
- **Case Ratio**: Keep an exact 3:1 ratio of happy path scenarios to edge/error scenarios unless a specific risk clearly requires an exception.
- **Minimum Coverage**: Generate only the minimum number of test cases needed to cover the acceptance criteria, core behavior, and distinct risks.
- **Title Format**: `TC### - US<USER_STORY_ID> - <Abbreviated User Story Title> - <Short Significant Scenario>`.
- **Title Brevity Rule**: Abbreviate the User Story title to 3-6 words in Test Case titles, but never abbreviate the original User Story title in reporting.
- **Step Limits**: Max 180 characters per step action; max 220 characters per expected result.
- **Mandatory Tooling Step**: The first step of every test case must open BRUNO or Swagger and set the request URL to `<WEBSERVICE_URL>`.
- **Webservice URL Rule**: The URL must be complete and literal. If it contains template variables such as `{{url}}` or `${url}`, stop and request the real URL.
- **Secrets Rule**: Never include real tokens, PAT values, or secrets.

## Known Limitations & Workarounds
- **Azure DevOps CLI Work Item Route Bug**: `az devops invoke --resource workitems` may fail with `KeyError: 'type'` in azure-devops CLI extension v1.0.2.
- **Azure DevOps CLI Steps PATCH Bug**: `az devops invoke --http-method PATCH` for `Microsoft.VSTS.TCM.Steps` may fail with `KeyError: 'type'` in the same extension version.
- **Comments API Instability**: `wit/comments` with `api-version 7.1-preview.4` may fail in some environments.
- **URL Shell Parsing Risk**: URLs containing `&` can be truncated if passed inline in shell commands.
- **Steps Renderer Compatibility**: If steps XML is stored with unquoted attributes (for example `id=0`), Azure Test Plans may not render the Steps grid.
- **Workaround**:
  1. Prefer `az boards work-item create` for Test Case creation when possible.
  2. Prefer `az boards work-item update --field "Microsoft.VSTS.TCM.Steps=<xml>"` for step population.
  3. Use PowerShell variables or temp files for long URLs and XML payloads; avoid inline concatenation for URLs with `&`.
  4. If comments retrieval fails, continue with Acceptance Criteria and Description and report comments as unavailable.
  5. Always verify write operations with an immediate read operation.

## Task

### Pre-Flight Input Validation
Before starting any API calls:
1. Confirm `<USER_STORY_ID>` and `<WEBSERVICE_URL>` were explicitly provided for this run.
2. If `<REQUIREMENT_BASED_SUITE_ID>` is provided, validate it is numeric.
3. If `<REQUIREMENT_BASED_SUITE_ID>` is not provided, require `<TEST_PLAN_ID>` and validate it is numeric.
4. Validate `<WEBSERVICE_URL>` is literal and does not contain template variables.
5. If `<COMMENTS_SCOPE>` is missing or empty, set it to `20`.
6. If `<WEBSERVICE_URL>` contains `&`, store it in a PowerShell variable before passing it to commands.

### Step 1: Retrieve User Story Details
```bash
az boards work-item show \
  --org https://dev.azure.com/cat-digital \
  --id <USER_STORY_ID> \
  --expand fields \
  --only-show-errors \
  --output json
```

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

#### Branch A: User Provided `<REQUIREMENT_BASED_SUITE_ID>`
Derive the Test Plan from the suite.

1. List all Test Plans:
```bash
az devops invoke \
  --org https://dev.azure.com/cat-digital \
  --area testplan \
  --resource plans \
  --route-parameters project='Cat Digital' \
  --api-version 7.1-preview \
  --only-show-errors \
  --output json
```

2. For each returned plan ID, try two validations for `<REQUIREMENT_BASED_SUITE_ID>`:
  - First, list suites in the plan and search for the suite ID.
  - If the suite is not returned by the list response, perform a direct suite lookup using `planId + suiteId`.

Use this fallback-safe pattern:
```powershell
$plans = az devops invoke `
  --org https://dev.azure.com/cat-digital `
  --area testplan `
  --resource plans `
  --route-parameters project='Cat Digital' `
  --api-version 7.1-preview `
  --only-show-errors `
  --output json | ConvertFrom-Json

$matches = @()
foreach ($plan in $plans.value) {
  $suites = az devops invoke `
    --org https://dev.azure.com/cat-digital `
    --area testplan `
    --resource suites `
    --route-parameters project='Cat Digital' planId=$($plan.id) `
    --api-version 7.1-preview `
    --only-show-errors `
    --output json | ConvertFrom-Json

  $match = $suites.value | Where-Object { $_.id -eq <REQUIREMENT_BASED_SUITE_ID> }
  
  if (-not $match) {
    try {
      $directSuite = az devops invoke `
        --org https://dev.azure.com/cat-digital `
        --area testplan `
        --resource suites `
        --route-parameters project='Cat Digital' planId=$($plan.id) suiteId=<REQUIREMENT_BASED_SUITE_ID> `
        --api-version 7.1-preview `
        --only-show-errors `
        --output json | ConvertFrom-Json

      if ($directSuite -and $directSuite.id -eq <REQUIREMENT_BASED_SUITE_ID>) {
        $match = @($directSuite)
      }
    }
    catch {
      # Ignore not-found responses for plans that do not own the suite.
    }
  }

  if ($match) {
    $matches += [PSCustomObject]@{
      planId = $plan.id
      planName = $plan.name
      suite = $match
    }
  }
}
```

3. Validation rules for provided suite:
- If zero matches are found, stop and request a valid Requirement Based Suite ID.
- If more than one match is found, stop and report the ambiguity.
- Set `<PLAN_ID>` to the matching plan ID.
- Set `<TARGET_SUITE_ID>` to `<REQUIREMENT_BASED_SUITE_ID>`.
- Validate the matched suite type is Requirement Based Suite. If the returned payload does not identify it as requirement-based, stop and ask for a correct suite ID.
- If the suite exposes a linked requirement/work item ID and it is different from `<USER_STORY_ID>`, stop and request confirmation.
- Do not assume that listing suites by plan always returns every suite needed for validation. The direct lookup by `planId + suiteId` is mandatory before rejecting a provided suite ID.

#### Branch B: User Did Not Provide `<REQUIREMENT_BASED_SUITE_ID>`
Ask for `<TEST_PLAN_ID>` and create a Requirement Based Suite for `<USER_STORY_ID>` under that plan.

1. Validate that the plan exists:
```bash
az devops invoke \
  --org https://dev.azure.com/cat-digital \
  --area testplan \
  --resource plans \
  --route-parameters project='Cat Digital' planId=<TEST_PLAN_ID> \
  --api-version 7.1-preview \
  --only-show-errors \
  --output json
```

2. Query existing suites in the plan and check whether a Requirement Based Suite already exists for `<USER_STORY_ID>`:
```bash
az devops invoke \
  --org https://dev.azure.com/cat-digital \
  --area testplan \
  --resource suites \
  --route-parameters project='Cat Digital' planId=<TEST_PLAN_ID> \
  --api-version 7.1-preview \
  --only-show-errors \
  --output json
```

3. Reuse rule before creation:
- If a Requirement Based Suite already exists in the plan for `<USER_STORY_ID>`, reuse it and set `<TARGET_SUITE_ID>` to that ID.
- If more than one Requirement Based Suite exists for `<USER_STORY_ID>`, stop and ask the user which one to reuse.

4. If no Requirement Based Suite exists for `<USER_STORY_ID>`, create one under `<TEST_PLAN_ID>`:
```powershell
$body = @(@{
  suiteType = 'requirementTestSuite'
  requirementId = <USER_STORY_ID>
}) | ConvertTo-Json -Depth 8

$tmp = [System.IO.Path]::GetTempFileName() + '.json'
[System.IO.File]::WriteAllText($tmp, $body, [System.Text.UTF8Encoding]::new($false))

az devops invoke `
  --org https://dev.azure.com/cat-digital `
  --area testplan `
  --resource suites `
  --route-parameters project='Cat Digital' planId=<TEST_PLAN_ID> `
  --http-method POST `
  --in-file $tmp `
  --api-version 7.1-preview `
  --only-show-errors `
  --output json
```

5. Creation validation rules:
- Set `<PLAN_ID>` to `<TEST_PLAN_ID>`.
- Set `<TARGET_SUITE_ID>` to the created suite ID.
- Immediately verify the created suite with a direct suite lookup using `planId + suiteId`, not only with the plan suite list.
- Verify the created suite is a Requirement Based Suite mapped to `<USER_STORY_ID>`.

Direct verification command:
```bash
az devops invoke \
  --org https://dev.azure.com/cat-digital \
  --area testplan \
  --resource suites \
  --route-parameters project='Cat Digital' planId=<TEST_PLAN_ID> suiteId=<TARGET_SUITE_ID> \
  --api-version 7.1-preview \
  --only-show-errors \
  --output json
```

### Step 3: Design Test Scenarios
From Acceptance Criteria first, then Description, then Discussion, design the minimum set of test cases needed.

Coverage rules:
- Generate 3 happy path scenarios and 1 edge/error scenario by default.
- Only exceed that ratio when a specific rule, branch, or observable outcome requires it.
- Set `<EXPECTED_TC_COUNT>` to the designed number of test cases.

For each test case:
- Use Gherkin thinking to define Given, When, Then.
- The first action/expected result pair must be:
  - **Action**: Open BRUNO or Swagger and set the request URL to `<WEBSERVICE_URL>`.
  - **Expected Result**: BRUNO or Swagger is open, the endpoint URL is loaded correctly, and the request is ready to execute.
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
- Do not rely on `az devops invoke --http-method PATCH` for `Microsoft.VSTS.TCM.Steps` in this environment.

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
  --api-version 7.1-preview \
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
  --api-version 7.1-preview \
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
EXPECTED TC COUNT: <EXPECTED_TC_COUNT>
TEST CASES:
- TC001 ...
- TC002 ...
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
- [ ] If comments retrieval failed, `COMMENTS_STATUS=UNAVAILABLE` was recorded and execution continued with Acceptance Criteria and Description.
- [ ] Test design priority was Acceptance Criteria > Description > Discussion.
- [ ] Every Test Case title starts with `TC###` and includes `US<USER_STORY_ID>`.
- [ ] Every Test Case uses the User Story iteration.
- [ ] Every Test Case uses the User Story area.
- [ ] Every Test Case contains only the minimum necessary steps.
- [ ] Step XML was stored with quoted attributes and renders in Azure Test Plans.
- [ ] All created Test Cases are present in the target suite membership query.
- [ ] The User Story has `Tested By` links to all generated Test Case IDs.

## Notes
- **Reusability**: This prompt accepts any User Story ID, any literal URL, and either a Requirement Based Suite ID or, if that suite ID is omitted, a Test Plan ID.
- **Rate Limiting**: Space out write operations by 1-2 seconds if multiple Test Cases are being created.
- **Silent Failures**: Treat HTTP 200 as insufficient proof for write operations. Always verify with a read.
- **Manual Fallback**: If automation fails because of Azure DevOps CLI limitations, continue with documented manual UI steps instead of inventing unsupported commands.

## PowerShell Best Practices (For Implementation)
- **JSON Temp Files**: Use `[System.IO.File]::WriteAllText($path, $content, [System.Text.UTF8Encoding]::new($false))` for JSON payloads to avoid UTF-8 BOM issues.
- **Error Handling**: Check both command failure and response content.
- **Verification**: Immediately run a GET after every POST or PATCH.
- **Output Management**: Redirect large command output to files when needed to avoid terminal truncation.
- **Known Bugs**: Do not rely on `az devops invoke --resource workitems` or steps PATCH when the environment reproduces `KeyError: 'type'`.
