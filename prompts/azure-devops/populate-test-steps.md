# Prompt: Populate Test Steps and Expected Results

## Context
You are collecting and validating test step-result pairs for Azure DevOps Test Cases. Each pair consists of a clear action and an observable expected result. Store valid pairs in a structured JSON repository for reuse and import into Test Plans.

Fixed configuration:
- Organization: `Cat Digital`
- Storage format: JSON (step-result pairs only)
- Storage location: `docs/testcase-breadcrumbs.json`
- Language: English only

## Inputs
- **Action (Test Step)**: A clear, concise action to be performed. Can be in any language; will be translated to English if needed. Required.
- **Expected Result**: An observable, testable outcome of the action. Can be in any language; will be translated to English if needed. Required.
- **Storage Mode**: `append` (add to breadcrumbs), `preview` (show JSON structure only, no save), or `export` (output formatted markdown).
- **Optional Metadata**: Test Case ID, User Story ID, scenario name, or parent node context (for organizational reference and duplicate disambiguation; not saved in breadcrumbs).

## Constraints
- **Action length**: Maximum 180 characters (after translation and coherence refinement).
- **Expected Result length**: Maximum 220 characters (after translation and coherence refinement).
- **Language acceptance**: Action and Expected Result can be submitted in any language. They will be translated to English.
- **Translation rule**: If input is not in English, translate to English using professional, concise terminology aligned with Azure DevOps/test automation standards.
- **Coherence refinement**: Review translated text for grammatical correctness, clarity, and consistency with test automation terminology. Make minor refinements for readability but do NOT rewrite unnecessarily. Keep original intent intact.
- **Refinement guardrail**: Only suggest changes if the text is unclear, contains typos, uses non-standard terminology, or lacks parallelism with other steps. Do NOT change professional voice or make stylistic improvements beyond clarity.
- **Duplicate detection**: Compare the translated/refined Action against existing entries in `docs/testcase-breadcrumbs.json`. If a duplicate or near-duplicate is found (semantic similarity > 85%), stop and report the match.
- **Duplicate handling**: If a duplicate is detected, ask the user to:
  1. Confirm whether it is truly the same step in a different context.
  2. If yes, provide a **parent node context** (e.g., "TC001 - Search scenario", "Setup phase", "Baseline request") to store both as related pairs.
  3. If no, clarify the difference so the system can distinguish them.
- **Observable outcomes**: Expected results must be verifiable and specific, not vague assertions.
- **No filler**: Each pair must add real test value.
- **Storage safety**: Do not modify existing entries in `docs/testcase-breadcrumbs.json` unless explicitly requested with `mode=replace`.
- **JSON integrity**: Output must be valid JSON with no syntax errors.

## Task

### Input Collection Mode
Collect inputs sequentially (one at a time) and do not infer missing values:
1. Ask for **Action (Test Step)** (any language accepted)
2. Ask for **Expected Result** (any language accepted)
3. Ask for **Storage Mode** (append | preview | export)
4. Optionally ask for metadata (Test Case ID, User Story ID, scenario name, or parent node context) if the user volunteers it

### Translation & Coherence Refinement
If either Action or Expected Result is not in English:
1. Translate to English using professional, concise terminology (aligned with Azure DevOps/test automation standards).
2. Report the translation to the user: `Original: <input>` → `Translated: <output>`
3. Review the translated text for coherence:
   - Check for grammatical correctness.
   - Verify use of standard terminology (not ambiguous or colloquial).
   - Ensure parallelism with existing steps (if context allows).
4. If refinements are needed for clarity, suggest them explicitly and ask for user approval before proceeding.
5. If input is already in clear English, confirm it and continue without unnecessary refinement.

### Duplicate Detection & Handling
Before validation or storage:
1. Load the current `docs/testcase-breadcrumbs.json`.
2. Extract all existing Actions from the breadcrumbs file.
3. Compare the incoming Action (after translation and refinement) against existing entries using semantic similarity (threshold: > 85% match).
4. If a near-duplicate or exact duplicate is found:
   - **Report the match**: `Found potential duplicate: "<existing_action>"` (show the matched entry)
   - **Ask for clarification**:
     - Is this the same step in a different test scenario?
     - If YES, proceed to parent node selection (see below).
     - If NO, ask the user to clarify the difference so the system can distinguish them.
   - **Parent Node Selection** (if duplicate confirmed):
     - Extract all existing parent node contexts from the breadcrumbs file (look for existing metadata or context fields).
     - If parent nodes exist, display available options:
       ```
       Available Parent Node Contexts:
       1. <parent_node_1> (e.g., "TC001 - Search scenario")
       2. <parent_node_2> (e.g., "Setup phase")
       3. <parent_node_3> (e.g., "Baseline request")
       ...
       Or provide a new parent node (type a new one)
       ```
     - Ask the user to **select an existing option by number OR type a new one**.
     - If no parent nodes exist yet, ask the user to provide a context description (e.g., "TC001 - Search scenario", "Setup phase", "Baseline request").
     - Validate the user's choice and store it as metadata.
   - **Decision**:
     - If user confirms it is a duplicate with a parent node, store both entries with the parent node metadata.
     - If user clarifies the difference, continue with the refined Action.
     - If user requests to skip this pair, do not proceed.
5. If no duplicate is found, proceed to Pre-Flight Validation.

