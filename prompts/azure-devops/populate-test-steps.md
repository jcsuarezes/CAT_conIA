# Prompt: Populate Test Steps and Expected Results

## Context
You are collecting and validating test step-result pairs for Azure DevOps Test Cases. Each pair consists of a clear action and an observable expected result. Store valid pairs in a structured JSON repository for reuse and import into Test Plans.

Fixed configuration:
- Organization: `Cat Digital`
- Storage format: JSON (step-result pairs only)
- Storage location: `docs/testcase-breadcrumbs.json`
- Language: English only

## Inputs
- **Action (Test Step)**: A clear, concise action to be performed. Required.
- **Expected Result**: An observable, testable outcome of the action. Required.
- **Storage Mode**: `append` (add to breadcrumbs), `preview` (show JSON structure only, no save), or `export` (output formatted markdown).
- **Optional Metadata**: Test Case ID, User Story ID, or scenario name for organizational reference (not saved in breadcrumbs; used for output documentation only).

## Constraints
- **Action length**: Maximum 180 characters.
- **Expected Result length**: Maximum 220 characters.
- **Language**: English only. No translations, no template variables.
- **Observable outcomes**: Expected results must be verifiable and specific, not vague assertions.
- **No filler**: Each pair must add real test value; duplicate pairs are rejected.
- **Storage safety**: Do not modify existing entries in `docs/testcase-breadcrumbs.json` unless explicitly requested with `mode=replace`.
- **JSON integrity**: Output must be valid JSON with no syntax errors.

## Task

### Input Collection Mode
Collect inputs sequentially (one at a time) and do not infer missing values:
1. Ask for **Action (Test Step)**
2. Ask for **Expected Result**
3. Ask for **Storage Mode** (append | preview | export)
4. Optionally ask for metadata (Test Case ID, User Story ID, or scenario name) if the user volunteers it

### Pre-Flight Validation
Before any operation:
1. Validate **Action** length: reject if > 180 characters.
2. Validate **Expected Result** length: reject if > 220 characters.
3. Validate both inputs are non-empty and in English (no template variables, no placeholders).
4. Validate **Storage Mode** is exactly one of: `append`, `preview`, or `export`.
5. If any validation fails, stop and report the error before proceeding.

### Processing by Storage Mode

#### Mode: `append`
1. Load the current `docs/testcase-breadcrumbs.json`.
2. Validate JSON structure.
3. Append the new step-result pair to the `entries` array (create a new entry if needed).
4. Write the updated JSON back to the file with proper formatting and no BOM.
5. Report success with file path and confirmation of the new pair.

#### Mode: `preview`
1. Do NOT write to file.
2. Show the proposed step-result pair in JSON format as it would be stored.
3. Show character counts for both action and expected result.
4. Provide a formatted markdown preview of the pair.

#### Mode: `export`
1. Do NOT write to file.
2. Generate a markdown table with the step-result pair formatted for Test Plans.
3. Include a PowerShell/JSON snippet ready for Azure DevOps Test Case creation.
4. Output is ready to copy and use in manual Test Case creation or as input for the `create-webservices-test-cases-from-user-story.md` prompt.

## Output Format

### Validation Result
- Action valid: `yes | no`
- Expected Result valid: `yes | no`
- Storage mode: `append | preview | export`
- Metadata included: `yes | no`

### Append Mode Output
```json
{
  "operation": "append",
  "status": "success",
  "file_path": "docs/testcase-breadcrumbs.json",
  "entry_added": {
    "step": "<action>",
    "expected_result": "<expected_result>"
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
    "step": "<action>",
    "expected_result": "<expected_result>"
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

### Structured Data
| Step | Expected Result |
|---|---|
| <action> | <expected_result> |

### PowerShell JSON (ready for Test Case creation)
<ps1-compatible JSON snippet>

### Character Counts
- Action: <count> / 180
- Expected Result: <count> / 220
```

### Validation Checklist
- [ ] Action is non-empty and ≤ 180 characters
- [ ] Expected Result is non-empty and ≤ 220 characters
- [ ] Both inputs are in English
- [ ] No template variables or placeholders
- [ ] Storage mode is valid (append | preview | export)
- [ ] JSON output is syntactically valid
- [ ] No BOM in output file (if append mode)
- [ ] File written to correct location (if append mode)

## Notes
- Use this prompt iteratively to build up a library of reusable step-result pairs in `docs/testcase-breadcrumbs.json`.
- The breadcrumbs file serves as a source-of-truth for step design across multiple test cases and user stories.
- Export mode is useful for generating snippets to share with team members or for importing into Excel/CSV tools.
