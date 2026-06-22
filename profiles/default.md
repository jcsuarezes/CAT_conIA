# Default Profile Template (Non-sensitive)

This file defines default values for your Azure DevOps automation framework. 
**Customize these values for your specific environment before using any prompts.**

---

## Identity
**Configure your default user identity.**

- **Profile name**: `default` (identifier for this configuration set)
- **Username alias**: `{{ USER_EMAIL }}` 
  - Example: `john.doe@company.com`
  - This user is assigned by default to created/updated work items
  - Update to your actual Azure DevOps user email

- **Team**: `{{ TEAM_NAME }}`
  - Example: `Platform Engineering` or leave blank if not needed
  - Used for filtering or grouping work items

---

## Azure DevOps Context
**Configure your target organization and project.**

- **Organization URL**: `https://dev.azure.com/{{ ORG_NAME }}`
  - Example: `https://dev.azure.com/mycompany`
  - Replace `{{ ORG_NAME }}` with your Azure DevOps organization name
  - Get from: Azure DevOps dashboard URL

- **Default project**: `{{ PROJECT_NAME }}`
  - Example: `Engineering` or `Platform`
  - Used when prompts don't specify a project explicitly
  - Must exist in your organization

- **Preferred work item types**: `{{ WI_TYPES }}`
  - Example: `User Story, Bug, Task`
  - Used to filter or validate work item queries
  - Leave blank if no preference

- **Preferred output language**: `English`
  - Recommended: Keep as English for consistency with prompts
  - Change if your team requires a different language

---

## Response Preferences
**Configure how you want prompt outputs formatted.**

- **Style**: `concise`
  - Options: `concise`, `detailed`, `minimal`
  - Affects summary length and verbosity

- **Include summary table**: `yes`
  - Options: `yes`, `no`
  - Include structured tabular output in responses

- **Include validation checklist**: `yes`
  - Options: `yes`, `no`
  - Include pre-execution and post-execution validation steps

- **Include rollback notes for updates**: `yes`
  - Options: `yes`, `no`
  - Include instructions to revert changes if needed

---

## Prompt Defaults
**Configure default behavior for prompt execution.**

- **Retrieval mode default**: `ids`
  - Options: `ids` (by Work Item ID), `wiql` (by query), `url` (by URL)
  - Which method to use when retrieving work items by default

- **Update mode default**: `dry-run-first`
  - Options: `dry-run-first`, `direct`, `interactive`
  - Whether to validate changes before applying them

- **Table format default**: `markdown-simple`
  - Options: `markdown-simple`, `markdown-detailed`, `json`, `csv`
  - Output format for work item tables

- **Work item assigned user default**: `{{ USER_EMAIL }}`
  - Same as Identity → Username alias above
  - Default assignee for new/updated work items
  - Used when prompts don't specify an assignee explicitly

---

## Secret References (Aliases Only)
**DO NOT store real tokens or secrets in this file.**

Store actual secrets in a local file outside the repository (e.g., `~/.prompt-secrets/`).
Reference them here by alias only.

- **PAT alias**: `AZDO_PAT_MAIN`
  - References your Azure DevOps Personal Access Token
  - Location: `{{ SECRET_VAULT_PATH }}` (e.g., `~/.prompt-secrets/azdo.local.md`)
  - Scopes needed: Work Items (read/write), Test Management (if using test plans)

- **Entra token alias**: `AZDO_ENTRA_TOKEN`
  - References your Entra/AAD token (if using CLI authentication)
  - Location: `{{ SECRET_VAULT_PATH }}`
  - Optional; use if PAT is insufficient

---

## Quick Start
1. Replace all `{{ PLACEHOLDER }}` values with your actual configuration
2. Store real secrets (PAT, tokens) in a local file outside this repository
3. Reference them in prompts using the alias names defined above
4. See [security.md](../docs/security.md) for best practices

---

## Notes
- **Change frequency**: Update this file when your team, project, or organization changes
- **Sharing**: Safe to commit to repo (no secrets; only aliases and references)
- **Inheritance**: Prompts use these defaults when inputs are not explicitly provided
- **Overrides**: Individual prompts can override any default by providing explicit values in their `Inputs` section
