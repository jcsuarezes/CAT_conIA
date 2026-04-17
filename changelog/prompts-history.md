# Prompt History

## 2026-04-17 (v1.33) — OPTIONAL SPANISH INSTRUCTIONS INPUT
- **Prompt updated**: `create-webservices-test-cases-from-user-story.md`
- **Changes**:
  - Added optional input `Additional Instructions (Spanish Comments)` for free-form operational context in Spanish.
  - Added constraint rule: Spanish instructions inform test design choices but must NOT be copied into test case titles, actions, expected results, or any generated artifact (all remain 100% English).
  - Extended pre-flight validation to confirm Additional Instructions are in Spanish and intended for guidance only.
  - Updated output format to include `ADDITIONAL INSTRUCTIONS (Spanish) APPLIED: <YES|NO>` for auditable tracking.
  - Added validation checklist item to confirm Spanish comments were not copied into generated test cases.
- **Use case**: User can provide business context, design priorities, or special rules in native Spanish without requiring test case content translation or English-language brittleness.
- **Enforcement**: If Additional Instructions are provided, they remain in execution context only and do not appear in any persisted Work Item field.

## 2026-04-17 (v1.32) - STEPS FALSE-PASS PREVENTION HARDENING
- **Prompt updated**: `create-webservices-test-cases-from-user-story.md`
- **Knowledge base updated**: `docs/ai-known-failures.md`
- **Root cause addressed**:
  - Execution reported success based on marker-only checks even when Steps were not reliably renderable in Azure Test Plans.
- **Corrections applied**:
  - Added a hard structural validation gate requiring each `<step ...>` to contain exactly two `parameterizedString` nodes (Action + Expected Result) and one `<description/>`.
  - Added minimum step-count gate (`>=4`, or `>=5` for `POST`/`PUT`/`DELETE`) to prevent underspecified Test Cases.
  - Added explicit false-positive prevention rule: no `COMPLETED` status when structural step validation fails.
  - Extended output format with per-Test-Case step validation evidence for auditable execution.

## 2026-04-16 (v1.31) — PRIORITY COVERAGE + FINALIZATION HARDENING
- **Shared instructions updated**: `.github/copilot-instructions.md`, `prompts/azure-devops/_prompt-template.md`
- **Prompt updated**: `create-webservices-test-cases-from-user-story.md`
- **Knowledge base updated**: `docs/ai-known-failures.md`
- **Coverage and execution improvements**:
  - Clarified that the 3:1 happy-path guideline is flexible and that ratios such as `4:1`, `5:1`, or `6:1` are valid only when driven by distinct high-priority behaviors that add real value.
  - Added an explicit rule against filler Test Cases and required priority-based follow-up reporting when more meaningful coverage remains.
  - Standardized an explicit final status message in execution-style outputs.
  - Documented the PowerShell array-materialization pitfall that can persist empty Azure DevOps Steps XML (`last='0'`) and added guardrails to reject it.

## 2026-04-16 (v1.30) — STEPS RENDERING ROOT-CAUSE FIX
- **Operational artifacts updated**: `run_tc_flow.ps1`, `docs/ai-known-failures.md`
- **Confirmed failure mode**:
  - The execution flow wrote `Microsoft.VSTS.TCM.Steps` in a shape that persisted text but did not render `Actions` and `Expected Results` in Azure Test Plans.
  - The failing pattern used `ValidateStep`-style XML and insufficient render-compatibility verification.
- **Corrections applied**:
  - Standardized the reusable PowerShell generator to emit `ActionStep` XML with quoted attributes and `<description/>` nodes.
  - Switched the step update path to the validated `az boards work-item update --field` pattern.
  - Removed the temporary seeded-test-case shortcut from the flow.
  - Hardened suite membership verification to recursively detect linked Test Case IDs from the returned payload.
  - Aligned comments retrieval to the preview API and default comments scope used by the prompt.

## 2026-04-16 (v1.29) — SUITE RESOLUTION REUSE ENFORCEMENT
- **Governance updated**: `.github/copilot-instructions.md`, `prompts/azure-devops/_prompt-template.md`
- **Framework guardrails added**:
  - Enforced the reusable suite-resolution prompt as the source of truth for any suite discovery/reuse/creation workflow.
  - Added template-level rules to prevent future prompts from duplicating suite-resolution logic.
  - Standardized required suite-resolution handoff outputs: `Resolved Plan ID` and `Resolved Suite ID`.