### Pre-Flight Validation
Before any operation:
1. Validate **Action** length (after translation/refinement): reject if > 180 characters.
2. Validate **Expected Result** length (after translation/refinement): reject if > 220 characters.
3. Validate both inputs are non-empty.
4. Validate **Storage Mode** is exactly one of: `append`, `preview`, or `export`.
5. If any validation fails, stop and report the error before proceeding.

### Processing by Storage Mode

#### Mode: `append`
1. Load the current `docs/testcase-breadcrumbs.json`.
2. Validate JSON structure.
3. Append the new step-result pair to the `entries` array (create a new entry if needed).
4. If parent node metadata was provided, include it in a comment or metadata section within the entry.
5. Write the updated JSON back to the file with proper formatting and no BOM.
6. Report success with file path, confirmation of the new pair, and any parent node associations.

#### Mode: `preview`
1. Do NOT write to file.
2. Show the proposed step-result pair (after translation and refinement) in JSON format as it would be stored.
3. Show character counts for both action and expected result.
4. Provide a formatted markdown preview of the pair.
5. If parent node metadata exists, show it in the preview.

#### Mode: `export`
1. Do NOT write to file.
2. Generate a markdown table with the step-result pair formatted for Test Plans.
3. Include a PowerShell/JSON snippet ready for Azure DevOps Test Case creation.
4. Output is ready to copy and use in manual Test Case creation or as input for the `create-webservices-test-cases-from-user-story.md` prompt.
5. If parent node metadata exists, include it as a comment or reference in the export.

## Output Format

### Translation & Refinement Report (if applicable)
```
Original Input:
- Action: <original_action_in_source_language>
- Expected Result: <original_expected_result_in_source_language>

Translated to English:
- Action: <translated_action>
- Expected Result: <translated_expected_result>

Coherence Refinements Applied:
- <list refinements made for clarity, or "None - input was clear">
```

### Duplicate Detection Report (if applicable)
```
⚠ Potential Duplicate Detected

Existing Entry Found:
- Step: "<existing_action>"
- Parent Node Context: <parent_node_if_available_or_"none">

Your New Entry:
- Step: "<new_action>"

Similarity Score: <percentage>%

Available Parent Node Options:
1. <parent_node_1> (e.g., "TC001 - Search scenario")
2. <parent_node_2> (e.g., "Setup phase")
3. <parent_node_3> (e.g., "Baseline request")

Next Step:
- Select an option (1, 2, 3, ...) to assign the same parent node
- OR type a new parent node context (e.g., "Follow-up validation")
- OR clarify how your step differs from the existing one
```

### Validation Result
- Translation required: `yes | no`
- Coherence refinements: `yes | no`
- Duplicate detected: `yes | no`
- Action valid: `yes | no`
- Expected Result valid: `yes | no`
- Storage mode: `append | preview | export`
- Metadata included: `yes | no`
- Parent node provided: `yes | no`

### Append Mode Output
```json
{
  "operation": "append",
  "status": "success",
  "file_path": "docs/testcase-breadcrumbs.json",
  "entry_added": {
    "step": "<action_after_translation_and_refinement>",
    "expected_result": "<expected_result_after_translation_and_refinement>"
  },
  "metadata": {
    "parent_node": "<context_if_provided>"
  },
  "character_count": {
    "action": <count>,
    "expected_result": <count>
  }
}
```

### Preview Mode Output
```json
{
  "operation": "preview",
  "status": "ready_to_append",
  "proposed_entry": {
    "step": "<action_after_translation_and_refinement>",
    "expected_result": "<expected_result_after_translation_and_refinement>"
  },
  "metadata": {
    "parent_node": "<context_if_provided>"
  },
  "character_count": {
    "action": <count>,
    "expected_result": <count>
  },
  "markdown_preview": "| Step | Expected Result |\n|---|---|\n| <action> | <expected_result> |"
}
```

### Export Mode Output
```markdown
## Test Step-Result Pair

### Metadata
- Parent Node: <context_if_provided>

### Structured Data
| Step | Expected Result |
|---|---|
| <action_after_translation_and_refinement> | <expected_result_after_translation_and_refinement> |

### PowerShell JSON (ready for Test Case creation)
<ps1-compatible JSON snippet>

### Character Counts
- Action: <count> / 180
- Expected Result: <count> / 220
```

### Validation Checklist
- [ ] Action input received (any language)
- [ ] Expected Result input received (any language)
- [ ] Translation performed (if not in English)
- [ ] Translation accuracy verified
- [ ] Coherence refinements suggested and approved by user
- [ ] Duplicate detection performed against breadcrumbs
- [ ] If duplicate found: parent node context collected
- [ ] Action is non-empty and ≤ 180 characters (after translation/refinement)
- [ ] Expected Result is non-empty and ≤ 220 characters (after translation/refinement)
- [ ] Storage mode is valid (append | preview | export)
- [ ] JSON output is syntactically valid
- [ ] No BOM in output file (if append mode)
- [ ] File written to correct location (if append mode)
- [ ] Parent node metadata stored if applicable

## Notes
- Use this prompt iteratively to build up a library of reusable step-result pairs in `docs/testcase-breadcrumbs.json`.
- The breadcrumbs file serves as a source-of-truth for step design across multiple test cases and user stories.
- Duplicate detection helps maintain consistency and prevents redundant steps across scenarios.
- Parent node context allows the same step to exist in multiple test scenarios without losing test separation.
- Export mode is useful for generating snippets to share with team members or for importing into Excel/CSV tools.
- Translation capability allows international teams to contribute test steps in their native language while maintaining English documentation standards.
