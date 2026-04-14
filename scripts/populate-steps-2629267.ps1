$org = "https://dev.azure.com/cat-digital"
$project = "Cat Digital"
$apiVer = "7.1"

function Set-TestCaseSteps {
  param(
    [int]$WorkItemId,
    [string]$Xml
  )

  $patch = @(
    @{ op = "add"; path = "/fields/Microsoft.VSTS.TCM.Steps"; value = $Xml }
  ) | ConvertTo-Json -Depth 5

  $tmp = [System.IO.Path]::GetTempFileName() + ".json"
  Set-Content -Path $tmp -Value $patch -Encoding utf8

  az devops invoke `
    --org $org `
    --area wit `
    --resource workitems `
    --route-parameters project="$project" id=$WorkItemId `
    --query-parameters "api-version=$apiVer" `
    --http-method PATCH `
    --in-file $tmp `
    --media-type "application/json-patch+json" `
    --output json | Out-Null

  Remove-Item $tmp -Force
  Write-Host "Updated steps for TC ID $WorkItemId"
}

$xml001 = @'
<steps id="0" last="3"><step id="1" type="ActionStep"><parameterizedString isformatted="true">Open BRUNO or Swagger and set the request URL to {{url}}/sis2-ws-all/services/searchresults with the default parameters (language=en, profileId=1, top=50, skip=0, count=true).</parameterizedString><parameterizedString isformatted="true">BRUNO or Swagger is open, endpoint URL is loaded correctly, and the request is ready to execute.</parameterizedString></step><step id="2" type="ActionStep"><parameterizedString isformatted="true">Set searchterm to: monitoring AND &quot;558-3035-00 Release Notes&quot; (AND is uppercase, phrase is wrapped in double quotes).</parameterizedString><parameterizedString isformatted="true">The searchterm field shows the boolean AND with exact phrase. All other query parameters remain unchanged.</parameterizedString></step><step id="3" type="ActionStep"><parameterizedString isformatted="true">Send the GET request and inspect the HTTP response status and returned items count and titles.</parameterizedString><parameterizedString isformatted="true">Response is HTTP 200. Result set includes only documents containing both monitoring AND the exact phrase 558-3035-00 Release Notes (intersection).</parameterizedString></step></steps>
'@

$xml002 = @'
<steps id="0" last="3"><step id="1" type="ActionStep"><parameterizedString isformatted="true">Open BRUNO or Swagger and set the request URL to {{url}}/sis2-ws-all/services/searchresults with the default parameters (language=en, profileId=1, top=50, skip=0, count=true).</parameterizedString><parameterizedString isformatted="true">BRUNO or Swagger is open, endpoint URL is loaded correctly, and the request is ready to execute.</parameterizedString></step><step id="2" type="ActionStep"><parameterizedString isformatted="true">Set searchterm to: monitoring OR &quot;558-3035-00 Release Notes&quot; (OR is uppercase, phrase is wrapped in double quotes).</parameterizedString><parameterizedString isformatted="true">The searchterm field shows the boolean OR with exact phrase. All other query parameters remain unchanged.</parameterizedString></step><step id="3" type="ActionStep"><parameterizedString isformatted="true">Send the GET request and inspect the HTTP response status and returned items count and titles.</parameterizedString><parameterizedString isformatted="true">Response is HTTP 200. Result set includes all documents with monitoring OR the exact phrase 558-3035-00 Release Notes (union of both criteria).</parameterizedString></step></steps>
'@

$xml003 = @'
<steps id="0" last="3"><step id="1" type="ActionStep"><parameterizedString isformatted="true">Open BRUNO or Swagger and set the request URL to {{url}}/sis2-ws-all/services/searchresults with the default parameters (language=en, profileId=1, top=50, skip=0, count=true).</parameterizedString><parameterizedString isformatted="true">BRUNO or Swagger is open, endpoint URL is loaded correctly, and the request is ready to execute.</parameterizedString></step><step id="2" type="ActionStep"><parameterizedString isformatted="true">Set searchterm to: monitoring NOT telemetry (NOT is uppercase, both terms are plain words with no quotes).</parameterizedString><parameterizedString isformatted="true">The searchterm field shows the uppercase NOT boolean operator. All other query parameters remain unchanged.</parameterizedString></step><step id="3" type="ActionStep"><parameterizedString isformatted="true">Send the GET request and inspect the HTTP response status and returned items count and titles.</parameterizedString><parameterizedString isformatted="true">Response is HTTP 200. Result set includes documents with monitoring only. Documents also containing telemetry are excluded from the results.</parameterizedString></step></steps>
'@

$xml004 = @'
<steps id="0" last="3"><step id="1" type="ActionStep"><parameterizedString isformatted="true">Open BRUNO or Swagger and set the request URL to {{url}}/sis2-ws-all/services/searchresults with the default parameters (language=en, profileId=1, top=50, skip=0, count=true).</parameterizedString><parameterizedString isformatted="true">BRUNO or Swagger is open, endpoint URL is loaded correctly, and the request is ready to execute.</parameterizedString></step><step id="2" type="ActionStep"><parameterizedString isformatted="true">Set searchterm to: monitoring and release notes (all lowercase, no boolean intent, no double quotes).</parameterizedString><parameterizedString isformatted="true">The searchterm field shows all-lowercase text. The API detects no boolean operators (AND/OR/NOT in uppercase) in the input.</parameterizedString></step><step id="3" type="ActionStep"><parameterizedString isformatted="true">Send the GET request and inspect the HTTP response status, items returned, and their ranking order.</parameterizedString><parameterizedString isformatted="true">Response is HTTP 200. Results follow current search logic: exact match documents are ranked above non-exact matches. No boolean mode is applied.</parameterizedString></step></steps>
'@

Set-TestCaseSteps -WorkItemId 2654973 -Xml $xml001
Set-TestCaseSteps -WorkItemId 2654974 -Xml $xml002
Set-TestCaseSteps -WorkItemId 2654975 -Xml $xml003
Set-TestCaseSteps -WorkItemId 2654976 -Xml $xml004
# Populate test steps for US2629267 test cases
# TC001=2654973, TC002=2654974, TC003=2654975, TC004=2654976
# Plan=2654621, Suite=2654972

$org     = "https://dev.azure.com/cat-digital"
$project = "Cat Digital"
$apiVer  = "7.1"

# Get DevOps bearer token once
$token = az account get-access-token --resource 499b84ac-1321-427f-aa17-267ca6975798 --query accessToken --output tsv
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json-patch+json"
}

function Update-TestSteps {
    param($tcId, $stepsXml)
    $patch = ConvertTo-Json -Depth 5 -InputObject @(
        @{ op = "add"; path = "/fields/Microsoft.VSTS.TCM.Steps"; value = $stepsXml }
    )
    $url = "$script:org/$script:project/_apis/wit/workitems/$($tcId)?api-version=$script:apiVer"
    $result = Invoke-RestMethod -Method PATCH -Uri $url -Headers $script:headers -Body $patch
    $hasSteps = if ($result.fields.'Microsoft.VSTS.TCM.Steps') { "YES" } else { "NO" }
    Write-Host "TC $tcId - $($result.fields.'System.Title') | Steps: $hasSteps"
}

$xml1 = @'
<steps id="0" last="3"><step id="1" type="ActionStep"><parameterizedString isformatted="true">Open BRUNO or Swagger and set the request URL to {{url}}/sis2-ws-all/services/searchresults with the default parameters (language=en, profileId=1, top=50, skip=0, count=true).</parameterizedString><parameterizedString isformatted="true">BRUNO or Swagger is open, endpoint URL is loaded correctly, and the request is ready to execute.</parameterizedString></step><step id="2" type="ActionStep"><parameterizedString isformatted="true">Set searchterm to: monitoring AND "558-3035-00 Release Notes" (AND is uppercase, phrase is wrapped in double quotes).</parameterizedString><parameterizedString isformatted="true">The searchterm field shows the boolean AND with exact phrase. All other query parameters remain unchanged.</parameterizedString></step><step id="3" type="ActionStep"><parameterizedString isformatted="true">Send the GET request and inspect the HTTP response status and returned items count and titles.</parameterizedString><parameterizedString isformatted="true">Response is HTTP 200. Result set includes only documents containing both monitoring AND the exact phrase 558-3035-00 Release Notes (intersection).</parameterizedString></step></steps>
'@

$xml2 = @'
<steps id="0" last="3"><step id="1" type="ActionStep"><parameterizedString isformatted="true">Open BRUNO or Swagger and set the request URL to {{url}}/sis2-ws-all/services/searchresults with the default parameters (language=en, profileId=1, top=50, skip=0, count=true).</parameterizedString><parameterizedString isformatted="true">BRUNO or Swagger is open, endpoint URL is loaded correctly, and the request is ready to execute.</parameterizedString></step><step id="2" type="ActionStep"><parameterizedString isformatted="true">Set searchterm to: monitoring OR "558-3035-00 Release Notes" (OR is uppercase, phrase is wrapped in double quotes).</parameterizedString><parameterizedString isformatted="true">The searchterm field shows the boolean OR with exact phrase. All other query parameters remain unchanged.</parameterizedString></step><step id="3" type="ActionStep"><parameterizedString isformatted="true">Send the GET request and inspect the HTTP response status and returned items count and titles.</parameterizedString><parameterizedString isformatted="true">Response is HTTP 200. Result set includes all documents with monitoring OR the exact phrase 558-3035-00 Release Notes (union of both criteria).</parameterizedString></step></steps>
'@

$xml3 = @'
<steps id="0" last="3"><step id="1" type="ActionStep"><parameterizedString isformatted="true">Open BRUNO or Swagger and set the request URL to {{url}}/sis2-ws-all/services/searchresults with the default parameters (language=en, profileId=1, top=50, skip=0, count=true).</parameterizedString><parameterizedString isformatted="true">BRUNO or Swagger is open, endpoint URL is loaded correctly, and the request is ready to execute.</parameterizedString></step><step id="2" type="ActionStep"><parameterizedString isformatted="true">Set searchterm to: monitoring NOT telemetry (NOT is uppercase, both terms are plain words with no quotes).</parameterizedString><parameterizedString isformatted="true">The searchterm field shows the uppercase NOT boolean operator. All other query parameters remain unchanged.</parameterizedString></step><step id="3" type="ActionStep"><parameterizedString isformatted="true">Send the GET request and inspect the HTTP response status and returned items count and titles.</parameterizedString><parameterizedString isformatted="true">Response is HTTP 200. Result set includes documents with monitoring only. Documents also containing telemetry are excluded from the results.</parameterizedString></step></steps>
'@

$xml4 = @'
<steps id="0" last="3"><step id="1" type="ActionStep"><parameterizedString isformatted="true">Open BRUNO or Swagger and set the request URL to {{url}}/sis2-ws-all/services/searchresults with the default parameters (language=en, profileId=1, top=50, skip=0, count=true).</parameterizedString><parameterizedString isformatted="true">BRUNO or Swagger is open, endpoint URL is loaded correctly, and the request is ready to execute.</parameterizedString></step><step id="2" type="ActionStep"><parameterizedString isformatted="true">Set searchterm to: monitoring and release notes (all lowercase, no boolean intent, no double quotes).</parameterizedString><parameterizedString isformatted="true">The searchterm field shows all-lowercase text. The API detects no boolean operators (AND/OR/NOT in uppercase) in the input.</parameterizedString></step><step id="3" type="ActionStep"><parameterizedString isformatted="true">Send the GET request and inspect the HTTP response status, items returned, and their ranking order.</parameterizedString><parameterizedString isformatted="true">Response is HTTP 200. Results follow current search logic: exact match documents are ranked above non-exact matches. No boolean mode is applied.</parameterizedString></step></steps>
'@

Write-Host "=== Updating test steps for all 4 test cases ==="
Update-TestSteps -tcId 2654973 -stepsXml $xml1
Update-TestSteps -tcId 2654974 -stepsXml $xml2
Update-TestSteps -tcId 2654975 -stepsXml $xml3
Update-TestSteps -tcId 2654976 -stepsXml $xml4
Write-Host "=== Done ==="
# Populate test steps for US2629267 test cases
# TC001=2654973, TC002=2654974, TC003=2654975, TC004=2654976
# Plan=2654621, Suite=2654972

$org = "https://dev.azure.com/cat-digital"
$project = "Cat%20Digital"
$apiVer = "7.1"

function Update-TestSteps {
    param($tcId, $stepsXml)
    $patch = ConvertTo-Json -Depth 5 -InputObject @(
        @{ op = "add"; path = "/fields/Microsoft.VSTS.TCM.Steps"; value = $stepsXml }
    )
    $tmpFile = [System.IO.Path]::GetTempFileName() + ".json"
    Set-Content -Path $tmpFile -Value $patch -Encoding utf8
    $url = "$org/$project/_apis/wit/workitems/$($tcId)?api-version=$apiVer"
    $result = az rest --method patch --url $url --body "@$tmpFile" --headers "Content-Type=application/json-patch+json" 2>&1 | ConvertFrom-Json
    Remove-Item $tmpFile -Force
    $hasSteps = if ($result.fields.'Microsoft.VSTS.TCM.Steps') { "YES" } else { "NO" }
    Write-Host "TC $tcId - Title: $($result.fields.'System.Title') | Steps: $hasSteps"
}
    function Update-TestSteps {
      param($tcId, $stepsXml)
      $patch = ConvertTo-Json -Depth 5 -InputObject @(
        @{ op = "add"; path = "/fields/Microsoft.VSTS.TCM.Steps"; value = $stepsXml }
      )
      $tmpFile = [System.IO.Path]::GetTempFileName() + ".json"
      Set-Content -Path $tmpFile -Value $patch -Encoding utf8
      $url = "$org/$project/_apis/wit/workitems/$($tcId)?api-version=$apiVer"
      $result = Invoke-RestMethod -Method PATCH -Uri $url -Headers $script:headers -Body $patch
      $org = "https://dev.azure.com/cat-digital"
      $project = "Cat Digital"
      $apiVer = "7.1"

      # Get DevOps bearer token once
      $token = az account get-access-token --resource 499b84ac-1321-427f-aa17-267ca6975798 --query accessToken --output tsv
      $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type"  = "application/json-patch+json"
      }
      Remove-Item $tmpFile -Force
      # Filter only JSON lines (skip WARNING lines from az)
      $jsonLines = $rawOutput | Where-Object { $_ -notmatch '^WARNING' -and $_ -notmatch '^ERROR' }
      $result = $jsonLines | Out-String | ConvertFrom-Json
      $hasSteps = if ($result.fields.'Microsoft.VSTS.TCM.Steps') { "YES" } else { "NO" }
      Write-Host "TC $tcId - Title: $($result.fields.'System.Title') | Steps: $hasSteps"
    }

# --- TC001: AND exact phrase returns intersection ---
$xml1 = @'
<steps id="0" last="3">
  <step id="1" type="ActionStep">
    <parameterizedString isformatted="true">Open BRUNO or Swagger and set the request URL to {{url}}/sis2-ws-all/services/searchresults with the default parameters (language=en, profileId=1, top=50, skip=0, count=true).</parameterizedString>
    <parameterizedString isformatted="true">BRUNO or Swagger is open, endpoint URL is loaded correctly, and the request is ready to execute.</parameterizedString>
  </step>
  <step id="2" type="ActionStep">
    <parameterizedString isformatted="true">Set searchterm to: monitoring AND &quot;558-3035-00 Release Notes&quot; (AND is uppercase, phrase is wrapped in double quotes).</parameterizedString>
    <parameterizedString isformatted="true">The searchterm field shows the boolean AND with exact phrase. All other query parameters remain unchanged.</parameterizedString>
  </step>
  <step id="3" type="ActionStep">
    <parameterizedString isformatted="true">Send the GET request and inspect the HTTP response status and returned items count and titles.</parameterizedString>
    <parameterizedString isformatted="true">Response is HTTP 200. Result set includes only documents containing both monitoring AND the exact phrase 558-3035-00 Release Notes (intersection).</parameterizedString>
  </step>
</steps>
'@

# --- TC002: OR exact phrase returns union ---
$xml2 = @'
<steps id="0" last="3">
  <step id="1" type="ActionStep">
    <parameterizedString isformatted="true">Open BRUNO or Swagger and set the request URL to {{url}}/sis2-ws-all/services/searchresults with the default parameters (language=en, profileId=1, top=50, skip=0, count=true).</parameterizedString>
    <parameterizedString isformatted="true">BRUNO or Swagger is open, endpoint URL is loaded correctly, and the request is ready to execute.</parameterizedString>
  </step>
  <step id="2" type="ActionStep">
    <parameterizedString isformatted="true">Set searchterm to: monitoring OR &quot;558-3035-00 Release Notes&quot; (OR is uppercase, phrase is wrapped in double quotes).</parameterizedString>
    <parameterizedString isformatted="true">The searchterm field shows the boolean OR with exact phrase. All other query parameters remain unchanged.</parameterizedString>
  </step>
  <step id="3" type="ActionStep">
    <parameterizedString isformatted="true">Send the GET request and inspect the HTTP response status and returned items count and titles.</parameterizedString>
    <parameterizedString isformatted="true">Response is HTTP 200. Result set includes all documents with monitoring OR the exact phrase 558-3035-00 Release Notes (union of both criteria).</parameterizedString>
  </step>
</steps>
'@

# --- TC003: NOT excludes matching records ---
$xml3 = @'
<steps id="0" last="3">
  <step id="1" type="ActionStep">
    <parameterizedString isformatted="true">Open BRUNO or Swagger and set the request URL to {{url}}/sis2-ws-all/services/searchresults with the default parameters (language=en, profileId=1, top=50, skip=0, count=true).</parameterizedString>
    <parameterizedString isformatted="true">BRUNO or Swagger is open, endpoint URL is loaded correctly, and the request is ready to execute.</parameterizedString>
  </step>
  <step id="2" type="ActionStep">
    <parameterizedString isformatted="true">Set searchterm to: monitoring NOT telemetry (NOT is uppercase, both terms are plain words with no quotes).</parameterizedString>
    <parameterizedString isformatted="true">The searchterm field shows the uppercase NOT boolean operator. All other query parameters remain unchanged.</parameterizedString>
  </step>
  <step id="3" type="ActionStep">
    <parameterizedString isformatted="true">Send the GET request and inspect the HTTP response status and returned items count and titles.</parameterizedString>
    <parameterizedString isformatted="true">Response is HTTP 200. Result set includes documents with monitoring only. Documents also containing telemetry are excluded from the results.</parameterizedString>
  </step>
</steps>
'@

# --- TC004: lowercase boolean falls back to standard logic ---
$xml4 = @'
<steps id="0" last="3">
  <step id="1" type="ActionStep">
    <parameterizedString isformatted="true">Open BRUNO or Swagger and set the request URL to {{url}}/sis2-ws-all/services/searchresults with the default parameters (language=en, profileId=1, top=50, skip=0, count=true).</parameterizedString>
    <parameterizedString isformatted="true">BRUNO or Swagger is open, endpoint URL is loaded correctly, and the request is ready to execute.</parameterizedString>
  </step>
  <step id="2" type="ActionStep">
    <parameterizedString isformatted="true">Set searchterm to: monitoring and release notes (all lowercase, no boolean intent, no double quotes).</parameterizedString>
    <parameterizedString isformatted="true">The searchterm field shows all-lowercase text. The API detects no boolean operators (AND/OR/NOT in uppercase) in the input.</parameterizedString>
  </step>
  <step id="3" type="ActionStep">
    <parameterizedString isformatted="true">Send the GET request and inspect the HTTP response status, items returned, and their ranking order.</parameterizedString>
    <parameterizedString isformatted="true">Response is HTTP 200. Results follow current search logic: exact match documents are ranked above non-exact matches. No boolean mode is applied.</parameterizedString>
  </step>
</steps>
'@

Write-Host "=== Updating test steps for all 4 test cases ==="
Update-TestSteps -tcId 2654973 -stepsXml $xml1
Update-TestSteps -tcId 2654974 -stepsXml $xml2
Update-TestSteps -tcId 2654975 -stepsXml $xml3
Update-TestSteps -tcId 2654976 -stepsXml $xml4
Write-Host "Done."
