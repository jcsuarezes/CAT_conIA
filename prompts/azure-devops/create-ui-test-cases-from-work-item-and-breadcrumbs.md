# Create UI Test Cases from Work Item and Breadcrumbs

## Context
Generate Azure DevOps Test Cases for a UI Work Item by combining:
- the Azure DevOps Work Item as the source of truth for title, area, iteration, acceptance criteria, description, and discussion context
- one or more full breadcrumbs provided by the user
- reusable step definitions stored in `docs/testcase-breadcrumbs.json`

The prompt must collect one or more full breadcrumbs, resolve each against the breadcrumbs repository, design the minimum viable Gherkin test set across all provided breadcrumbs, create the Test Case work items, inject the test steps, link the Test Cases to the resolved destination suite, and link them back to the source Work Item.

Injection model alignment:
- Use the same Azure DevOps Test Case injection lifecycle validated in `prompts/azure-devops/create-webservices-test-cases-from-user-story.md`.
- Reuse the same suite-resolution dependency `prompts/azure-devops/resolve-or-create-requirement-based-suite.md`.
- This prompt is for UI coverage only. If the requested test design type is not `UI`, stop and redirect to the appropriate prompt.

## Inputs
- **Source Work Item URL or Numeric ID**: Required. This is the Work Item from which the test cases will be derived (`Bug` or `User Story`). Request full Azure DevOps Work Item URL first and extract numeric ID internally. Accept numeric ID only when URL is not available.
- **Test Design Type**: Fixed value `UI`. This prompt supports only `UI` test design. Do not ask the user for this value.
- **Associated Requirement/User Story ID for Suite Ownership**: Optional. Use this when the source Work Item is a `Bug` and there is a linked `User Story` or requirement that should own the Requirement Based Suite. If not provided, continue with the source Work Item ID as fallback for suite resolution/creation.
- **Destination Suite ID** *(child)*: Optional numeric ID of an existing suite that will receive the generated Test Cases. Allowed suite types when provided: `requirementTestSuite` and `staticTestSuite`.
- **Test Plan ID** *(parent)*: Required in all execution paths. Needed both when reusing a suite and when creating one.
- **Preferred ID input format for suite reuse**: Ask the user for fragment-only input from Test Plans URL: `planId=<PLAN_ID>&suiteId=<SUITE_ID>`. Do not ask for the full URL.
- **Breadcrumbs**: Required. Collect one or more complete breadcrumb paths, one per line. Ask the user to enter all breadcrumbs they want covered, then confirm when done.
- **Breadcrumb Format Example (accepted)**: `Crumbs: Home > Serial Number > Dashboard > Left Hand Navigation (LHN) -Dashboard > Alternate Parts`
- **Multiple Breadcrumb Entry Example**:
  ```
  Crumbs: Home > Serial Number > Repair > Left Hand Navigation (LHN) - Repair
  Crumbs: Home > Serial Number > Parts > Left Hand Navigation (LHN) - Parts
  ```
- **Discussion/Comments Scope**: Number of latest comments to evaluate. Default: `20`.
- **Additional Instructions (Spanish Comments)**: Optional. Operational guidance only. Do not copy this text into titles, actions, expected results, or final Gherkin content.

Input safety note:
- Example IDs shown in this file are illustrative only.
- Never reuse IDs from previous runs unless the user explicitly provides them again.
- If any required input is missing, stop and request it explicitly before generating or executing commands.

## Constraints
- **Language**: English for all prompt content, test case titles, steps, and expected results.
- **Organization URL**: `https://dev.azure.com/cat-digital`
- **Project**: `Cat Digital`
- **Execution Input Mode Rule**: During execution, ask required inputs one at a time and do not batch multiple questions in one message.
- **Terminology**: Use official Azure DevOps terms only: Work Item, ID, Requirement Based Suite, Static Test Suite, Test Case, Test Plan, WIQL.
- **Type Rule**: This prompt is `UI`-only. The Test Design Type is always `UI` and must not be collected from the user.
- **ID Validation**: Validate every provided ID is numeric before any API call.
- **Work Item URL Rule**: If the user provides a URL, extract the numeric Work Item ID and validate it.
- **Breadcrumb Collection Rule**: Collect one or more complete breadcrumb paths, one per line. Ask the user to provide all breadcrumbs they want covered before proceeding. Do not infer omitted segments.
- **Breadcrumb Count Rule**: There is no fixed limit on the number of breadcrumbs. Accept all that the user provides.
- **Accepted Route Example**: `Crumbs: Home > Serial Number > Dashboard > Left Hand Navigation (LHN) -Dashboard > Alternate Parts` is a valid breadcrumb input format.
- **Breadcrumb Prefix Rule**: Accept and normalize optional `Crumbs:` prefix before segment resolution.
- **Breadcrumb Resolution Rule**: Resolve each crumb segment against `docs/testcase-breadcrumbs.json` using the `crumstep` field. Matching should be case-insensitive after trimming surrounding whitespace, while preserving the canonical repository value in output.
- **Missing Crumb Rule**: If any crumb is not found in `docs/testcase-breadcrumbs.json`, stop and report the missing crumb explicitly.
- **Reusable Step Rule**: Build scenario navigation from the resolved breadcrumb steps. Reuse common path segments across breadcrumbs logically, but keep each final Gherkin scenario independently executable.
- **Source of Truth**:
  - Title comes from `System.Title` on the Work Item.
  - Area comes from `System.AreaPath` on the Work Item.
  - Iteration comes from `System.IterationPath` on the Work Item.
  - Sprint label is always the last component of `System.IterationPath`.
  - Acceptance behavior comes first from `Microsoft.VSTS.Common.AcceptanceCriteria`, then `System.Description`, then discussion/comments.
