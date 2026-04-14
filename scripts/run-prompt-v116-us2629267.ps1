$ErrorActionPreference = 'Stop'
$org = 'https://dev.azure.com/cat-digital'
$project = 'Cat Digital'
$userStoryId = 2629267
$suiteId = 2655077
$webUrl = 'https://sis-ws-all-dev.azurewebsites.net/sis2-ws-all/services/searchresults?language=en&profileId=1&searchterm=%22OIL AND PUMP%22&top=50&skip=0&count=true&isMultipleProductFamilyFacets=true&allowExpandedMiningProducts=true'

Write-Host '1) Validate User Story'
$us = az boards work-item show --org $org --id $userStoryId --expand fields --only-show-errors --output json | ConvertFrom-Json
Write-Host ("US OK: {0} | Title: {1}" -f $us.id, $us.fields.'System.Title')

Write-Host '2) Resolve suite by direct planId+suiteId scan'
$plans = az devops invoke --org $org --area testplan --resource plans --route-parameters project=$project --api-version 7.1-preview --only-show-errors --output json | ConvertFrom-Json
$match = $null
foreach ($p in $plans.value) {
    try {
        $s = az devops invoke --org $org --area testplan --resource suites --route-parameters project=$project planId=$($p.id) suiteId=$suiteId --api-version 7.1-preview --only-show-errors --output json | ConvertFrom-Json
        if ($s.id -eq $suiteId) {
            $match = [PSCustomObject]@{ planId = $p.id; planName = $p.name; suite = $s }
            break
        }
    }
    catch {
        # Keep scanning plans.
    }
}
if (-not $match) { throw 'Suite not found by direct lookup.' }
Write-Host ("Suite OK: planId={0} suiteId={1} suiteType={2} requirementId={3}" -f $match.planId, $match.suite.id, $match.suite.suiteType, $match.suite.requirementId)

Write-Host '3) Try comments retrieval with fallback behavior'
$commentsStatus = 'OK'
try {
    $null = az devops invoke --org $org --area wit --resource comments --route-parameters project=$project workItemId=$userStoryId --query-parameters '$top=20' --api-version 7.1-preview.4 --only-show-errors --output json | ConvertFrom-Json
}
catch {
    $commentsStatus = 'UNAVAILABLE'
}
Write-Host ("COMMENTS_STATUS={0}" -f $commentsStatus)

Write-Host '4) Duplicate guard by expected TC titles'
$expectedTitles = @(
    'TC001 - US2629267 - Boolean Search - AND Exact Phrase',
    'TC002 - US2629267 - Boolean Search - OR Search',
    'TC003 - US2629267 - Boolean Search - NOT Search',
    'TC004 - US2629267 - Boolean Search - Fallback Logic'
)
$existing = @()
foreach ($t in $expectedTitles) {
    $wiql = "Select [System.Id] From WorkItems Where [System.TeamProject] = 'Cat Digital' And [System.WorkItemType] = 'Test Case' And [System.Title] = '$t'"
    $qr = az boards query --org $org --wiql $wiql --only-show-errors --output json | ConvertFrom-Json
    foreach ($w in $qr.workItems) { $existing += [int]$w.id }
}
$existing = $existing | Sort-Object -Unique
Write-Host ("Existing expected TCs: {0}" -f (($existing -join ', ')))

Write-Host '5) Validate membership and steps for existing TCs'
$suiteCases = az devops invoke --org $org --area testplan --resource suitetestcase --route-parameters project=$project planId=$($match.planId) suiteId=$suiteId --api-version 7.1-preview --only-show-errors --output json | ConvertFrom-Json
$suiteIds = @($suiteCases.value.workItem.id)
foreach ($id in $existing) {
    $wi = az boards work-item show --org $org --id $id --expand fields --only-show-errors --output json | ConvertFrom-Json
    $steps = $wi.fields.'Microsoft.VSTS.TCM.Steps'
    $stepCount = ([regex]::Matches($steps, '<step ')).Count
    $inSuite = $suiteIds -contains $id
    Write-Host ("TC {0}: inSuite={1} steps={2}" -f $id, $inSuite, $stepCount)
}

Write-Host 'DONE'
