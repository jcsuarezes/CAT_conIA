# Manual Test Case Creation Guide - US 2629267: Boolean Search

**Date**: April 13, 2026  
**Organization**: cat-digital  
**Project**: Cat Digital  
**User Story**: 2629267 - Allow searching with booleans and exact strings  

---

## Test Plan Information

| Item | Value |
|------|-------|
| **Test Plan ID** | 2655035 |
| **Test Plan Name** | SIS - Boolean Search Test Plan |
| **Suite ID** | 2655041 |
| **Suite Name** | Boolean Search SUITE 26.05.00 |
| **Area Path** | Cat Digital\A - SIS\A - SIS Core Team 2 |
| **Iteration** | Cat Digital\SIS\2026\26.05.00 (Apr 02 - Apr 22) |

---

## Step-by-Step Manual Creation

### Open Test Plan

1. Go to: https://dev.azure.com/cat-digital/Cat%20Digital/_testplans/define?planId=2655035&suiteId=2655041
2. Login with your credentials
3. You should see the suite: **Boolean Search SUITE 26.05.00**

---

### Create Test Cases (5 cases)

#### **TC001: Boolean AND Search**

1. Click **+ New Test Case** or **Add test case**
2. Enter Title: `TC001 - US2629267 - Boolean AND Search`
3. Set:
   - Area Path: `Cat Digital\A - SIS\A - SIS Core Team 2`
   - Iteration: `26.05.00 (Apr 02 - Apr 22)`
   - Description: "Happy Path: AND operator with multiple terms"
4. **Click Steps** section
5. Add steps:
   - **Step 1 Action**: Open BRUNO or Swagger and set request URL to the webservice
   - **Step 1 Expected**: BRUNO/Swagger is open, URL is loaded correctly
   - **Step 2 Action**: Set searchterm parameter to: `OIL AND PUMP` (uppercase AND)
   - **Step 2 Expected**: API returns results containing BOTH OIL AND PUMP
   - **Step 3 Action**: Verify response uses full text search logic (searchMode=all, queryType=full)
   - **Step 3 Expected**: Parameters correctly applied
6. Save

---

#### **TC002: Exact Phrase Search**

1. Click **+ New Test Case**
2. Enter Title: `TC002 - US2629267 - Exact Phrase Search`
3. Set:
   - Area Path: `Cat Digital\A - SIS\A - SIS Core Team 2`
   - Iteration: `26.05.00 (Apr 02 - Apr 22)`
   - Description: "Happy Path: Exact phrase with double quotes"
4. **Click Steps** section
5. Add steps:
   - **Step 1 Action**: Open BRUNO or Swagger and set request URL  
   - **Step 1 Expected**: BRUNO/Swagger is open, URL ready
   - **Step 2 Action**: Set searchterm parameter to: `"OIL PUMP"` (with quotes, properly escaped in JSON)
   - **Step 2 Expected**: Double quotes correctly formatted: `\"OIL PUMP\"`
   - **Step 3 Action**: Execute and verify only exact phrase matches are returned
   - **Step 3 Expected**: Partial matches excluded; only exact phrase results shown
6. Save

---

#### **TC003: Boolean OR Search**

1. Click **+ New Test Case**
2. Enter Title: `TC003 - US2629267 - Boolean OR Search`
3. Set:
   - Area Path: `Cat Digital\A - SIS\A - SIS Core Team 2`
   - Iteration: `26.05.00 (Apr 02 - Apr 22)`
   - Description: "Happy Path: OR operator with multiple terms"
4. **Click Steps** section
5. Add steps:
   - **Step 1 Action**: Open BRUNO or Swagger and set request URL
   - **Step 1 Expected**: BRUNO/Swagger is open, URL ready
   - **Step 2 Action**: Set searchterm parameter to: `MONITORING OR ALERT` (uppercase OR)
   - **Step 2 Expected**: API receives OR operator syntax
   - **Step 3 Action**: Execute and verify results contain MONITORING or ALERT or both
   - **Step 3 Expected**: Full text search applied; results include any match
