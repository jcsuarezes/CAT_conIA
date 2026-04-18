# Prompt: Resolve or Create Requirement Based Suite

## Context
You are resolving the execution destination suite for Azure DevOps Test Case operations.
This prompt standardizes suite discovery and creation so users can reuse one flow across different User Stories, Test Plans, and test case generation prompts.

Fixed configuration:
- Organization URL: `https://dev.azure.com/cat-digital`
- Default project: `Cat Digital`

## Inputs
- Project (default: `Cat Digital`)
- User Story Work Item ID (required, numeric)
- **Requirement Based Suite ID** *(child)*: Optional numeric ID of the Requirement Based Suite (child suite) that will receive the test cases. This suite must live inside the Test Plan specified below.
- **Test Plan ID** *(parent container)*: Required in ALL cases — the Test Plan is the parent that owns the suite. Needed both when reusing an existing suite and when creating a new one. The API requires `planId` for every suite operation; auto-discovering it by scanning all plans is not reliable in large organizations with 100+ test plans.

> **Critical rule**: Never attempt to discover `planId` from a `suiteId` alone by iterating all test plans. This approach times out and is architecturally unreliable. Always collect **Test Plan ID (parent)** from the user alongside **Requirement Based Suite ID (child)**.

## Constraints
- Do not expose secrets or tokens.
- Validate every provided ID is numeric before any call.
- Follow shared command guidance in `docs/validated-command-patterns.md`.
- Never use container/parent suites as final execution target.
- Destination must be exactly one Requirement Based Suite.
- If ambiguity exists, stop and ask explicitly.
- Treat empty stdout as unvalidated even when exit code is `0`.

## Task
1. Validate required inputs and numeric IDs.
2. Validate that `Test Plan ID` exists via direct plan lookup before any suite operation:
   - Use `az devops invoke --area testplan --resource plans --route-parameters planId=<TEST_PLAN_ID>`.
   - If the plan is not found, stop immediately with BLOCKED and report the exact API error.
3. If `Requirement Based Suite ID` is provided:
   - Perform a direct lookup using both `planId` and `suiteId` (do NOT scan all plans).
   - Use `az devops invoke --area testplan --resource suites --route-parameters project='Cat Digital' planId=<PLAN_ID> suiteId=<SUITE_ID> --api-version 7.1`.
   - If the suite is not found in the specified plan, stop with BLOCKED.
   - Collect the single match and set `Resolved Plan ID` and `Resolved Suite ID`.
4. Validate provided-suite branch:
   - If the direct lookup fails: stop with BLOCKED, report the exact error.
   - If the suite is found: set `Resolved Plan ID` and `Resolved Suite ID`.
5. If suite ID was not provided:
   - The Test Plan ID is already validated (step 2).
   - List suites in the plan and detect Requirement Based Suites linked to `User Story Work Item ID`.
   - If one exists, reuse it.
   - If more than one exists, stop and ask user which one to reuse.
   - If none exists, create one with:
     - `suiteType=requirementTestSuite`
     - `requirementId=<User Story Work Item ID>`
6. Post-resolution validation:
   - Confirm resolved suite is Requirement Based.
   - Confirm resolved suite maps to the expected User Story ID; if different, stop and request confirmation.
   - Confirm destination is not a parent/container suite.
7. Return an auditable contract output.

## Output Format
### Resolution Summary
- Project used:
- User Story Work Item ID:
- Input Suite ID:
- Input Plan ID:
- Resolution path: `provided-suite` | `reused-existing` | `created-new`

### Contract Output
- Resolved Plan ID:
- Resolved Suite ID:
- Suite Type:
- Linked Requirement ID:
- Is Executable Target Suite: `yes/no`

### Evidence
- Plans checked:
- Suite matches found:
- Validation notes:

### Validation Checklist
- [ ] IDs validated as numeric
- [ ] Destination suite resolved to exactly one match
- [ ] Destination suite is Requirement Based
- [ ] Destination suite is executable target (not container/parent)
- [ ] Linked requirement validated against User Story ID
- [ ] No secrets displayed
