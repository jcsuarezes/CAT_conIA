
# Populate Steps for TCs 2655098-2655101 (US 2629267 Boolean Search)
# Uses az boards work-item update --field (PAT-auth via devops extension)
$ErrorActionPreference = 'Stop'
$org = 'https://dev.azure.com/cat-digital'
$base = 'https://sis-ws-all-dev.azurewebsites.net/sis2-ws-all/services/searchresults?language=en&profileId=1'

function EscHtml([string]$s) {
    return $s -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;' -replace "'", '&apos;'
}

function BS([int]$sid, [string]$a, [string]$e) {
    return "<step id='$sid' type='ActionStep'>" +
        '<parameterizedString isformatted=''true''>' + $a + '</parameterizedString>' +
        '<parameterizedString isformatted=''true''>' + $e + '</parameterizedString>' +
        '<description/></step>'
}

function BuildXml([array]$steps) {
    $last = $steps.Count + 1
    $xml = "<steps id='0' last='$last'>"
    $sid = 2
    foreach ($s in $steps) {
        $xml += BS $sid (EscHtml $s.a) (EscHtml $s.e)
        $sid++
    }
    $xml += '</steps>'
    return $xml
}

function Update([int]$id, [array]$steps) {
    $xml = BuildXml $steps
    az boards work-item update --org $org --id $id --field "Microsoft.VSTS.TCM.Steps=$xml" --only-show-errors --output none
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK: $id"
    } else {
        Write-Host "FAIL ($LASTEXITCODE): $id"
    }
}

# TC001 - AND Exact Phrase (2655098)
$qs101 = $base + '&searchterm=%22OIL%20AND%20PUMP%22&top=50&skip=0&count=true&isMultipleProductFamilyFacets=true&allowExpandedMiningProducts=true'
Update 2655098 @(
    @{a = "Send HTTP GET to: $qs101 (uppercase AND, exact phrase quoted via %22)"; e = "HTTP 200 OK; response body is valid JSON with @odata.context and @odata.count present" }
    @{a = "Inspect @odata.count in the response body"; e = "@odata.count is greater than 0; value array contains at least one result" }
    @{a = "Review each returned result; verify results are relevant to the exact phrase 'OIL AND PUMP' with AND as boolean operator"; e = "Top results match 'OIL AND PUMP'; uppercase AND is applied as boolean AND, not treated as a literal word" }
)

# TC002 - OR Search (2655099)
$qs102 = $base + '&searchterm=OIL%20OR%20PUMP&top=50&skip=0&count=true&isMultipleProductFamilyFacets=true&allowExpandedMiningProducts=true'
Update 2655099 @(
    @{a = "Send HTTP GET to: $qs102 (uppercase OR, no phrase quoting)"; e = "HTTP 200 OK; response body is valid JSON" }
    @{a = "Inspect value array; verify it includes results containing ONLY 'OIL' and results containing ONLY 'PUMP'"; e = "@odata.count is greater than 0; OIL-only items and PUMP-only items both present confirming OR logic is applied" }
    @{a = "Compare result count to an equivalent AND search; verify OR returns an equal or higher count (more permissive)"; e = "OR count is >= AND count; OR result set is a superset of the AND results" }
)

# TC003 - NOT Search (2655100)
$qs103 = $base + '&searchterm=OIL%20NOT%20PUMP&top=50&skip=0&count=true&isMultipleProductFamilyFacets=true&allowExpandedMiningProducts=true'
Update 2655100 @(
    @{a = "Send HTTP GET to: $qs103 (uppercase NOT)"; e = "HTTP 200 OK; response body is valid JSON" }
    @{a = "Inspect value array; verify no returned result title or description contains the term 'PUMP'"; e = "All returned items contain 'OIL'; zero results include 'PUMP' in title or description" }
    @{a = "Verify @odata.count is lower than a plain OIL-only search confirming NOT exclusion reduces the result set"; e = "NOT exclusion applied; count is strictly lower than plain OIL search; PUMP items are absent" }
)

# TC004 - Default Search Behavior (2655101)
$qs104 = $base + '&searchterm=oil%20and%20pump&top=50&skip=0&count=true&isMultipleProductFamilyFacets=true&allowExpandedMiningProducts=true'
Update 2655101 @(
    @{a = "Send HTTP GET to: $qs104 (all lowercase, no quoting - 'and' is NOT a boolean operator here)"; e = "HTTP 200 OK; response body is valid JSON" }
    @{a = "Compare result count and items to TC001 (uppercase AND boolean); verify lowercase 'and' is NOT treated as boolean AND"; e = "Result count differs from TC001; lowercase 'and' triggers the default search behavior and returns more or different results" }
    @{a = "Verify exact-match items appear boosted at the top and partial-match items rank lower in the result order"; e = "Items matching the exact phrase 'oil and pump' rank highest; items matching partial terms appear below; default search behavior is observable" }
)

Write-Host "Done."