- **Requirement Association Rule**: If the source Work Item type is `Bug`, the associated requirement/User Story ID is optional. If the user provides it, use it for suite ownership. If not, continue with the source Work Item ID as the suite ownership fallback.
- **Iteration Rule**: Never ask the user for iteration or sprint name. The iteration must always be the same as the Work Item iteration.
- **Suite Resolution Rule**: If the user provides `Destination Suite ID`, require `Test Plan ID` as well and validate the suite using direct lookup `planId + suiteId`. Never attempt to auto-discover `planId` by scanning all plans.
- **Suite Type Acceptance Rule**: If `Destination Suite ID` is provided, the resolved suite type must be either `requirementTestSuite` or `staticTestSuite`.
- **Suite Creation Rule**: If the user does not provide `Destination Suite ID`, require `Test Plan ID` and create/reuse a Requirement Based Suite for the Work Item under that plan.
- **Suite Hierarchy Rule**: Never treat a container or parent suite as the execution target for this prompt. The resolved suite must be a direct executable destination suite.
- **Suite Resolution Reuse Rule**: Use `prompts/azure-devops/resolve-or-create-requirement-based-suite.md` as the source of truth for suite resolution or creation behavior. Do not duplicate or override that logic.
- **Requirement Mapping Rule**: If a provided suite is associated with a different requirement/work item than the requested source Work Item, stop and request confirmation before continuing.
- **Case Ratio Baseline**: Use a default pattern of 1 happy path plus up to 3 negative/edge/boundary scenarios per core behavior when those scenarios cover distinct risks or observable outcomes.
- **Case Ratio Clarification**: This is the default framework pattern, not a rigid quota. If no meaningful negative, edge, or boundary coverage exists, do not invent scenarios just to reach four cases.
- **Case Ratio Expansion Rule**: If more than 3 distinct negative/edge/boundary scenarios add real coverage value, include them, with a maximum of 5 negative/edge/boundary scenarios per happy path.
- **Minimum Coverage**: Generate only the minimum number of test cases needed to cover acceptance criteria, core behavior, distinct breadcrumbs, and distinct risks.
- **Duplicate Avoidance Rule**: If two breadcrumbs drive the same validation intent, consolidate coverage instead of creating redundant scenarios.
- **Title Format**: `TC### - <SOURCE_TYPE_TAG> - <Short Significant Scenario>`, where `<SOURCE_TYPE_TAG>` must be `US` when source type is `User Story`, and `BUG` when source type is `Bug`.
- **Title Source-Type Rule**: Do not include Work Item numeric ID or abbreviated Work Item title in Test Case titles. Use only `US` or `BUG` as the source-type tag plus a concise scenario description.
- **Title Wording Rule**: Test Case titles and scenario summaries must describe observable product behavior. Do not include generic labels such as `Happy path`, `Edge case`, or `Negative case` in titles.
- **Step Limits**: Max 180 characters per step action; max 220 characters per expected result.
- **Step Count Rule**: Do not cap test cases at 3 steps. Use as many action/expected result pairs as needed to cover acceptance criteria and distinct risks without adding filler.
- **First-Step Rule**: The first navigation/action steps must come from the resolved breadcrumb path, starting with the first available crumb in the selected breadcrumb.
- **Final Validation Rule**: The last validation step in each scenario must reflect the behavior under test from acceptance criteria, description, or repro context. Do not stop at breadcrumb navigation alone.
- **Secrets Rule**: Never include real tokens, PAT values, or secrets in output.
- **Operational Safety Rule**: Follow the validated Azure DevOps CLI patterns documented in `docs/ai-known-failures.md` and the injection patterns already validated in `prompts/azure-devops/create-webservices-test-cases-from-user-story.md`.
- **Spanish Instructions Rule**: If the user provides `<ADDITIONAL_INSTRUCTIONS>`, use them to inform test design choices but never copy their text into test case titles, actions, or expected results.