## 2026-04-16 (v1.28) — WEBSERVICES SUITE RESOLUTION EXTERNALIZATION
- **Prompt updated**: `create-webservices-test-cases-from-user-story.md`
- **Catalog updated**: `catalog/index.md`
- **Refactor completed**:
  - Externalized WebServices Step 2 suite-resolution logic to the reusable prompt `resolve-or-create-requirement-based-suite.md`.
  - Replaced duplicated suite-discovery/creation instructions with a strict handoff contract (`Resolved Plan ID` and `Resolved Suite ID`).
  - Added a blocking rule so execution cannot continue when suite resolution is ambiguous or invalid.

## 2026-04-16 (v1.27) — REUSABLE SUITE RESOLUTION FLOW
- **Prompt added**: `resolve-or-create-requirement-based-suite.md`
- **Catalog updated**: `catalog/index.md`
- **Capability added**:
  - Introduced a reusable prompt-first flow to resolve or create Requirement Based Suites across different User Stories and Test Plans.
  - Added explicit input/output contract for `Resolved Plan ID` and `Resolved Suite ID`.
  - Standardized plan-wide resolution, direct `planId + suiteId` lookup fallback, and ambiguity handling.
  - Enforced executable target suite validation (not container/parent) and requirement linkage checks.

## 2026-04-16 (v1.26) — FRAMEWORK PERSISTENCE HARDENING
- **Governance updated**: `.github/copilot-instructions.md`, `README.md`, `docs/operating-model.md`
- **Persistence controls added**:
  - Established an explicit prompt-first architecture rule.
  - Added a script lifecycle policy to prevent story-specific script sprawl.
  - Defined that process logic must live in prompts/docs, with scripts treated as support or legacy.
  - Added onboarding criteria for any new automation (reusability, owner, and retirement traceability).

## 2026-04-16 (v1.25) — CONTRADICTION CLEANUP
- **Configuration updated**: `.vscode/mcp.json`, `profiles/default.md`, `docs/operating-model.md`, `catalog/index.md`
- **Prompts updated**: `generate-work-item-urls-from-id-list.md`, `ready/generate-work-item-urls-from-id-list.quickstart.md`, `get-open-work-items-table.md`, `ready/get-open-work-items-table.quickstart.md`, `create-webservices-test-cases-from-user-story.md`
- **Consistency fixes**:
  - Standardized the Azure DevOps organization URL to `https://dev.azure.com/cat-digital` in active configuration and prompt defaults.
  - Removed trailing-slash inconsistencies from the URL-generation prompt and quickstart.
  - Aligned open-items prompts so assigned-user resolution now asks first, falls back to the profile default, and stops if no value can be resolved.
  - Clarified that the WebServices test-case prompt must target a direct executable Requirement Based Suite rather than a parent/container suite.
  - Replaced the misleading `Alternate project` catalog entry with a single-project statement.

## 2026-04-16 (v1.24) — SCENARIO TAXONOMY NORMALIZATION
- **Prompt updated**: `create-webservices-test-cases-from-user-story.md`
- **Project artifacts updated**: Boolean-search scripts, generated docs, and execution summaries
- **Wording normalization**:
  - Standardized visible scenario grouping to `Core Behavior` and `Default Behavior`.
  - Renamed the residual `Fallback Logic No Operators` title to `Search Without Boolean Operators`.
  - Preserved technical uses of `validation` and `fallback` where they refer to implementation or operational behavior rather than test case naming.

## 2026-04-16 (v1.23) — TEST CASE TITLE WORDING CLEANUP
- **Prompt updated**: `create-webservices-test-cases-from-user-story.md`
- **Project artifacts updated**: `run_tc_flow.ps1`, `scripts/create-boolean-search-test-cases.ps1`, `scripts/fix-descriptions-2655098-2655101.ps1`, generated docs and outputs
- **Naming cleanup**:
  - Added an explicit rule that Test Case titles must not include generic taxonomy labels such as `Happy path`, `Edge case`, or `Negative case`.
  - Reworded existing scenario names and descriptions to use professional, behavior-specific phrasing.
  - Cleaned historical generated artifacts so the repository no longer surfaces those labels in title-like contexts.