6. Save

---

#### **TC004: Boolean NOT Search**

1. Click **+ New Test Case**
2. Enter Title: `TC004 - US2629267 - Boolean NOT Search`
3. Set:
   - Area Path: `Cat Digital\A - SIS\A - SIS Core Team 2`
   - Iteration: `26.05.00 (Apr 02 - Apr 22)`
   - Description: "Happy Path: NOT operator to exclude terms"
4. **Click Steps** section
5. Add steps:
   - **Step 1 Action**: Open BRUNO or Swagger and set request URL
   - **Step 1 Expected**: BRUNO/Swagger is open, URL ready
   - **Step 2 Action**: Set searchterm parameter to: `OIL NOT PUMP` (uppercase NOT)
   - **Step 2 Expected**: API receives NOT operator syntax
   - **Step 3 Action**: Execute and verify results contain OIL but exclude PUMP
   - **Step 3 Expected**: Exclusion logic works; no PUMP results in response
6. Save

---

#### **TC005: Fallback Logic No Operators (Edge Case)**

1. Click **+ New Test Case**
2. Enter Title: `TC005 - US2629267 - Fallback Logic No Operators`
3. Set:
   - Area Path: `Cat Digital\A - SIS\A - SIS Core Team 2`
   - Iteration: `26.05.00 (Apr 02 - Apr 22)`
   - Description: "Edge Case: Search without booleans/quotes falls back to current logic"
4. **Click Steps** section
5. Add steps:
   - **Step 1 Action**: Open BRUNO or Swagger and set request URL
   - **Step 1 Expected**: BRUNO/Swagger is open, URL ready
   - **Step 2 Action**: Set searchterm parameter to: `SEARCHTERM` (plain text, NO operators, NO quotes)
   - **Step 2 Expected**: API receives plain text request
   - **Step 3 Action**: Execute and verify legacy search logic applies (exact match boosted by 30 + non-exact)
   - **Step 3 Expected**: Results include both exact and fuzzy matches per legacy behavior
6. Save

---

## After Creating All 5 Test Cases

### Link Test Cases to Suite

All 5 test cases should automatically belong to suite **2655041** if created within the suite context.

**Verify**:
1. In the Test Plan view, you should see all 5 TC### items listed under the suite
2. Each should show state: `Design` or `Ready`

### Link User Story to Test Cases

1. Navigate to User Story: https://dev.azure.com/cat-digital/Cat%20Digital/_workitems/edit/2629267
2. Click **Links** tab (bottom)
3. Click **Link work item**  
4. Relation type: `Tested By`
5. Work item: Enter each **TC ID** (e.g., TC001, TC002, etc.)
6. Repeat for all 5 test cases

---

## Validation Checklist

After completing manual steps:

- [ ] All 5 test cases created (TC001-TC005)
- [ ] All test cases have proper titles starting with `TC###`
- [ ] Each test case includes steps with actions and expected results
- [ ] Each test case in Design state
- [ ] All 5 test cases linked to suite 2655041
- [ ] User Story 2629267 shows "flask" icon (Tested By relationships)
- [ ] Test plan accessible at: https://dev.azure.com/cat-digital/Cat%20Digital/Testing/testplan/connect?planId=2655035&suiteId=2655041

---

## Test Plan Access

**Direct Link**: https://dev.azure.com/cat-digital/Cat%20Digital/Testing/testplan/connect?planId=2655035&suiteId=2655041

---

## Known Limitation

⚠️ **Azure DevOps CLI PATCH Bug**  
- The `az devops invoke --http-method PATCH` command for updating `Microsoft.VSTS.TCM.Steps` field fails with `KeyError: 'type'` in azure-devops CLI v1.0.2
- **Workaround**: Manual UI entry is required to add test steps
- **Status**: Documented as known issue in repo history

---

**Created**: 2026-04-13  
**Created by**: Automated Test Generation Script
