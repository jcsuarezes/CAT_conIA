# Prompt Catalog (Azure DevOps)

## Quick Access
- Get Work Items
- Get Open Work Items (Daily Table)
- Get Open Work Items By Assignee (Daily)
- Resolve or Create Requirement Based Suite
- Create WebServices Test Cases From User Story
- Update Work Items
- Inject Table Values
- WIQL Queries
- Generate Work Item URLs From ID List
- Get Items QS
- Get Open Items Daily QS
- Update Items QS
- Inject Table QS
- Generate URLs From ID List QS

## Fixed Configuration
- Organization URL: `https://dev.azure.com/cat-digital`
- Default project: `Cat Digital`
- Single allowed project: `Cat Digital`
- Get mode default: `IDs-only`

## Registration Rule
1. Add new prompt to this index.
2. Add entry in Prompt History.
3. No secrets in markdown files.

---

<details>
<summary>Catalog Details (internal)</summary>

## Core Prompts

| Name | Purpose | Inputs | Output | Status | Version |
|---|---|---|---|---|---|
| [Get Work Items](../prompts/azure-devops/get-work-items.md) | Retrieve work items by IDs | project, ids, fields | Summary table | Active | v1.17 |
| [Get Open Work Items (Daily Table)](../prompts/azure-devops/get-open-work-items-table.md) | Retrieve open items (New, Active, In Progress) with markdown table and daily snapshot | project, assignedTo | Markdown table + daily markdown file | Active | v1.1 |
| [Get Open Work Items By Assignee (Daily)](../prompts/azure-devops/get-open-work-items-by-assignee-daily.md) | Retrieve open Work Items for a specific assignee and save a dated markdown snapshot | project, assignedTo | Markdown table + daily markdown file | Active | v1.1 |
| [Resolve or Create Requirement Based Suite](../prompts/azure-devops/resolve-or-create-requirement-based-suite.md) | Resolve target Requirement Based Suite by suite ID across plans, or reuse/create suite by User Story + Test Plan | user story ID, suite ID optional, test plan ID conditional | Resolved plan/suite contract output | Active | v1.0 |
| [Create WebServices Test Cases From User Story](../prompts/azure-devops/create-webservices-test-cases-from-user-story.md) | Generate test cases from webservices user story; reuse provided requirement-based suite or create one under a provided test plan | user story ID, requirement based suite ID optional, test plan ID conditional, webservice URL, optional Spanish instructions | Requirement Based Suite ID, TC###-prefixed test case IDs | Active | v1.33 |
| [Update Work Items](../prompts/azure-devops/update-work-items.md) | Update work item fields safely | project, ids, patch intent | Change log by item | Active | v1.2 |
| [Inject Table Values](../prompts/azure-devops/inject-table-values.md) | Insert markdown tables/checklists | project, ids, target field, rows | Insert-ready markdown block | Active | v1.2 |
| [WIQL Queries](../prompts/azure-devops/wiql-queries.md) | Build WIQL filters | project, area, iteration, states, owners | WIQL + assumptions | Active | v1.21 |
| [Generate Work Item URLs From ID List](../prompts/azure-devops/generate-work-item-urls-from-id-list.md) | Generate Work Item web URLs from a provided ID list and include title per ID | project, ids source | Plain text URL report | Active | v1.1 |

## Quickstarts

| Name | Purpose | Status | Version |
|---|---|---|---|
| [Get Work Items Quickstart](../prompts/azure-devops/ready/get-work-items.quickstart.md) | Fast retrieval by IDs | Active | v1.1 |
| [Get Open Work Items (Daily Table) Quickstart](../prompts/azure-devops/ready/get-open-work-items-table.quickstart.md) | Fast retrieval of open Work Items with daily markdown snapshot | Active | v1.1 |
| [Update Work Items Quickstart](../prompts/azure-devops/ready/update-work-items.quickstart.md) | Safe dry-run updates | Active | v1.1 |
| [Inject Table Values Quickstart](../prompts/azure-devops/ready/inject-table-values.quickstart.md) | Fast table injection | Active | v1.1 |
| [Generate Work Item URLs From ID List Quickstart](../prompts/azure-devops/ready/generate-work-item-urls-from-id-list.quickstart.md) | Fast URL generation from a provided ID list for the configured organization | Active | v1.1 |

</details>
