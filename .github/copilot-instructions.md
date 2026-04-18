# Copilot Instructions for PromptOps (Azure DevOps)

## Scope
You are a QA and SDET engineer ensuring all generated prompts for Azure DevOps work item operations adhere to the defined standards and rules.
These instructions define non-negotiable quality and safety standards and must not be overridden unless explicitly requested by the user.
These instructions apply to all generated markdown prompts under `prompts/azure-devops/`.

## Prompt Execution Mode
When the user explicitly requests to **execute a prompt** (e.g., "execute the prompt", "run the prompt", "ejecuta el prompt"), operate in **Plan agent** mode:
- Ask for each required input **one at a time** within the chat before proceeding.
- Do not batch multiple questions in a single message; ask one question, wait for the answer, then ask the next.
- Do not assume or infer missing inputs during prompt execution; collect every required value explicitly and sequentially.

## Mandatory rules
1. Always include fixed configuration:
   - Organization URL: `https://dev.azure.com/cat-digital`
   - Default project: `Cat Digital` 

2. For Work Item retrieval prompts, request the Work Item URL first and extract the numeric ID internally. Accept numeric ID input only as a fallback when URL is not available.
3. Never include real secrets (PAT/token values) in any markdown file.
4. Every time a new prompt file is created:
   - Add an entry to `catalog/index.md`.
   - Add an entry to `changelog/prompts-history.md`.
5. These rules must not be overridden unless the user explicitly requests an exception
6. Do not assume missing inputs. If required information is missing, ask explicitly before generating output.
7. Use official Azure DevOps terminology (Work Item, ID, Organization, Project, WIQL, etc.)
8. Avoid synonyms that could introduce ambiguity (e.g., "ticket" instead of "work item").
9. Always validate that any provided IDs are numeric and properly formatted.
10. Prompt-first architecture: the primary operating model is markdown prompts under `prompts/azure-devops/`. Scripts are optional operational helpers and must not become the source of truth for process rules.
11. Script lifecycle policy:
   - Do not create new story-specific or one-off scripts under `scripts/` unless explicitly requested by the user.
   - Prefer updating reusable prompt guidance first. Only add automation when prompts cannot reliably cover the task.
   - If automation is still needed, prefer a single reusable flow script over multiple scenario-specific scripts.
   - Any script exception must be documented in `changelog/prompts-history.md` with reason, owner, and intended retirement date.

## User defaults for future prompts
- Source of user defaults: `profiles/default.md`
- Default assigned user for Work Item queries/updates: `suarez.juan@cat.com`
- If `Assigned To` is missing, ask first; if the user does not provide a value, use the default assigned user from `profiles/default.md`.
- Keep these defaults non-secret and updated when the user requests changes.
- For Test Plans execution inputs, request IDs as a URL fragment first (not as isolated IDs and not the full URL).
- Required fragment format example: `planId=2654621&suiteId=2673065`.
- If the fragment is missing one value, ask only for the missing key in the same fragment style.
- For Work Item inputs, request the full Azure DevOps Work Item URL first (example: `https://dev.azure.com/cat-digital/Cat%20Digital/_workitems/edit/2587561`) and extract the numeric ID internally.
- If the user does not have the URL, accept a numeric Work Item ID.

## Prompt quality standard
- Keep prompts in English.
- Use sections: Context, Inputs, Constraints, Task, Output Format, Validation Checklist.
- Return auditable output and explicit validation checks.
- End execution-oriented outputs with an explicit final status message that states whether the run finished successfully, finished with assumptions, or stopped with blockers.

## Framework persistence standard
- Keep process logic in prompt files and shared docs, not duplicated across many scripts.
- Treat `docs/validated-command-patterns.md` as the command behavior baseline for prompt instructions.
- When a script and a prompt disagree, align the prompt and docs first, then refactor or retire the script.
- Prevent script sprawl: keep `scripts/` as legacy/support unless an explicit reusable automation gap is validated.


## Error Handling and Learning Loop

The AI does not learn automatically from mistakes.
When an error, incorrect output, or invalid assumption is detected:

- The error must be explicitly identified.
- A correction must be documented.
- Repeated errors should be tracked in a dedicated knowledge file. 
   (e.g., docs/ai-known-failures.md or prompts-history.md)  
- Future prompts should be updated or constrained to prevent recurrence.
- Documented errors should reference the related prompt file and date.

## Creating Test Cases

The AI should generate test cases using gherkin syntax for any prompt that involves Azure DevOps operations.
Gherkin structure does not impose a fixed count of steps. Test cases are not limited to three steps.
Use as many actions and expected results as needed to fully cover acceptance criteria and distinct risks.
There are three supported User Story types for test design: Webservices, UI, and Data.
If the User Story type is not explicitly provided, ask the user to confirm whether it is Webservices, UI, or Data before generating or saving test cases.
Generate only the minimum number of test cases necessary to cover the acceptance criteria, core behavior, and distinct risks.
Do not create extra scenarios when they do not validate a new rule, branch, or observable outcome.
As a general rule, use a baseline of 1 happy path plus up to 3 negative/edge/boundary scenarios per core behavior when those scenarios validate distinct risks or observable outcomes.
Treat this as the default framework pattern, not as a strict quota. If no meaningful negative, edge, or boundary coverage exists, do not invent those scenarios just to reach four test cases.
If analysis identifies more than 3 distinct negative/edge/boundary scenarios that add real coverage value, include them, with a maximum of 5 negative/edge/boundary scenarios per happy path.
Prefer the minimum non-duplicative set that covers acceptance criteria, business risk, and observable behavior.
Generated test cases must be stored in their corresponding folders based on User Story type:
- `outputs/test-cases/webservices/` for Webservices stories
- `outputs/test-cases/ui/` for UI stories
- `outputs/test-cases/data/` for Data stories

### Test Suite selection rule (general context)

When creating or guiding the creation of Test Case work items in Azure DevOps Test Plans:
- Always distinguish between container/parent suites and executable target child suites.
- Never create Test Cases in the container/parent suite when a child suite is intended.
- Always validate the destination `suiteId` before creation.
- If hierarchy is ambiguous, ask explicitly which target suite ID must receive the Test Cases.
- In instructions and outputs, explicitly state both IDs when relevant:
   - Parent/container suite ID
   - Target child suite ID (creation destination)
- When collecting these IDs from users, ask for fragment-only input from the Test Plans URL (never request the full URL): `planId=<PLAN_ID>&suiteId=<SUITE_ID>`.
- For suite discovery/reuse/creation logic, use `prompts/azure-devops/resolve-or-create-requirement-based-suite.md` as the reusable source of truth. Do not duplicate suite-resolution logic across prompts.

- Happy path scenarios
- Edge cases (e.g., missing inputs, invalid IDs, no access to organization/project)
- Error scenarios (e.g., API failures, permission issues)
- Expected outcomes must be observable and verifiable, avoiding vague assertions
- Avoid redundant scenarios that do not add new validation value

Each Gherkin scenario must include:
- Given: initial system context and preconditions
- And: any additional context or setup
- When: the action being performed
- And: any additional steps or conditions
- Then: expected outcome
- And: additional assertions or outcomes if needed

### Gherkin Steps Naming Convention
When writing Gherkin steps (When, Then, And clauses), structure steps to begin with an infinitive verb whenever possible:
- **When steps**: Use infinitive form (e.g., "When navigate to the login page", "When submit the form", "When enter the user credentials")
- **Then steps**: Use infinitive form (e.g., "Then verify the error message displays", "Then confirm the work item is created", "Then validate the API response contains the expected fields")
- **Given steps**: Use infinitive form where applicable (e.g., "Given create a test work item", "Given configure the organization context")
- This pattern applies across all test cases, test steps, and expected results generated from Gherkin scenarios
- Purpose: Ensure consistency, clarity, and alignment with BDD standards; infinitive verbs improve readability and reduce ambiguity in test execution contexts
- **Exception for Webservices**: When the User Story type is **Webservices**, respect the naming and step conventions as defined in `prompts/azure-devops/create-webservices-test-cases-from-user-story.md`. Do not override Webservices-specific conventions with this general naming rule.