## Execution Safety Profile
- **Shared guidance source**: `docs/ai-known-failures.md`
- **Injection baseline source**: `prompts/azure-devops/create-webservices-test-cases-from-user-story.md`
- **Validated patterns reused by this prompt**:
  1. Prefer `az boards work-item create` for Test Case creation.
  2. Prefer `az boards work-item update --field "Microsoft.VSTS.TCM.Steps=<xml>"` for step population.
  3. Use PowerShell variables or temp files for long XML payloads.
  4. Verify every write operation with an immediate read.
  5. Write all multi-step PowerShell automation to a `.ps1` file under `scripts/` only if explicit automation is requested. Otherwise keep the prompt as the source of truth.
  6. Never use `$pid` or `$PID` as a variable name in PowerShell.

## Task

### Input Collection Mode
Before pre-flight validation, collect missing required inputs sequentially and do not infer missing values.

Ask in this exact order:
1. Source Work Item URL first; if unavailable, ask for numeric ID.
2. If the source Work Item is a `Bug`, ask whether there is an associated requirement/User Story ID for Requirement Based Suite ownership. If not provided, continue with the source Work Item ID as fallback.
3. Test Plan fragment for suite reuse or creation:
   - `planId=<PLAN_ID>&suiteId=<SUITE_ID>` when reusing an existing suite.
   - `planId=<PLAN_ID>` when no existing suite is provided yet.
4. All breadcrumbs the user wants covered (one per line). After the user enters them, ask "Are there more breadcrumbs to add?" and collect additional ones until the user confirms they are done.
5. Optional additional instructions, only after required inputs are complete.

### Pre-Flight Input Validation
Before starting any API calls:
1. Confirm Source Work Item input was provided as URL or numeric ID and resolve Work Item ID for this run.
2. Validate the Work Item ID is numeric.
3. If `Associated Requirement/User Story ID for Suite Ownership` is provided, validate it is numeric.
5. Require `Test Plan ID` in all cases and validate it is numeric.
6. If `Destination Suite ID` is provided, validate it is numeric and perform a direct `planId + suiteId` lookup immediately.
7. Validate that at least one breadcrumb was provided and that every breadcrumb is non-empty.
8. If `Discussion/Comments Scope` is missing or empty, set it to `20`.
9. If `Additional Instructions` are provided, confirm they are operational guidance only.

### Step 1: Retrieve Work Item Details
```bash
az boards work-item show \
  --org https://dev.azure.com/cat-digital \
  --id <WORK_ITEM_ID> \
  --expand all \
  --only-show-errors \
  --output json
```

Retrieve and store:
- `System.WorkItemType`
- `System.Title`
- `System.AreaPath`
- `System.Description`
- `Microsoft.VSTS.Common.AcceptanceCriteria`
- `Microsoft.VSTS.TCM.ReproSteps` when present
- `System.IterationPath`
- latest comments/discussion when available

Source priority for test design:
1. Acceptance Criteria
2. Description
3. Repro Steps
4. Discussion/Comments

Conflict rule:
- If Description, Repro Steps, or Discussion conflict with Acceptance Criteria, follow Acceptance Criteria and record the conflict in output assumptions.

### Step 2: Resolve or Create the Destination Suite
Use this branching behavior:
- If `Destination Suite ID` is provided:
  - Validate it directly with `planId + suiteId` lookup.
  - Accept only when resolved suite type is `requirementTestSuite` or `staticTestSuite`.
  - Set `Resolved Plan ID` and `Resolved Suite ID` from that lookup.
- If `Destination Suite ID` is not provided:
  - Execute `prompts/azure-devops/resolve-or-create-requirement-based-suite.md` with:
    - `User Story Work Item ID = <ASSOCIATED_REQUIREMENT_USER_STORY_ID_FOR_SUITE_OWNERSHIP>` when the source Work Item is a `Bug` and the associated requirement/User Story ID was provided
    - `User Story Work Item ID = <WORK_ITEM_ID>` when the source Work Item is already the requirement/User Story, or when the source Work Item is a `Bug` and no associated requirement/User Story ID was provided
    - `Test Plan ID = <TEST_PLAN_ID>`

Required handoff contract:
- `Resolved Plan ID`
- `Resolved Suite ID`

