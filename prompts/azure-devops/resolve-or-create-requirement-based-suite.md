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
- Requirement Based Suite ID (optional, numeric)
- Test Plan ID (required only when suite ID is not provided, numeric)

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
2. If `Requirement Based Suite ID` is provided:
   - List plans and attempt suite resolution by plan.
   - For each plan, use both:
     - suite listing in the plan
     - direct lookup with `planId + suiteId`
   - Collect all matches.
3. Validate provided-suite branch:
   - If zero matches: stop and request a valid suite ID.
   - If more than one match: stop and report ambiguity.
   - If one match: set `Resolved Plan ID` and `Resolved Suite ID`.
4. If suite ID was not provided:
   - Validate `Test Plan ID` exists.
   - List suites in the plan and detect Requirement Based Suites linked to `User Story Work Item ID`.
   - If one exists, reuse it.
   - If more than one exists, stop and ask user which one to reuse.
   - If none exists, create one with:
     - `suiteType=requirementTestSuite`
     - `requirementId=<User Story Work Item ID>`
5. Post-resolution validation:
   - Confirm resolved suite is Requirement Based.
   - Confirm resolved suite maps to the expected User Story ID; if different, stop and request confirmation.
   - Confirm destination is not a parent/container suite.
6. Return an auditable contract output.

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
