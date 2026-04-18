
# Prompt: Populate Test Steps and Expected Results (Step-by-Step, No Breadcrumbs)

## Context
You are collecting and validating one test step payload per cycle for Azure DevOps Test Cases. The flow is sequential and interactive in a continuous loop: process one payload, return output, and if not final, request the next step without re-executing the prompt.

Scope rule:
- This prompt is only for filling the JSON step payload.
- Do not create test cases.
- Do not navigate to any URL.

Fixed configuration:
- Organization URL: `https://dev.azure.com/cat-digital`
- Default project: `Cat Digital`
- Language: English only in final output
- Persistence rule: Do not store, append, or read from breadcrumbs files

## Inputs
- **Crumstep**: Specific step name (for example: `HOME`, `LOGIN`, `SEARCH`). Required.
- **Action (Test Step)**: A clear action to perform. Can be in any language; translate to English if needed. Required.
- **Expected Result**: An observable, testable outcome for that action. Can be in any language; translate to English if needed. Required.
- **Is Last Step**: `yes` or `no` to indicate whether this is the final step so the same prompt can continue in the same run without re-execution.

## Constraints
- **One step per cycle**: Process exactly one Crumstep + Action + Expected Result payload per cycle.
- **Sequential interaction**: Ask inputs one at a time and do not infer missing values.
- **Question limit**: Ask only these 4 questions in order: Crumstep, Action, Expected Result, Is Last Step (`yes|no`).
- **JSON-only operation**: Limit output to the defined step JSON payload and validation metadata for this prompt.
- **No test case creation**: Do not create or suggest creating Test Case work items from this prompt.
- **No URL navigation**: Do not request, open, or navigate to links/URLs.
- **Crumstep length**: Maximum 60 characters.
- **Action length**: Maximum 180 characters after translation/refinement.
- **Expected Result length**: Maximum 220 characters after translation/refinement.
- **Translation rule**: If input is not in English, translate to concise professional English aligned with Azure DevOps testing terminology.
- **Coherence refinement**: Only refine when needed for clarity/grammar/terminology; preserve user intent.
- **No breadcrumbs**: Do not compare against, write to, or depend on `docs/testcase-breadcrumbs.json`.
- **Breadcrumb rejection**: If the user provides or requests breadcrumbs, stop and remind: "This prompt only accepts one Crumstep, one Action, one Expected Result, and Is Last Step per step. Breadcrumbs are not accepted."
- **Observable outcomes only**: Expected Result must be verifiable and specific.

## Task

### Scope Enforcement
If the user asks to create test cases or navigate/open any URL:
1. Return this rejection message:
  - "Out of scope for this prompt: only JSON step payload filling is allowed."
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
2. Report translation:
   - `Original: <input>`
   - `Translated: <output>`
3. Apply minimal coherence refinement only when necessary, without asking additional questions.

### Pre-Flight Validation
Before output:
1. Validate Crumstep is non-empty and <= 60 chars.
2. Validate Action is non-empty and <= 180 chars.
3. Validate Expected Result is non-empty and <= 220 chars.
4. Validate Is Last Step is exactly `yes` or `no`.
5. If any validation fails, stop and return explicit blocker.

### Processing
1. Do not write to any file.
2. Return the processed one-step payload and character counts.
3. Return continuation guidance based on Is Last Step:
  - If `yes`: indicate sequence complete.
  - If `no`: ask the next Crumstep immediately in the same execution flow.

## Output Format

### Translation & Refinement Report (if applicable)
```
Original Input:
- Crumstep: <original_crumstep>
- Action: <original_action>
- Expected Result: <original_expected_result>

Translated to English:
- Crumstep: <crumstep_after_refinement>
- Action: <translated_action>
- Expected Result: <translated_expected_result>

Coherence Refinements Applied:
- <none_or_list>
```

### Validation Result
- Translation required: `yes | no`
- Coherence refinements: `yes | no`
- Crumstep valid: `yes | no`
- Action valid: `yes | no`
- Expected Result valid: `yes | no`
- Is last step: `yes | no`

### Breadcrumb Rejection Message (when applicable)
```
Breadcrumbs are not accepted in this prompt.
This prompt only accepts one Crumstep, one Action, one Expected Result, and Is Last Step per step.
```

### Scope Rejection Message (when applicable)
```
Out of scope for this prompt: only JSON step payload filling is allowed.
Test case creation and URL navigation are not allowed in this prompt.
```

### Step Output
```json
{
  "operation": "single_step",
  "status": "ready",
  "step_pair": {
    "crumstep": "<crumstep_after_refinement>",
    "step": "<action_after_translation_and_refinement>",
    "expected_result": "<expected_result_after_translation_and_refinement>"
  },
  "character_count": {
    "crumstep": <count>,
    "action": <count>,
    "expected_result": <count>
  },
  "sequence": {
    "is_last_step": "<yes_or_no>",
    "next_action": "<ask_next_crumstep_if_no_else_completed>"
  }
}
```

### Validation Checklist
- [ ] Crumstep input received
- [ ] Action input received
- [ ] Expected Result input received
- [ ] Translation performed if needed
- [ ] Coherence reviewed
- [ ] Crumstep <= 60 chars
- [ ] Action <= 180 chars
- [ ] Expected Result <= 220 chars
- [ ] Is Last Step valid (`yes | no`)
- [ ] No breadcrumb storage/read used
- [ ] If breadcrumb detected, rejection reminder shown
- [ ] If out-of-scope request detected, scope rejection shown and flow continued
- [ ] Output contains exactly one step-result pair

## Notes
- This prompt is intentionally step-by-step and stateless for storage.
- Keep the same prompt execution active for consecutive steps; do not require re-execution when `Is Last Step = no`.
- Execution behavior is fixed: ask Crumstep, then Action, then Expected Result, then Is Last Step (`yes|no`).
- If Is Last Step is `no`, continue requesting the next Crumstep in the same run.
