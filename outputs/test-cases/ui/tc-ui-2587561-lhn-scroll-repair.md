# Test Cases — UI — Bug 2587561 (SUPERSEDED — see tc-ui-2587561-lhn-scroll-v2.md)
**Title**: Fix Scroll Issue on Parts, Repair Tab Left Hand Navigation (LHN)  
**Source Work Item**: [2587561](https://dev.azure.com/cat-digital/Cat%20Digital/_workitems/edit/2587561)  
**Type**: Bug | **State**: Internal Review  
**Area Path**: Cat Digital\A - SIS\A - SIS Core Team 2  
**Iteration**: Cat Digital\SIS\2026\26.05.00 (Apr 02 - Apr 22)  
**Breadcrumb**: Home > Serial Number > Repair > Left Hand Navigation (LHN) - Repair  
**Destination Suite**: planId=2654621 / suiteId=2676990 (staticTestSuite)  
**Generated**: 2026-04-20  

---

## TC-001 — Happy Path: LHN scroll bar is immediately scrollable without expanding items

```gherkin
Feature: LHN Scroll Bar - Repair Tab

  Scenario: Verify LHN scroll bar is immediately scrollable after data loads without expanding any item
    Given open a new browser tab in a standard (non-incognito) session
    When navigate to https://sis2-dev.cat.com/
    Then verify the user can see the SIS2 application running correctly in the development environment
    When enter the machine serial number or its prefix
    Then verify a list of machines or parts is displayed so the user can select one
    When click the Repair tab
    Then verify all repair information related to the selected product and its organization is displayed
    When click the left-hand navigation (LHN)
    Then verify a pane populated with elements related to repair is visible for the user to select
    And verify the LHN scroll bar is visible and scrollable immediately without expanding any tree item
```

---

## TC-002 — Edge: LHN scroll bar remains functional after expand/collapse (regression)

```gherkin
  Scenario: Verify LHN scroll bar availability is not affected by expanding and collapsing tree items
    Given open a new browser tab in a standard session
    When navigate to https://sis2-dev.cat.com/
    Then verify the user can see the SIS2 application running correctly in the development environment
    When enter the machine serial number or its prefix
    Then verify a list of machines or parts is displayed so the user can select one
    When click the Repair tab
    Then verify all repair information related to the selected product and its organization is displayed
    When click the left-hand navigation (LHN)
    Then verify a pane populated with elements related to repair is visible for the user to select
    And verify the LHN scroll bar is visible and scrollable before any interaction
    When expand one tree item in the LHN pane
    And collapse the same tree item
    Then verify the LHN scroll bar remains visible and scrollable after the expand/collapse action
```

---

## TC-003 — Edge: LHN scroll bar is consistent across multiple browser tabs without incognito

```gherkin
  Scenario: Verify LHN scroll bar behavior is consistent in a second browser tab without incognito
    Given confirm the LHN scroll bar was already verified as functional in a first standard browser tab
    And open a second standard browser tab (non-incognito, same browser session)
    When navigate to https://sis2-dev.cat.com/
    Then verify the user can see the SIS2 application running correctly in the development environment
    When enter the machine serial number or its prefix
    Then verify a list of machines or parts is displayed so the user can select one
    When click the Repair tab
    Then verify all repair information related to the selected product and its organization is displayed
    When click the left-hand navigation (LHN)
    Then verify a pane populated with elements related to repair is visible for the user to select
    And verify the LHN scroll bar is visible and scrollable in the second tab without requiring incognito mode
```

---

## TC-004 — Boundary: LHN scroll bar is scrollable at a non-default screen resolution

```gherkin
  Scenario: Verify LHN scroll bar is scrollable when browser is at a non-default screen resolution
    Given configure the browser viewport to a non-default resolution (e.g., 1280x768)
    When navigate to https://sis2-dev.cat.com/
    Then verify the user can see the SIS2 application running correctly in the development environment
    When enter the machine serial number or its prefix
    Then verify a list of machines or parts is displayed so the user can select one
    When click the Repair tab
    Then verify all repair information related to the selected product and its organization is displayed
    When click the left-hand navigation (LHN)
    Then verify a pane populated with elements related to repair is visible for the user to select
    And verify the LHN scroll bar is visible and scrollable at the configured screen resolution
```

---

## Validation Checklist

- [x] Source Work Item 2587561 retrieved and validated (Bug, Internal Review)
- [x] All 4 breadcrumb crumsteps resolved from `docs/testcase-breadcrumbs.json`
- [x] Destination suite planId=2654621 / suiteId=2676990 validated (staticTestSuite accepted)
- [x] Test Design Type: UI
- [x] Ratio: 1 happy path + 3 edge/boundary scenarios
- [x] All 5 acceptance criteria covered across the 4 test cases
- [x] Steps follow infinitive verb convention (navigate, click, enter, verify, confirm)
- [ ] Test cases written to Azure DevOps — PENDING user confirmation

---

## Coverage Map

| Acceptance Criteria | TC-001 | TC-002 | TC-003 | TC-004 |
|---|---|---|---|---|
| Scroll visible/scrollable immediately without expansion | ✅ | ✅ | ✅ | ✅ |
| Consistent across screen resolutions | — | — | — | ✅ |
| Consistent across browser tabs/sessions (no incognito) | — | — | ✅ | — |
| Expand/collapse does not affect scroll bar | — | ✅ | — | — |
| No regression in Tab LHN navigation | — | ✅ | — | — |