### Step 3: Resolve Breadcrumbs into Reusable Steps
For each provided breadcrumb (repeat for every breadcrumb the user supplied):
1. Remove optional `Crumbs:` prefix, then split the breadcrumb by `>`.
2. Trim each crumb segment.
3. Resolve every crumb segment against `docs/testcase-breadcrumbs.json` using case-insensitive `crumstep` matching after trimming whitespace.
4. Build the ordered navigation/action path from the resolved `step` and `expected_result` values.
5. If any crumb in any breadcrumb is missing, stop and report every missing crumb explicitly before continuing.

Resolution output for internal planning must preserve, for each breadcrumb:
- breadcrumb index and original text
- resolved crumb order
- action/expected-result pairs mapped to each crumb

### Step 4: Design Test Scenarios
Design the minimum valid set of UI test cases using all resolved breadcrumbs plus Work Item behavior.

Coverage rules:
- Start from the minimum viable set of scenarios needed for coverage.
- Each breadcrumb is a candidate execution path. Apply the 1 happy path + up to 3 negative/edge/boundary ratio per breadcrumb only when those scenarios validate distinct risks. Do not force scenarios that have no real coverage value.
- Create separate scenarios only when the final validation intent, acceptance behavior, or risk is distinct.
- If two breadcrumbs lead to the same validation intent and risk, consolidate instead of duplicating.
- Keep each scenario independently executable.
- The final step pair of each scenario must validate the Work Item behavior under test.
- Use Gherkin structure with Given, When, Then, and And as needed.

### Step 5: Create Test Case Work Items
Preferred command pattern:
```bash
az boards work-item create \
  --org https://dev.azure.com/cat-digital \
  --project 'Cat Digital' \
  --type 'Test Case' \
  --title '<TC_TITLE>' \
  --area '<WORK_ITEM_AREA_PATH>' \
  --iteration '<WORK_ITEM_ITERATION_PATH>' \
  --only-show-errors \
  --output json
```

Creation rules:
- Create all Test Cases in `Design` state unless the process sets a different default automatically.
- Use `System.AreaPath` from the source Work Item.
- Use `System.IterationPath` from the source Work Item.
- Never ask the user for iteration or sprint.

### Step 6: Inject Test Steps into Each Test Case
Use the same verified XML pattern and update method defined in `prompts/azure-devops/create-webservices-test-cases-from-user-story.md`.

Injection rules:
- Each step must contain one Action and one Expected Result.
- Use render-compatible `Microsoft.VSTS.TCM.Steps` XML with quoted attributes, `ActionStep`, and `<description/>`.
- After writing steps, read them back and verify the persisted structure.
- Do not report completion if the persisted XML is empty or malformed.

### Step 7: Link Test Cases to the Resolved Destination Suite
Use the resolved `Resolved Plan ID` and `Resolved Suite ID` to link every created Test Case to the target destination suite.

### Step 8: Validate Test Case Creation and Links
For each created Test Case ID, verify:
- title format
- area path
- iteration path
- persisted steps XML structure
- suite membership
- relation back to the source Work Item

### Step 9: Link the Source Work Item to the Test Cases
For each Test Case ID, create the Work Item relation back to the source Work Item using the same validated relation-add flow used by the Webservices prompt.

## Output Format

### Inputs Summary
- Source Work Item ID: <id>
- Work Item Type: <bug_or_user_story>
- Associated Requirement/User Story ID for Suite Ownership: <id_or_not_provided>
- Test Design Type: UI
- Full Breadcrumb: <breadcrumb>

### Breadcrumb Resolution Summary
- Breadcrumb: <breadcrumb>
- Resolved crumbs:
  - <crumb_1>
  - <crumb_2>
  - <...additional_resolved_crumbs_as_needed>
- Missing crumbs: <none_or_list>

### Coverage Analysis
- Acceptance criteria covered: <list>
- Distinct risks covered: <list>
- Duplicates removed: <list_or_none>
- Final test case count: <count>

### Test Cases
```gherkin
Scenario: <scenario_title>
  Given <step>
  And <step>
  When <step>
  And <step>
  Then <expected_outcome>
  And <expected_outcome>
```

### Execution Result
- Resolved Plan ID: <id>
- Resolved Suite ID: <id>
- Created Test Case IDs: <list_or_none>

### Validation Checklist
- [ ] Work Item retrieved successfully
- [ ] Test design type confirmed as UI
- [ ] Full breadcrumb collected
- [ ] All breadcrumb segments resolved from repository
- [ ] Acceptance criteria analyzed
- [ ] Minimum sufficient test cases generated
- [ ] Duplicate scenarios avoided
- [ ] Test Cases created
- [ ] Steps injected and validated
- [ ] Suite links verified
- [ ] Source Work Item links verified

### Final Status
- `COMPLETED`
- `COMPLETED WITH ASSUMPTIONS`
- `BLOCKED`