## 2026-04-16 (v1.22) — TEST CASE RATIO CLARIFICATION
- **Prompt updated**: `create-webservices-test-cases-from-user-story.md`
- **Shared instruction updated**: `.github/copilot-instructions.md`
- **Ratio clarification**:
  - Reworded the 3:1 guidance so it is treated as a suite-level balance target, not as an exact quota.
  - Explicitly forbids padding with negative or edge/error scenarios only to force counts.
  - Clarified that the rule must never be interpreted as 3 negative test cases per happy path.

## 2026-04-16 (v1.21) — WIQL QUERY SAFETY HARDENING
- **Prompt updated**: `wiql-queries.md`
- **WIQL safety improvements**:
  - Added explicit anti-ambiguity rules so partial or multi-meaning filters must be documented or split into an alternate query.
  - Added validated WIQL examples for open-items and assignee-based queries.
  - Standardized default ordering guidance and stricter assumptions reporting.
- **Shared guidance alignment**:
  - Linked the prompt explicitly to `docs/validated-command-patterns.md` so WIQL generation follows the same repo-wide validation model used by retrieval prompts.

## 2026-04-16 (v1.20) — VALIDATED COMMAND PATTERNS + OPEN ITEMS HARDENING
- **Docs added**: `docs/validated-command-patterns.md`
- **Prompts updated**: `_prompt-template.md`, `get-open-work-items-table.md`, `get-open-work-items-by-assignee-daily.md`
- **Quickstarts updated**: `ready/get-open-work-items-table.quickstart.md`
- **Shared guidance**:
  - Added a reusable command-pattern guide for Azure DevOps reads, WIQL flows, writes, and post-write verification.
  - Linked the shared guide from the base prompt template and README.
- **Open items hardening**:
  - Added explicit validation that WIQL zero-result cases are handled as valid outcomes rather than silent failures.
  - Added count-matching validation between WIQL ID results and retrieved work item payloads before rendering output.

## 2026-04-16 (v1.19) — WEBSERVICES PROMPT SAFETY CONSOLIDATION
- **Prompt updated**: `create-webservices-test-cases-from-user-story.md`
- **Safety consolidation**:
  - Replaced the long ad hoc limitations block with a compact `Execution Safety Profile` aligned to `docs/ai-known-failures.md`.
  - Added an explicit operational safety rule so the prompt uses validated Azure DevOps CLI patterns instead of repeating known-bad retries.
  - Added retrieval guardrails for `az boards work-item show` to avoid invalid `--fields` + `--expand` combinations and false success from empty stdout.
- **Maintenance cleanup**:
  - Renamed the implementation section to `Implementation Guardrails` while preserving the verified PowerShell practices already used by this repo.

## 2026-04-16 (v1.18) — CONFIG NORMALIZATION + QUICKSTART HARDENING
- **Prompts updated**: `update-work-items.md`, `inject-table-values.md`, `wiql-queries.md`, `generate-work-item-urls-from-id-list.md`
- **Quickstarts updated**: `ready/get-work-items.quickstart.md`, `ready/update-work-items.quickstart.md`, `ready/inject-table-values.quickstart.md`, `ready/generate-work-item-urls-from-id-list.quickstart.md`
- **Configuration normalization**:
  - Standardized fixed organization URL to `https://dev.azure.com/cat-digital` across the remaining Azure DevOps prompts and quickstarts that still used the generic root URL.
  - Standardized project naming to `Cat Digital` in prompts and quickstarts that still used `cat-digital` as the project label.
- **Retrieval hardening**:
  - Propagated the validated `az boards work-item show` guidance into the get-work-items quickstart to prevent invalid `--fields` + `--expand` combinations and false positives from empty stdout.
- **Documentation**:
  - Added visible repo documentation for known AI and Azure DevOps CLI failures in `docs/ai-known-failures.md` and linked it from `README.md`.

## 2026-04-16 (v1.17) — RETRIEVAL PATTERN HARDENING
- **Prompts updated**: `_prompt-template.md`, `get-work-items.md`
- **Azure DevOps CLI retrieval guardrails**:
  - Added explicit rule to avoid combining `--fields` with `--expand` in `az boards work-item show`.
  - Standardized the preferred retrieval pattern for field reads: use `--expand fields -o json` and extract values from the `fields` object.
  - Added validation rule that empty stdout is not sufficient to claim success when the CLI exits with code `0`.
- **Configuration cleanup**:
  - Standardized fixed organization URL to `https://dev.azure.com/cat-digital` in the shared template and get-work-items prompt.
  - Standardized allowed/default project naming to `Cat Digital` in `get-work-items.md`.

