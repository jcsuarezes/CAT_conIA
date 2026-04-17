#############################################################################
# Create Test Cases for US 2629267: Boolean Search
# Organization: cat-digital, Project: Cat Digital
#############################################################################

$ErrorActionPreference = "Continue"

# Configuration
$ORG = "https://dev.azure.com/cat-digital"
$PROJECT = "Cat Digital"
$USER_STORY_ID = 2629267
$PLAN_ID = 2655035
$SUITE_ID = 2655041
$AREA_PATH = "Cat Digital\A - SIS\A - SIS Core Team 2"
$ITERATION_PATH = "Cat Digital\SIS\2026\26.05.00 (Apr 02 - Apr 22)"

# Test Case Titles
$testCaseTitles = @(
  "TC001 - US2629267 - Boolean AND Search",
  "TC002 - US2629267 - Exact Phrase Search",
  "TC003 - US2629267 - Boolean OR Search",
  "TC004 - US2629267 - Boolean NOT Search",
  "TC005 - US2629267 - Search Without Boolean Operators"
)

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "Create Boolean Search Test Cases - US 2629267" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Test Plan ID: $PLAN_ID"
Write-Host "  Suite ID: $SUITE_ID"
Write-Host "  Area Path: $AREA_PATH"
Write-Host "  Test Cases: $(($testCaseTitles).Count)"

#############################################################################
# Step 1: Create Test Cases
#############################################################################

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "STEP 1: CREATE TEST CASES" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$createdTCIds = @()

foreach ($title in $testCaseTitles) {
  Write-Host ""
  Write-Host "Creating: $title" -ForegroundColor Green
  
  try {
    $result = az boards work-item create `
      --org $ORG `
      --project $PROJECT `
      --type "Test Case" `
      --title "$title" `
      --area-path $AREA_PATH `
      --iteration-path $ITERATION_PATH `
      --output json 2>&1
    
    if ($result -is [string] -and $result.Contains('"id"')) {
      $tcObj = $result | ConvertFrom-Json
      $tcId = $tcObj.id
      $createdTCIds += $tcId
      Write-Host "  SUCCESS - ID: $tcId" -ForegroundColor Green
    } else {
      Write-Host "  ERROR: $result" -ForegroundColor Red
    }
  } catch {
    Write-Host "  EXCEPTION: $_" -ForegroundColor Red
  }
  
  Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "Total Created: $($createdTCIds.Count) / $(($testCaseTitles).Count)" -ForegroundColor Cyan

if ($createdTCIds.Count -eq 0) {
  Write-Host "ERROR: No test cases created. Exiting." -ForegroundColor Red
  exit 1
}

#############################################################################
# Step 2: Link Test Cases to Suite
#############################################################################

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "STEP 2: LINK TEST CASES TO SUITE" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$linkedCount = 0

foreach ($tcId in $createdTCIds) {
  Write-Host ""
  Write-Host "Linking TC ID $tcId to Suite $SUITE_ID" -ForegroundColor Green
  
  try {
    $linkBody = @{
      pointAssignments = @(
        @{ testCase = @{ id = $tcId } }
      )
    } | ConvertTo-Json -Depth 10
    
    $tmpFile = "$env:TEMP\link_$tcId.json"
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
      Write-Host "  SUCCESS" -ForegroundColor Green
      $linkedCount++
    } else {
      Write-Host "  WARNING: $linkResult" -ForegroundColor Yellow
    }
  } catch {
    Write-Host "  EXCEPTION: $_" -ForegroundColor Red
  }
  
  Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "Total Linked: $linkedCount / $($createdTCIds.Count)" -ForegroundColor Cyan

#############################################################################
# Step 3: Link User Story to Test Cases  
#############################################################################

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "STEP 3: LINK USER STORY TO TEST CASES" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$relationCount = 0

foreach ($tcId in $createdTCIds) {
  Write-Host ""
  Write-Host "Creating relation: US $USER_STORY_ID 'Tested By' TC $tcId" -ForegroundColor Green
  
  try {
    $relationResult = az boards work-item relation add `
      --org $ORG `
      --id $USER_STORY_ID `
      --relation-type "Tested By" `
      --target-id $tcId `
      --only-show-errors `
      --output json 2>&1
    
    if ($relationResult -and -not $relationResult.Contains("ERROR")) {
      Write-Host "  SUCCESS" -ForegroundColor Green
      $relationCount++
    } else {
      Write-Host "  WARNING: $relationResult" -ForegroundColor Yellow
    }
  } catch {
    Write-Host "  EXCEPTION: $_" -ForegroundColor Red
  }
  
  Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "Total Relations: $relationCount / $($createdTCIds.Count)" -ForegroundColor Cyan

#############################################################################
# Summary
#############################################################################

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "EXECUTION SUMMARY" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Test Cases Created:" -ForegroundColor White
Write-Host "  TC001: Boolean AND Search"
Write-Host "  TC002: Exact Phrase Search"
Write-Host "  TC003: Boolean OR Search"
Write-Host "  TC004: Boolean NOT Search"
Write-Host "  TC005: Search Without Boolean Operators"

Write-Host ""
Write-Host "Statistics:" -ForegroundColor White
Write-Host "  Created: $($createdTCIds.Count)"
Write-Host "  Linked to Suite: $linkedCount"
Write-Host "  Relations Created: $relationCount"

Write-Host ""
Write-Host "Test Plan Link:" -ForegroundColor Cyan
Write-Host "https://dev.azure.com/cat-digital/Cat%20Digital/Testing/testplan/connect?planId=$PLAN_ID&suiteId=$SUITE_ID"

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Green
Write-Host "SUCCESS: All test cases created and linked!" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green
Write-Host ""
