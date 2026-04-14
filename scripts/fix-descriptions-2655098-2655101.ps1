$ErrorActionPreference = 'Stop'
$org = 'https://dev.azure.com/cat-digital'
$fullUrl = 'https://sis-ws-all-dev.azurewebsites.net/sis2-ws-all/services/searchresults?language=en&profileId=1&searchterm=%22OIL AND PUMP%22&top=50&skip=0&count=true&isMultipleProductFamilyFacets=true&allowExpandedMiningProducts=true'

$items = @(
    @{ id = 2655098; d = "Happy path. Verify uppercase AND with an exact phrase is honored and exact phrase escaping is preserved. Initial step uses the provided webservice URL: $fullUrl" }
    @{ id = 2655099; d = "Happy path. Verify uppercase OR returns records matching either term. Initial step uses the provided webservice URL: $fullUrl" }
    @{ id = 2655100; d = "Happy path. Verify uppercase NOT excludes the negated term from results. Initial step uses the provided webservice URL: $fullUrl" }
    @{ id = 2655101; d = "Edge case. Verify searches without uppercase boolean operators or quotes fall back to current logic with exact match boosted and non-exact match behavior. Initial step uses the provided webservice URL: $fullUrl" }
)

foreach ($i in $items) {
    az boards work-item update --org $org --id $i.id --field "System.Description=$($i.d)" --only-show-errors --output none
    if ($LASTEXITCODE -eq 0) {
        Write-Host "DESC OK: $($i.id)"
    } else {
        Write-Host "DESC FAIL: $($i.id)"
    }
}

Write-Host 'Done.'
