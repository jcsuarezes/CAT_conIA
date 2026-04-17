# Prompt History

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
- Enforces 3:1 test case ratio (happy path:edge cases) and step/result character limits for Azure DevOps UI readability.
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
- Added reusable prompt `generate-work-item-urls-from-id-list.md` for generating Work Item web URLs from IDs using `https://dev.azure.com/cat-digital/` and project `cat-digital`.
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
