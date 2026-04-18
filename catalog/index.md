# Prompt Catalog (Azure DevOps)

## Active Execution Scope

This repository contains a **primary WebServices-focused workflow** plus additional reusable Azure DevOps prompts for UI breadcrumb-driven test design.

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
| [Create UI Test Cases From Work Item And Breadcrumbs](../prompts/azure-devops/create-ui-test-cases-from-work-item-and-breadcrumbs.md) | Generate UI test cases from a Work Item plus one or more reusable breadcrumbs and inject them into Azure DevOps | v2.0 |

## Historical Reference

Other prompts exist in the `prompts/azure-devops/` folder but are not active in the current execution scope. See [changelog/prompts-history.md](../changelog/prompts-history.md) for historical records and removal dates.
