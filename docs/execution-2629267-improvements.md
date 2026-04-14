# Error Corrections & Prompt Improvements - Summary

## Errors Identified & Fixed

### 1️⃣ **Azure DevOps CLI PATCH Bug (Critical)**
**Error**: `az devops invoke PATCH` for `Microsoft.VSTS.TCM.Steps` fails with `KeyError: 'type'`
- **Root Cause**: Bug in azure-devops CLI extension v1.0.2 response parser
- **Impact**: Test case steps cannot be automated; field remains empty
- **Fix Applied**:
  - ✅ Documented the bug explicitly in "Known Limitations & Workarounds" section
  - ✅ Replaced automated Step 5 with 3 clear alternatives:
    - Option A: Manual UI population (recommended)
    - Option B: Invoke-RestMethod with bearer token (advanced)
    - Option C: Defer step population until CLI is fixed
  - ✅ Removed broken PowerShell code that was using `az devops invoke PATCH`

### 2️⃣ **Sprint Name Normalization**
**Error**: User provided full iteration path instead of sprint name component
- **Example**: Input `Cat Digital\SIS\2026\26.05.00 (Apr 02 - Apr 22)` → used as-is
- **Impact**: Suite naming became malformed with backslashes
- **Fix Applied**:
  - ✅ Added "Pre-Flight Input Validation" section
  - ✅ Mandatory normalization: Extract only the final component (e.g., "26.05.00 (Apr 02 - Apr 22)")
  - ✅ Stop and clarify if user provides full path

### 3️⃣ **Webservice URL Templating**
**Error**: User provided `{{url}}` placeholder without replacement
- **Impact**: Steps XML contain literal `{{url}}` instead of actual endpoint
- **Fix Applied**:
  - ✅ Added URL validation (reject template variables like `{{}}` or `${}`)
  - ✅ Prompt now stops and requests literal URL before proceeding
  - ✅ Added constraint: "Must be a complete, literal URL"

### 4️⃣ **Silent API Failures**
**Error**: Suite linkage POST returned HTTP 200 but didn't actually link test cases
- **Impact**: Test cases appeared linked but query returned 0 results
- **Root Cause**: Verification only checked exit code, not returned data
- **Fix Applied**:
  - ✅ Step 7 now includes **CRITICAL VALIDATION**: Count must equal expected (4 test cases)
  - ✅ If count ≠ expected, prompt **FAILS LOUDLY** with explicit error message
  - ✅ Added instruction: "Verify immediately after linking with GET query"

### 5️⃣ **UTF-8 Encoding with BOM**
**Error**: PowerShell `Set-Content -Encoding utf8` adds BOM → "Unexpected UTF-8 BOM" parser error
- **Root Cause**: PowerShell's utf8 encoding includes BOM by default
- **Impact**: Azure DevOps API rejects JSON patch requests
- **Fix Applied**:
  - ✅ Added PowerShell Best Practices section with exact encoding fix
  - ✅ Documented: Use `[System.IO.File]::WriteAllText($path, $json, [System.Text.UTF8Encoding]::new($false))`
  - ✅ Key: Parameter `$false` disables BOM

---

## Prompt Changes Summary

| Section | Change | Rationale |
|---------|--------|-----------|
| **Pre-Execution Validation** | Added Sprint Name & URL normalization checks | Catch input errors early before API calls |
| **Known Limitations** | NEW: Documented az devops PATCH bug with 3 workarounds | Fail fast, provide alternatives upfront |
| **Constraints** | Added URL format validation rule | Prevent template variables from reaching steps |
| **Pre-Flight Validation** | NEW: Input normalization before Step 1 | Normalize sprint name, validate URLs |
| **Step 5** | Completely rewritten; automation removed, 3 options provided | CLI bug makes automation impossible; manual/defer are only options |
| **Step 7** | Enhanced with count validation & loud failure | Catch silent failures immediately |
| **Notes** | Added PowerShell Best Practices | Prevent encoding/error handling issues in future |

---

## Files Updated

- ✅ `/prompts/azure-devops/create-webservices-test-cases-from-user-story.md` (v1.14)
- ✅ `/changelog/prompts-history.md` (added v1.14 entry)
- ✅ `/memories/session/execution-errors-2629267.md` (NEW)
- ✅ `/memories/azure-devops-cli-pitfalls.md` (NEW)

---

## Key Takeaways for Future Prompts

1. **Validate Inputs First**: Normalize and sanitize all user inputs BEFORE using in API calls
2. **Fail Fast, Fail Loud**: Check exit codes AND response data; don't rely on HTTP 200 alone
3. **Document Known Bugs**: Warn about CLI/API limitations upfront, provide workarounds
4. **Encoding Matters**: UTF-8 BOM causes silent JSON parse failures; always disable BOM
5. **Verify Results**: Query immediately after write operations to confirm success

---

## Next Execution (of this prompt)

The updated prompt will now:
- ✅ Ask for Sprint Name (with instruction to provide only iteration label, not full path)
- ✅ Ask for Webservice URL (with validation against template variables)
- ✅ Show warning upfront about Step 5 limitation → user chooses Option A/B/C
- ✅ Validate suite membership immediately after linking
- ✅ Fail with explicit error if any critical step fails

**This should prevent all 5 errors identified in this execution.**
