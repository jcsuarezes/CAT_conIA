
# Prompt: Populate Test Steps and Expected Results (Step-by-Step, Persist Breadcrumbs)

## Context
You are collecting and validating one test step payload per cycle for Azure DevOps Test Cases. The flow is sequential and interactive in a continuous loop: process one payload, return output, and if not final, request the next step without re-executing the prompt.

Scope rule:
- This prompt is only for filling one test step payload.
- Do not create test cases.
- Do not navigate to any URL.

Fixed configuration:
- Organization URL: `https://dev.azure.com/cat-digital`
- Default project: `Cat Digital`
- Language: English only in final output
- Persistence file: `docs/testcase-breadcrumbs.json`

## Inputs
- **Crumstep**: Specific step name (for example: `Home`, `Login`, `Search`). Required.
- **Action (Test Step)**: A clear action to perform. Can be in any language; translate to English if needed. Required.
- **Expected Result**: An observable, testable outcome for that action. Can be in any language; translate to English if needed. Required.
- **Is Last Step**: `yes` or `no` to indicate whether this is the final step so the same prompt can continue in the same run without re-execution.

## Constraints
- **One step per cycle**: Process exactly one Crumstep + Action + Expected Result payload per cycle.
- **Sequential interaction**: Ask inputs one at a time and do not infer missing values.
- **Question limit**: Ask only these 4 questions in order: Crumstep, Action, Expected Result, Is Last Step (`yes|no`).
- **Minimal output only**: Limit successful output to the processed step content only.
- **No test case creation**: Do not create or suggest creating Test Case work items from this prompt.
- **No URL navigation**: Do not request, open, or navigate to links/URLs.
- **Crumstep length**: Maximum 60 characters.
- **Action length**: Maximum 180 characters after translation/refinement.
- **Expected Result length**: Maximum 220 characters after translation/refinement.
- **Translation rule**: If input is not in English, translate to concise professional English aligned with Azure DevOps testing terminology.
- **Coherence refinement**: Only refine when needed for clarity/grammar/terminology; preserve user intent.
- **Persistence required**: After validation, persist the processed step into `docs/testcase-breadcrumbs.json`.
- **No extra metadata**: Do not add ids, titles, scenario labels, preconditions, character counters, or additional fields.
- **Observable outcomes only**: Expected Result must be verifiable and specific.

## Task

### Scope Enforcement
If the user asks to create test cases or navigate/open any URL:
1. Return this rejection message:
  - "Out of scope for this prompt: only step payload filling is allowed."
  - "Test case creation and URL navigation are not allowed in this prompt."
2. Continue the same flow by requesting only the next required input according to sequence.
3. Do not terminate the run unless input validation fails.

### Input Collection Mode
Collect inputs sequentially and one by one:
1. Ask for **Crumstep**.
2. Ask for **Action (Test Step)**.
3. Ask for **Expected Result**.
4. Ask: **Is this the last step?** (`yes | no`).

Do not ask any other question unless validation fails and a correction is required.

### Translation & Coherence Refinement
If Action or Expected Result is not in English:
1. Translate to English.
2. Apply minimal coherence refinement only when necessary, without asking additional questions.

### Pre-Flight Validation
Before output:
1. Validate Crumstep is non-empty and <= 60 chars.
2. Validate Action is non-empty and <= 180 chars.
3. Validate Expected Result is non-empty and <= 220 chars.
4. Validate Is Last Step is exactly `yes` or `no`.
5. If any validation fails, stop and return explicit blocker.

### Processing
1. Write one processed step into `docs/testcase-breadcrumbs.json` using this structure only: `crumstep`, `step`, `expected_result`.
2. Persistence behavior:
  - If there is an existing empty placeholder pair (`crumstep`, `step`, and `expected_result` all empty), replace the first empty placeholder.
  - Otherwise, append the new pair to `entries[entries.length - 1].step_result_pairs`.
  - If `entries` is missing or empty, create one entry with `step_result_pairs` and insert the new pair.
3. Return the processed step content plus minimal sequence guidance.
4. Return continuation guidance based on Is Last Step:
  - If `yes`: indicate sequence complete.
  - If `no`: ask the next Crumstep immediately in the same execution flow.
5. Do not return validation summaries, character counts, or checklists in normal successful output.

## Output Format

### Scope Rejection Message (when applicable)
```
Out of scope for this prompt: only step payload filling is allowed.
Test case creation and URL navigation are not allowed in this prompt.
```

### Processed Step
```text
Crumstep: <crumstep_after_refinement>
Action: <action_after_translation_and_refinement>
Expected Result: <expected_result_after_translation_and_refinement>
Sequence Status: <completed_or_request_next_crumstep>
```

## Notes
- This prompt is intentionally step-by-step and stateful for breadcrumb persistence.
- Keep the same prompt execution active for consecutive steps; do not require re-execution when `Is Last Step = no`.
- Execution behavior is fixed: ask Crumstep, then Action, then Expected Result, then Is Last Step (`yes|no`).
- If Is Last Step is `no`, continue requesting the next Crumstep in the same run.
- Translation and coherence refinement remain internal behaviors and should not be reported in successful output.
- Successful output should contain only the processed fields plus minimal sequence guidance.
- Each successful cycle must persist exactly one processed pair in `docs/testcase-breadcrumbs.json`.
