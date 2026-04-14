#!/usr/bin/env pwsh
# Final test case creation for US 2629267

$ORG = "https://dev.azure.com/cat-digital"
$PROJECT = "Cat Digital"
$USER_STORY_ID = 2629267
$PLAN_ID = 2655035
$SUITE_ID = 2655041
$AREA = "Cat Digital\A - SIS\A - SIS Core Team 2"
$ITERATION = "Cat Digital\SIS\2026\26.05.00 (Apr 02 - Apr 22)"

$titles = @(
    "TC001 - US2629267 - Boolean AND Search",
    "TC002 - US2629267 - Exact Phrase Search",
    "TC003 - US2629267 - Boolean OR Search",
    "TC004 - US2629267 - Boolean NOT Search",
    "TC005 - US2629267 - Fallback Logic No Operators"
)

Write-Host "================================================"
Write-Host "Creating Test Cases - US 2629267"
Write-Host "================================================"
Write-Host ""

$ids = @()

foreach ($title in $titles) {
    Write-Host "Creating: $title" -ForegroundColor Yellow
    
    # Create JSON payload
    $json = @"
{
  "fields": {
    "System.Title": "$title",
    "System.WorkItemType": "Test Case",
    "System.AreaPath": "$AREA",
    "System.IterationPath": "$ITERATION"
  }
}
"@
    
    # Write to temp file
    $tmpFile = "$env:TEMP\tc_$(Get-Random).json"
    [System.IO.File]::WriteAllText($tmpFile, $json, [System.Text.UTF8Encoding]::new($false))
    
    # Create work item
    try {
        $output = az devops invoke `
            --org $ORG `
            --area wit `
            --resource workitems `
            --route-parameters project=$PROJECT `
            --http-method POST `
            --in-file $tmpFile `
            --api-version 7.1-preview `
            --output json `
            2>&1
        
        # Check if output contains error
        if ($output -like "*ERROR*" -or $output -like "*error*") {
            Write-Host "  FAILED: $output" -ForegroundColor Red
        } else {
            # Parse ID from output
            if ($output -match '"id"\s*:\s*(\d+)') {
                $id = $Matches[1]
                $ids += $id
                Write-Host "  SUCCESS - ID: $id" -ForegroundColor Green
            } else {
                Write-Host "  Could not parse ID from: $output" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "  EXCEPTION: $_" -ForegroundColor Red
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "================================================"
Write-Host "Created Test Case IDs:"
Write-Host "================================================"
foreach ($id in $ids) {
    Write-Host "  $id"
}

Write-Host ""
Write-Host "Total: $($ids.Count) test cases"
Write-Host ""
Write-Host "Next: Add steps manually in https://dev.azure.com/cat-digital/Cat%20Digital/_testplans/define?planId=$PLAN_ID&suiteId=$SUITE_ID"
