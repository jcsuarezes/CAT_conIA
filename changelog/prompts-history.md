# Prompt History

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