## 2026-04-14 (v1.16) — STEPS RENDERING + EXECUTION HARDENING
- **Prompt updated**: `create-webservices-test-cases-from-user-story.md`
- **Step population fix**:
  - Standardized Step 5 to use `az boards work-item update --field "Microsoft.VSTS.TCM.Steps=..."`.
  - Added explicit XML guidance requiring quoted attributes (`id='0'`, `type='ActionStep'`) to ensure Azure Test Plans renders the Steps grid.
  - Added validation requirement to confirm stored Steps XML includes quoted attributes and at least one `<step ...>` element.
- **Comments resilience**:
  - Added fallback behavior when `wit/comments` fails (`COMMENTS_STATUS=UNAVAILABLE`) so execution continues with Acceptance Criteria and Description.
- **URL safety**:
  - Added pre-flight and limitation notes to avoid URL truncation when `<WEBSERVICE_URL>` contains `&` by using variables or temp files.
- **Catalog maintenance**:
  - Bumped catalog version for this prompt to `v1.16`.
  - Corrected catalog typo `Gedate Work Items` -> `Update Work Items`.

## 2026-04-13 (v1.15) — DUPLICATE SUITE INCIDENT FIX
- **Incident**: 3 identical test suites created under Test Plan 2654621 for User Story 2629267 (Sprint 145).
- **Root Cause**: Step 3 queried only direct children of the root suite (`parentSuiteId=<ROOT_SUITE_ID>`). Suites created in previous runs were not visible in this scoped query, so the guard always evaluated `$existingCount = 0` and created a new suite each time.
- **Fix in `create-webservices-test-cases-from-user-story.md`**:
  - Replaced scoped query with a **plan-wide suite listing** (no `parentSuiteId` filter).
  - Changed condition from `$existingCount -gt 1` to `$existingCount -ge 1` — ANY match triggers a **HARD STOP**.
  - Removed silent auto-reuse: user must reply `reuse <ID>` explicitly before execution continues.
  - Added **post-creation assertion** (Step 3-D): after creating a suite, re-query all plan suites and assert exactly 1 suite with that name exists. If count ≠ 1, halt.
  - Updated **Suite Uniqueness Rule** in Constraints to reflect plan-wide search requirement.
- **Files changed**: `prompts/azure-devops/create-webservices-test-cases-from-user-story.md`, `changelog/prompts-history.md`

## 2026-04-14 (v1.14) - CRITICAL FIXES & CLI BUG DOCUMENTATION
- **Major Updates to `create-webservices-test-cases-from-user-story.md`**:
  - **Steps 5-7 rewritten**: Documented known Azure DevOps CLI PATCH bug (`KeyError: 'type'` in v1.0.2) that prevents automated step population. Moved to Option A (manual UI), Option B (Invoke-RestMethod), or Option C (defer).
  - **Pre-Flight Input Validation added**: New section to normalize Sprint Name (extract from full path) and validate Webservice URL (reject template variables).
  - **Step 7 (Verify Suite Membership)** enhanced with critical validation: MUST verify that returned test case count equals expected count; fail loudly if not.
  - **Added PowerShell Best Practices section**: UTF-8 no-BOM encoding guidance, silent failure detection, error handling patterns.
  - **Updated Pre-Execution Validation**: Added URL and Sprint Name normalization checks before any API calls.
