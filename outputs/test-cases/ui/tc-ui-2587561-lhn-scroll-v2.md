# Test Cases — UI — Bug 2587561
**Title**: Bug: Fix Scroll Issue on Parts, Repair Tab Left Hand Navigation (LHN)
**Source Work Item**: [2587561](https://dev.azure.com/cat-digital/Cat%20Digital/_workitems/edit/2587561)
**Type**: Bug | **State**: Internal Review
**Area Path**: Cat Digital\A - SIS\A - SIS Core Team 2
**Iteration**: Cat Digital\SIS\2026\26.05.00 (Apr 02 - Apr 22)
**Destination Suite**: planId=2654621 / suiteId=2676990 (staticTestSuite)
**Generated**: 2026-04-20

**Breadcrumbs used**:
1. `Crumbs: Home > Serial Number > Repair > Left Hand Navigation (LHN) - Repair`
2. `Crumbs: Home > Serial Number > Parts > Left Hand Navigation (LHN) - Parts`

---

## Breadcrumb Resolution

### BC1 — Repair path
| # | Crumstep | Step | Expected Result |
|---|---|---|---|
| 1 | Home | Navigate to https://sis2-dev.cat.com/. | The user can see the SIS2 application running correctly in the development environment. |
| 2 | Serial Number | Enter the machine serial number or its prefix. | A list of machines or parts is displayed so the user can select one. |
| 3 | Repair | Click the Repair tab. | All repair information related to the selected product and its organization is displayed. |
| 4 | Left Hand Navigation (LHN) - Repair | Click the left-hand navigation (LHN). | A pane populated with elements related to repair is visible for the user to select. |

### BC2 — Parts path
| # | Crumstep | Step | Expected Result |
|---|---|---|---|
| 1 | Home | Navigate to https://sis2-dev.cat.com/. | The user can see the SIS2 application running correctly in the development environment. |
| 2 | Serial Number | Enter the machine serial number or its prefix. | A list of machines or parts is displayed so the user can select one. |
| 3 | Parts | Click the Parts link. | A list of parts related to the previously selected machine is displayed. |
| 4 | Left Hand Navigation (LHN) - Parts | Click the left-hand navigation (LHN). | A pane populated with elements related to parts is visible for the user to select. |

---

## TC-001 — LHN scroll bar scrollable immediately on Repair tab without expanding items (BC1 — Happy Path)

```gherkin
Feature: LHN Scroll Bar — Repair Tab

  Scenario: Verify LHN scroll bar is immediately scrollable on Repair tab without prior item expansion
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

## TC-002 — LHN scroll bar remains functional after expand/collapse on Repair tab (BC1 — Regression)

```gherkin
  Scenario: Verify LHN scroll bar on Repair tab is not affected by expanding and collapsing tree items
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

## TC-003 — LHN scroll bar on Repair tab is consistent across browser tabs without incognito (BC1 — Edge)

```gherkin
  Scenario: Verify LHN scroll bar on Repair tab is scrollable in a second standard browser tab
    Given confirm the LHN scroll bar was verified as functional in a first standard browser tab on the Repair tab
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

## TC-004 — LHN scroll bar scrollable immediately on Parts tab without expanding items (BC2 — Happy Path)

```gherkin
Feature: LHN Scroll Bar — Parts Tab

  Scenario: Verify LHN scroll bar is immediately scrollable on Parts tab without prior item expansion
    Given open a new browser tab in a standard (non-incognito) session
    When navigate to https://sis2-dev.cat.com/
    Then verify the user can see the SIS2 application running correctly in the development environment
    When enter the machine serial number or its prefix
    Then verify a list of machines or parts is displayed so the user can select one
    When click the Parts link
    Then verify a list of parts related to the previously selected machine is displayed
    When click the left-hand navigation (LHN)
    Then verify a pane populated with elements related to parts is visible for the user to select
    And verify the LHN scroll bar is visible and scrollable immediately without expanding any tree item
```

---

## TC-005 — LHN scroll bar on Parts tab is scrollable at a non-default screen resolution (BC2 — Boundary)

```gherkin
  Scenario: Verify LHN scroll bar on Parts tab is scrollable when browser is at a non-default screen resolution
    Given configure the browser viewport to a non-default resolution (e.g., 1280x768)
    When navigate to https://sis2-dev.cat.com/
    Then verify the user can see the SIS2 application running correctly in the development environment
    When enter the machine serial number or its prefix
    Then verify a list of machines or parts is displayed so the user can select one
    When click the Parts link
    Then verify a list of parts related to the previously selected machine is displayed
    When click the left-hand navigation (LHN)
    Then verify a pane populated with elements related to parts is visible for the user to select
    And verify the LHN scroll bar is visible and scrollable at the configured screen resolution
```

---

## TC-006 — LHN scroll bar on Repair tab is scrollable at a non-default screen resolution (BC1 — Boundary)

```gherkin
  Scenario: Verify LHN scroll bar on Repair tab is scrollable when browser is at a non-default screen resolution
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

## TC-007 — LHN scroll bar on Parts tab remains functional after expand/collapse (BC2 — Regression)

```gherkin
  Scenario: Verify LHN scroll bar on Parts tab is not affected by expanding and collapsing tree items
    Given open a new browser tab in a standard session
    When navigate to https://sis2-dev.cat.com/
    Then verify the user can see the SIS2 application running correctly in the development environment
    When enter the machine serial number or its prefix
    Then verify a list of machines or parts is displayed so the user can select one
    When click the Parts link
    Then verify a list of parts related to the previously selected machine is displayed
    When click the left-hand navigation (LHN)
    Then verify a pane populated with elements related to parts is visible for the user to select
    And verify the LHN scroll bar is visible and scrollable before any interaction
    When expand one tree item in the LHN pane
    And collapse the same tree item
    Then verify the LHN scroll bar remains visible and scrollable after the expand/collapse action
```

---

## TC-008 — LHN scroll bar on Parts tab is consistent across browser tabs without incognito (BC2 — Edge)

```gherkin
  Scenario: Verify LHN scroll bar on Parts tab is scrollable in a second standard browser tab
    Given confirm the LHN scroll bar was verified as functional in a first standard browser tab on the Parts tab
    And open a second standard browser tab (non-incognito, same browser session)
    When navigate to https://sis2-dev.cat.com/
    Then verify the user can see the SIS2 application running correctly in the development environment
    When enter the machine serial number or its prefix
    Then verify a list of machines or parts is displayed so the user can select one
    When click the Parts link
    Then verify a list of parts related to the previously selected machine is displayed
    When click the left-hand navigation (LHN)
    Then verify a pane populated with elements related to parts is visible for the user to select
    And verify the LHN scroll bar is visible and scrollable in the second tab without requiring incognito mode
```

---

## Validation Checklist

- [x] Source Work Item 2587561 retrieved and validated (Bug, Internal Review)
- [x] Both breadcrumbs fully resolved from `docs/testcase-breadcrumbs.json` — all 8 crumstep lookups resolved
- [x] Destination suite planId=2654621 / suiteId=2676990 validated (staticTestSuite accepted)
- [x] Test Design Type: UI
- [x] Ratio: 2 happy paths (one per breadcrumb/tab) + 6 edge/boundary/regression (3 per breadcrumb) — all scenarios validate distinct risks
- [x] All 5 acceptance criteria covered per breadcrumb across 8 test cases
- [x] Every scenario fully iterates its breadcrumb crumsteps — no shorthand references to other TCs
- [x] Steps follow infinitive verb convention (navigate, click, enter, verify, configure)
- [ ] Test cases written to Azure DevOps — PENDING user confirmation

---

## Coverage Map

| Acceptance Criteria | TC-001 | TC-002 | TC-003 | TC-004 | TC-005 | TC-006 | TC-007 | TC-008 |
|---|---|---|---|---|---|---|---|---|
| AC1 — Scroll immediate without expansion | ✅ | — | — | ✅ | — | — | — | — |
| AC2 — Consistent across screen resolutions | — | — | — | — | ✅ | ✅ | — | — |
| AC3 — Consistent across tabs/sessions (no incognito) | — | — | ✅ | — | — | — | — | ✅ |
| AC4 — Expand/collapse does not affect scroll bar | — | ✅ | — | — | — | — | ✅ | — |
| AC5 — No regression in Repair + Parts Tab LHN | ✅ | ✅ | — | ✅ | ✅ | — | ✅ | — |
| **Breadcrumb** | BC1 | BC1 | BC1 | BC2 | BC2 | BC1 | BC2 | BC2 |
