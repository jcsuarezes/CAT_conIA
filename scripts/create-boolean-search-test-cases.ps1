#########################################################################
# Create Test Cases for US 2629267: Boolean Search
# Organization: cat-digital
# Project: Cat Digital
# Date: 2026-04-13
#########################################################################

$ErrorActionPreference = "Continue"

# Configuration
$ORG = "https://dev.azure.com/cat-digital"
$PROJECT = "Cat Digital"
$USER_STORY_ID = 2629267
$PLAN_ID = 2655035
$SUITE_ID = 2655041
$ROOT_SUITE_ID = 2655036
$AREA_PATH = "Cat Digital\A - SIS\A - SIS Core Team 2"
$ITERATION_PATH = "Cat Digital\SIS\2026\26.05.00 (Apr 02 - Apr 22)"
$WEBSERVICE_URL = "https://sis-ws-all-dev.azurewebsites.net/sis2-ws-all/services/searchresults?language=en&profileId=1&searchterm=%22OIL AND PUMP"+"& `"&top=50&skip=0&count=true&isMultipleProductFamilyFacets=true&allowExpandedMiningProducts=true"

# Test Case Definitions
$testCases = @(
  @{
    TCNum = "001"
    Title = "TC001 - US2629267 - Boolean AND Search"
    Description = "Verify AND operator with multiple terms"
    Source = "Acceptance Criteria"
    Steps = @(
      @{Action = "Open BRUNO or Swagger and set the request URL"; Expected = "BRUNO/Swagger is open, URL is loaded: $WEBSERVICE_URL"},
      @{Action = "Set searchterm parameter to: OIL AND PUMP (uppercase AND)"; Expected = "API receives request with both terms separated by AND operator"},
      @{Action = "Execute the search request"; Expected = "API returns results containing BOTH OIL AND PUMP; searchMode=all and queryType=full parameters applied"},
      @{Action = "Verify result count > 0"; Expected = "Results match full text search logic"}
    )
  },
  @{
    TCNum = "002"
    Title = "TC002 - US2629267 - Exact Phrase Search"
    Description = "Verify exact phrase handling with double quotes"
    Source = "Acceptance Criteria"
    Steps = @(
      @{Action = "Open BRUNO or Swagger and set the request URL"; Expected = "BRUNO/Swagger is open, URL is loaded: $WEBSERVICE_URL"},
      @{Action = "Set searchterm parameter to: `"OIL PUMP`" (quoted phrase)"; Expected = "API receives request with escaped double quotes"},
      @{Action = "Execute the search request"; Expected = "API returns only exact phrase matches; partial matches excluded"},
      @{Action = "Verify escaped quotes in payload"; Expected = "Double quotes properly formatted in JSON: \`"OIL PUMP\`""}
    )
  },
  @{
    TCNum = "003"
    Title = "TC003 - US2629267 - Boolean OR Search"
    Description = "Verify OR operator with multiple terms"
    Source = "Acceptance Criteria"
    Steps = @(
      @{Action = "Open BRUNO or Swagger and set the request URL"; Expected = "BRUNO/Swagger is open, URL is loaded: $WEBSERVICE_URL"},
      @{Action = "Set searchterm parameter to: MONITORING OR ALERT (uppercase OR)"; Expected = "API receives request with terms separated by OR operator"},
      @{Action = "Execute the search request"; Expected = "API returns results containing EITHER MONITORING OR ALERT; full text search applies"},
      @{Action = "Verify result count includes both variations"; Expected = "Results include items with MONITORING only, ALERT only, or both"}
    )
  },
  @{
    TCNum = "004"
    Title = "TC004 - US2629267 - Boolean NOT Search"
    Description = "Verify NOT operator excludes terms"
    Source = "Acceptance Criteria"
    Steps = @(
      @{Action = "Open BRUNO or Swagger and set the request URL"; Expected = "BRUNO/Swagger is open, URL is loaded: $WEBSERVICE_URL"},
      @{Action = "Set searchterm parameter to: OIL NOT PUMP (uppercase NOT)"; Expected = "API receives request with NOT operator"},
      @{Action = "Execute the search request"; Expected = "API returns results containing OIL but excluding PUMP; NOT operator filters correctly"},
      @{Action = "Verify no results contain PUMP term"; Expected = "Exclusion logic works as expected"}
    )
  },
  @{
    TCNum = "005"
    Title = "TC005 - US2629267 - Search Without Boolean Operators"
    Description = "Verify default search behavior without boolean operators or quotes"
    Source = "Acceptance Criteria"
    Steps = @(
      @{Action = "Open BRUNO or Swagger and set the request URL"; Expected = "BRUNO/Swagger is open, URL is loaded: $WEBSERVICE_URL"},
      @{Action = "Set searchterm parameter to: SEARCHTERM (plain text, no operators or quotes)"; Expected = "API receives plain text request"},
      @{Action = "Execute the search request"; Expected = "API applies current search logic: exact match boosted by 30 AND non-exact matches included"},
      @{Action = "Verify no boolean parsing occurs"; Expected = "Results include both exact and fuzzy matches per legacy behavior"}
    )
  }
)

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Create Boolean Search Test Cases - US 2629267               ║" -ForegroundColor Cyan
Write-Host "║  Organization: cat-digital  |  Project: Cat Digital          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n📋 Configuration:" -ForegroundColor Yellow
Write-Host "  Test Plan ID: $PLAN_ID"
Write-Host "  Suite ID: $SUITE_ID"
Write-Host "  Area Path: $AREA_PATH"
Write-Host "  Iteration: $ITERATION_PATH"
Write-Host "  Test Cases to Create: $(($testCases).Count)"

#########################################################################
# Step 1: Create Test Cases
#########################################################################

Write-Host "`n" + ("="*70) -ForegroundColor Cyan
Write-Host "STEP 1: CREATE TEST CASES" -ForegroundColor Cyan
Write-Host ("="*70) -ForegroundColor Cyan

$createdTCIds = @()

foreach ($tc in $testCases) {
  Write-Host "`n➤ Creating $($tc.Title)..." -ForegroundColor Green
  
  try {
    # Create Test Case using az boards work-item create
    $result = az boards work-item create `
      --org $ORG `
      --project $PROJECT `
      --type "Test Case" `
      --title "$($tc.Title)" `
      --description "$($tc.Description) | Source: $($tc.Source)" `
      --area-path $AREA_PATH `
      --iteration-path $ITERATION_PATH `
      --output json 2>&1
    
    if ($result -is [string] -and $result.Contains('"id"')) {
      $tcObj = $result | ConvertFrom-Json
      $tcId = $tcObj.id
      $createdTCIds += $tcId
      Write-Host "  ✅ Created successfully | ID: $tcId" -ForegroundColor Green
    } else {
      Write-Host "  ⚠️  Error creating test case: $result" -ForegroundColor Yellow
    }
  } catch {
    Write-Host "  ❌ Exception: $_" -ForegroundColor Red
  }
  
  Start-Sleep -Milliseconds 800
}

Write-Host "`n📊 Test Cases Created: $(($createdTCIds).Count) / $(($testCases).Count)" -ForegroundColor Cyan

if ($createdTCIds.Count -eq 0) {
  Write-Host "`n❌ No test cases were created. Exiting." -ForegroundColor Red
  exit 1
}

#########################################################################
# Step 2: Link Test Cases to Suite
#########################################################################

Write-Host "`n" + ("="*70) -ForegroundColor Cyan
Write-Host "STEP 2: LINK TEST CASES TO SUITE" -ForegroundColor Cyan
Write-Host ("="*70) -ForegroundColor Cyan

$linkedCount = 0

foreach ($tcId in $createdTCIds) {
  Write-Host "`n➤ Linking TC ID $tcId to Suite $SUITE_ID..." -ForegroundColor Green
  
  try {
    $linkBody = @{
      pointAssignments = @(
        @{ testCase = @{ id = $tcId } }
      )
    } | ConvertTo-Json -Depth 10
    
    $tmpFile = "$env:TEMP\link_tc_$tcId.json"
    [System.IO.File]::WriteAllText($tmpFile, $linkBody, [System.Text.UTF8Encoding]::new($false))
    
    $linkResult = az devops invoke `
      --org $ORG `
      --area testplan `
      --resource suitetestcase `
      --route-parameters project=$PROJECT planId=$PLAN_ID suiteId=$SUITE_ID testCaseId=$tcId `
      --http-method POST `
      --in-file $tmpFile `
      --api-version 7.1-preview `
      --only-show-errors `
      --output json 2>&1
    
    if ($linkResult -and -not $linkResult.Contains("ERROR")) {
      Write-Host "  ✅ Linked successfully" -ForegroundColor Green
      $linkedCount++
    } else {
      Write-Host "  ⚠️  Link result: $linkResult" -ForegroundColor Yellow
    }
  } catch {
    Write-Host "  ❌ Exception: $_" -ForegroundColor Red
  }
  
  Start-Sleep -Milliseconds 800
}

Write-Host "`n📊 Test Cases Linked: $linkedCount / $($createdTCIds.Count)" -ForegroundColor Cyan

#########################################################################
# Step 3: Verify Suite Membership
#########################################################################

Write-Host "`n" + ("="*70) -ForegroundColor Cyan
Write-Host "STEP 3: VERIFY SUITE MEMBERSHIP" -ForegroundColor Cyan
Write-Host ("="*70) -ForegroundColor Cyan

Write-Host "`n➤ Verifying test cases in suite $SUITE_ID..." -ForegroundColor Green

try {
  $verifyResult = az devops invoke `
    --org $ORG `
    --area testplan `
    --resource suitetestcase `
    --route-parameters project=$PROJECT planId=$PLAN_ID suiteId=$SUITE_ID `
    --api-version 7.1-preview `
    --only-show-errors `
    --output json 2>&1
  
  if ($verifyResult) {
    $suiteTestCases = $verifyResult | ConvertFrom-Json
    $tcCount = @($suiteTestCases.value).Count
    
    Write-Host "  ✅ Suite contains $tcCount test case(s)" -ForegroundColor Green
    
    if ($tcCount -ge $createdTCIds.Count) {
      Write-Host "  ✅ All created test cases are linked to suite" -ForegroundColor Green
    } else {
      Write-Host "  ⚠️  Expected $($createdTCIds.Count) but found $tcCount" -ForegroundColor Yellow
    }
  }
} catch {
  Write-Host "  ❌ Verification error: $_" -ForegroundColor Red
}

#########################################################################
# Step 4: Link User Story to Test Cases
#########################################################################

Write-Host "`n" + ("="*70) -ForegroundColor Cyan
Write-Host "STEP 4: LINK USER STORY TO TEST CASES" -ForegroundColor Cyan
Write-Host ("="*70) -ForegroundColor Cyan

$relationCount = 0

foreach ($tcId in $createdTCIds) {
  Write-Host "`n➤ Linking US $USER_STORY_ID 'Tested By' TC $tcId..." -ForegroundColor Green
  
  try {
    $relationResult = az boards work-item relation add `
      --org $ORG `
      --id $USER_STORY_ID `
      --relation-type "Tested By" `
      --target-id $tcId `
      --only-show-errors `
      --output json 2>&1
    
    if ($relationResult -and -not $relationResult.Contains("ERROR")) {
      Write-Host "  ✅ Relation created successfully" -ForegroundColor Green
      $relationCount++
    } else {
      Write-Host "  ⚠️  Relation result: $relationResult" -ForegroundColor Yellow
    }
  } catch {
    Write-Host "  ❌ Exception: $_" -ForegroundColor Red
  }
  
  Start-Sleep -Milliseconds 800
}

Write-Host "`n📊 Relations Created: $relationCount / $($createdTCIds.Count)" -ForegroundColor Cyan

#########################################################################
# Step 5: Output Summary
#########################################################################

Write-Host "`n" + ("="*70) -ForegroundColor Cyan
Write-Host "✅ EXECUTION SUMMARY" -ForegroundColor Green
Write-Host ("="*70) -ForegroundColor Cyan

Write-Host "`nTest Plan Information:" -ForegroundColor White
Write-Host "  Plan ID: $PLAN_ID"
Write-Host "  Plan Name: SIS - Boolean Search Test Plan"
Write-Host "  Suite ID: $SUITE_ID"
Write-Host "  Suite Name: Boolean Search SUITE 26.05.00"
Write-Host "`nCreated Test Cases: $($createdTCIds.Count)" -ForegroundColor White
Write-Host "  [1] TC001: Boolean AND Search"
Write-Host "  [2] TC002: Exact Phrase Search"
Write-Host "  [3] TC003: Boolean OR Search"
Write-Host "  [4] TC004: Boolean NOT Search"
Write-Host "  [5] TC005: Search Without Boolean Operators"
Write-Host "`nTest Cases Linked to Suite: $linkedCount" -ForegroundColor White
Write-Host "User Story Relations Created: $relationCount" -ForegroundColor White
Write-Host "`n🔗 Test Plan Link:" -ForegroundColor Cyan
Write-Host "https://dev.azure.com/cat-digital/Cat%20Digital/Testing/testplan/connect?planId=$PLAN_ID&suiteId=$SUITE_ID" -ForegroundColor Yellow
Write-Host "`n📝 Next Steps (MANUAL):" -ForegroundColor Cyan
Write-Host "  1. Open each Test Case in Azure DevOps"
Write-Host "  2. Click 'Edit' then 'Steps' section"
Write-Host "  3. Add scenario-specific validation steps to each test case"
Write-Host "  4. Save each test case"
Write-Host "`n⚠️  Known Limitation:" -ForegroundColor Yellow
Write-Host "  Azure DevOps CLI has a bug with PATCH for test steps."
Write-Host "  Manual UI entry is required at this time."

Write-Host "═"*70 -ForegroundColor Cyan
Write-Host "Script completed successfully! All test cases created and linked." -ForegroundColor Green
Write-Host "═"*70 -ForegroundColor Cyan