- **Lessons Learned**: Silent API failures (POST returns 200 but doesn't actually link), UTF-8 BOM encoding issues, CLI bugs are not workaroundable—must provide alternatives upfront.
- **Documentation**:  Added session memory file `/memories/session/execution-errors-2629267.md` with detailed error root causes.
  - Added persistent user memory `/memories/azure-devops-cli-pitfalls.md` with CLI antipatterns and best practices.

## 2026-04-13 (v1.13)
- Updated `create-webservices-test-cases-from-user-story.md` to explicitly prioritize sources when designing test cases: **Acceptance Criteria > Description > Discussion**.
- Added mandatory retrieval of User Story discussion/comments and conflict handling rule (Acceptance Criteria takes precedence).
- Added validation checks confirming all three sources were reviewed before generating test cases.

## 2026-04-13 (v1.12)
- Enhanced `prompts/azure-devops/_prompt-template.md` with explicit input sections by User Story type: Webservices, UI, and Data.
- Added mandatory User Story type confirmation for test case generation.
- Added template task checks to enforce Webservice URL validation and BRUNO Step 1 only when type is Webservices.

## 2026-04-13 (v1.11)
- Updated `prompts/azure-devops/_prompt-template.md` to enforce BRUNO + Webservice URL only for **Webservices** test case generation.
- Added conditional guard in template so this rule does not apply to UI or Data test cases.

## 2026-04-13 (v1.10)
- Updated `create-webservices-test-cases-from-user-story.md` to require **Webservice URL** as mandatory input before execution.
- Added rule that the first step/action/expected result in every generated test case must open **BRUNO for APIs** and set the provided endpoint URL.
- Added missing-input guard: if Webservice URL is not provided, prompt execution must stop and request it.

## 2026-04-13 (v1.9)
- Updated `create-webservices-test-cases-from-user-story.md` to create User Story links using `Tested By` from the User Story side (`--id <USER_STORY_ID> --relation-type "Tested By" --target-id <TC_ID>`), ensuring the flask indicator appears on the story card.
- Added explicit verification for relation type `Microsoft.VSTS.Common.TestedBy-Forward` on the User Story.

## 2026-04-13 (v1.8)
- Enhanced `create-webservices-test-cases-from-user-story.md` with validation step (Step 8) to verify test case creation, steps population, and Design state.
- Added relationship linking (Step 9) to associate each test case with the source user story work item using "Tests" / "Tested By" relationship types.
- Updated validation checklist to require: steps field verification, relationship confirmation, and state validation.

## 2026-04-13 (v1.7)
- Added reusable prompt `create-webservices-test-cases-from-user-story.md` for generating Azure DevOps Test Cases from Gherkin webservices user stories.
- Prompt accepts User Story ID and Test Plan ID as parameters; creates suite with TC### naming convention; includes step/expected result population in native Azure DevOps XML format.
- Introduced initial 3:1 happy-path to edge/error guidance and step/result character limits for Azure DevOps UI readability.
- Registered prompt in `catalog/index.md` (Quick Access and Core Prompts).

## 2026-04-11 (v1.6)
- Renamed the URL-generation prompt to `generate-work-item-urls-from-id-list.md` to make the function explicit (URL generation from provided Work Item ID list).
- Renamed the matching quickstart to `ready/generate-work-item-urls-from-id-list.quickstart.md` for consistency.
- Updated catalog naming and core prompt link accordingly.

## 2026-04-11 (v1.5)
- Added reusable prompt `get-open-work-items-by-assignee-daily.md` for querying open Work Items by assigned user, rendering a markdown table, and saving a daily snapshot file.
- Registered prompt in `catalog/index.md` (Quick Access and Core Prompts).

## 2026-04-11 (v1.4)
- Added prompt `get-open-work-items-table.md` to retrieve only open Work Items, render a markdown table, and save a daily snapshot file at `outputs/daily/open-work-items-<YYYY-MM-DD>.md`.
- Added quickstart `ready/get-open-work-items-table.quickstart.md` for fast execution of the same daily open-items scenario.
- Registered both entries in `catalog/index.md` (Quick Access, Core Prompts, and Quickstarts).

## 2026-02-24 (v1.3)
- Added quickstart prompt `ready/generate-work-item-urls-from-id-list.quickstart.md` for fast Work Item URL generation from a provided ID list.
- Registered the quickstart in `catalog/index.md` (Quick Access and Quickstarts table).

## 2026-02-23 (v1.2)
- Added reusable prompt `generate-work-item-urls-from-id-list.md` for generating Work Item web URLs from IDs using the configured Azure DevOps organization URL and the `Cat Digital` project.
- Registered prompt in `catalog/index.md` (Quick Access and Core Prompts).

## 2026-02-23 (v1.1)
- Standardized fixed Azure DevOps organization configuration across prompt set.
- Enforced IDs-only retrieval mode for get-work-items prompts.
- Added mandatory registration rule: new prompts must be added to `catalog/index.md`.
- Added `.github/copilot-instructions.md` to persist generation rules.
- Added `prompts/azure-devops/_prompt-template.md` with registration checklist.

## 2026-02-23
- Added initial Azure DevOps prompt library (`v1.0`).
- Added security and operating model docs.
- Established markdown-only workflow and secret-handling policy.

## Template for future entries
- Date:
- Prompt:
- Change:
- Why:
- Owner:
- Version:
