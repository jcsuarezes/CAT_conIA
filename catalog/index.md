# Prompt Catalog (Azure DevOps)

## Active Execution Scope

This repository contains a **WebServices-focused test case generation workflow** with two active prompts:

| Name | Purpose | Version |
|---|---|---|
| [Create WebServices Test Cases From User Story](../prompts/azure-devops/create-webservices-test-cases-from-user-story.md) | Generate Gherkin-style test cases from webservices user stories | v1.34 |
| [Resolve or Create Requirement Based Suite](../prompts/azure-devops/resolve-or-create-requirement-based-suite.md) | Resolve or create target Requirement Based Suite for test case placement | v1.1 |

**Note**: The second prompt is a required dependency for the first. Both must be available.

## Fixed Configuration

- Organization URL: `https://dev.azure.com/cat-digital`
- Default project: `Cat Digital`
- Execution scope: WebServices test case generation only

## Supporting Tools

| Name | Purpose | Version |
|---|---|---|
| [Populate Test Steps](../prompts/azure-devops/populate-test-steps.md) | Collect and validate test step-result pairs for storage in breadcrumbs repository | v1.0 |

## Historical Reference

Other prompts exist in the `prompts/azure-devops/` folder but are not active in the current execution scope. See [changelog/prompts-history.md](../changelog/prompts-history.md) for historical records and removal dates.
