# rewrite-steps-json-format.ps1
# Rewrites test case steps with JSON body displayed as formatted HTML block.
# isformatted='true' enables HTML rendering in Azure Test Plans.
# &quot; renders as " | &lt;pre&gt; renders as <pre> block

$org = "https://dev.azure.com/cat-digital"

# ── Shared step 1 variants ───────────────────────────────────────────────────
$s1Action     = "Open BRUNO or Swagger. Set URL: https://sis-ws-admin-dev.cat.com/sis-ws-admin/services/users/ | Method: POST | Accept: application/addupdateuser-v1+json | Authorization: Bearer Token Dealer"
$s1Expected   = "BRUNO or Swagger is open. URL set, method POST selected, Accept and Authorization headers configured. Request is ready to execute."

$s1NoAuthAct  = "Open BRUNO or Swagger. Set URL: https://sis-ws-admin-dev.cat.com/sis-ws-admin/services/users/ | Method: POST | Accept: application/addupdateuser-v1+json | Leave the Authorization header empty or remove it."
$s1NoAuthExp  = "BRUNO or Swagger is open. URL set, method POST selected, Accept header configured. Authorization header is absent or empty."

# ── JSON payloads (double-quotes HTML-encoded for safe XML embedding) ─────────
$bodyFull = "{&quot;userTypeCode&quot;:&quot;005&quot;,&quot;cws&quot;:&quot;td04xx3&quot;,&quot;recId&quot;:&quot;PSP-00055274&quot;,&quot;name&quot;:&quot;td00nv&quot;,&quot;affiliationOrgCode&quot;:&quot;TD03&quot;,&quot;organization&quot;:&quot;CATERPILLAR DEMO DEALER TD00&quot;,&quot;dealerCode&quot;:&quot;TD00&quot;,&quot;accessTypeIds&quot;:[1],&quot;isTechnicalCommunicator&quot;:false,&quot;isActive&quot;:true,&quot;isAdmin&quot;:true,&quot;reasonId&quot;:1,&quot;note&quot;:&quot;toggle test&quot;}"

$bodyNoCws  = "{&quot;userTypeCode&quot;:&quot;005&quot;,&quot;recId&quot;:&quot;PSP-00055274&quot;,&quot;name&quot;:&quot;td00nv&quot;,&quot;affiliationOrgCode&quot;:&quot;TD03&quot;,&quot;organization&quot;:&quot;CATERPILLAR DEMO DEALER TD00&quot;,&quot;dealerCode&quot;:&quot;TD00&quot;,&quot;accessTypeIds&quot;:[1],&quot;isActive&quot;:true,&quot;isAdmin&quot;:true,&quot;reasonId&quot;:1,&quot;note&quot;:&quot;toggle test&quot;}"

$bodyDupId  = "{&quot;userTypeCode&quot;:&quot;005&quot;,&quot;cws&quot;:&quot;td04xx4&quot;,&quot;recId&quot;:&quot;PSP-00055274&quot;,&quot;name&quot;:&quot;td00nv2&quot;,&quot;affiliationOrgCode&quot;:&quot;TD03&quot;,&quot;organization&quot;:&quot;CATERPILLAR DEMO DEALER TD00&quot;,&quot;dealerCode&quot;:&quot;TD00&quot;,&quot;accessTypeIds&quot;:[1],&quot;isActive&quot;:true,&quot;isAdmin&quot;:true,&quot;reasonId&quot;:1,&quot;note&quot;:&quot;duplicate recId test&quot;}"

$bodyNoAuth = "{&quot;userTypeCode&quot;:&quot;005&quot;,&quot;cws&quot;:&quot;td04xx3&quot;,&quot;recId&quot;:&quot;PSP-99999999&quot;,&quot;name&quot;:&quot;td00nv&quot;,&quot;affiliationOrgCode&quot;:&quot;TD03&quot;,&quot;organization&quot;:&quot;CATERPILLAR DEMO DEALER TD00&quot;,&quot;dealerCode&quot;:&quot;TD00&quot;,&quot;accessTypeIds&quot;:[1],&quot;isActive&quot;:true,&quot;isAdmin&quot;:true,&quot;reasonId&quot;:1,&quot;note&quot;:&quot;auth test&quot;}"

# Helper: wrap JSON in a <pre> HTML block for Test Plans rendering
function Body-Step($label, $json) {
    return "$label&lt;br/&gt;&lt;pre&gt;$json&lt;/pre&gt;"
}

# ── TC001 (2682889) — Happy Path: Create user successfully ────────────────────
$xml1 = "<steps id='0' last='4'>" +
  "<step id='2' type='ActionStep'>" +
    "<parameterizedString isformatted='true'>$s1Action</parameterizedString>" +
    "<parameterizedString isformatted='true'>$s1Expected</parameterizedString>" +
  "</step>" +
  "<step id='3' type='ActionStep'>" +
    "<parameterizedString isformatted='true'>$(Body-Step 'In the request body editor, paste this JSON payload:' $bodyFull)</parameterizedString>" +
    "<parameterizedString isformatted='true'>Request body editor shows all required fields: userTypeCode, cws, recId, name, affiliationOrgCode, organization, dealerCode, accessTypeIds, isTechnicalCommunicator, isActive, isAdmin, reasonId, note.</parameterizedString>" +
  "</step>" +
  "<step id='4' type='ActionStep'>" +
    "<parameterizedString isformatted='true'>Click Send to execute the POST request.</parameterizedString>" +
    "<parameterizedString isformatted='true'>Response HTTP status is 200 or 201. Response body contains the field user: created confirming successful user creation. Expected response body:&lt;br/&gt;&lt;pre&gt;{&lt;br/&gt;&amp;nbsp;&amp;nbsp;&quot;infoMessage&quot;: &quot;User td04xx3 updated successfully&quot;&lt;br/&gt;}&lt;/pre&gt;</parameterizedString>" +
  "</step>" +
"</steps>"

# ── TC002 (2682890) — Missing required field: cws ────────────────────────────
$xml2 = "<steps id='0' last='4'>" +
  "<step id='2' type='ActionStep'>" +
    "<parameterizedString isformatted='true'>$s1Action</parameterizedString>" +
    "<parameterizedString isformatted='true'>$s1Expected</parameterizedString>" +
  "</step>" +
  "<step id='3' type='ActionStep'>" +
    "<parameterizedString isformatted='true'>$(Body-Step 'In the request body editor, paste this JSON payload — cws field intentionally omitted:' $bodyNoCws)</parameterizedString>" +
    "<parameterizedString isformatted='true'>Request body editor shows the JSON payload without the cws field. All other fields are present.</parameterizedString>" +
  "</step>" +
  "<step id='4' type='ActionStep'>" +
    "<parameterizedString isformatted='true'>Click Send to execute the POST request.</parameterizedString>" +
    "<parameterizedString isformatted='true'>Response HTTP status is 400 or 422. Response body contains an error message indicating cws is required. No user is created.</parameterizedString>" +
  "</step>" +
"</steps>"

# ── TC003 (2682891) — Duplicate recId ────────────────────────────────────────
$xml3 = "<steps id='0' last='4'>" +
  "<step id='2' type='ActionStep'>" +
    "<parameterizedString isformatted='true'>&lt;b&gt;Prerequisite:&lt;/b&gt; A user with recId PSP-00055274 already exists (created in TC001). $s1Action</parameterizedString>" +
    "<parameterizedString isformatted='true'>$s1Expected User with recId PSP-00055274 is confirmed to exist in the system.</parameterizedString>" +
  "</step>" +
  "<step id='3' type='ActionStep'>" +
    "<parameterizedString isformatted='true'>$(Body-Step 'In the request body editor, paste this JSON payload reusing the same recId PSP-00055274:' $bodyDupId)</parameterizedString>" +
    "<parameterizedString isformatted='true'>Request body editor shows the JSON payload with duplicate recId value PSP-00055274.</parameterizedString>" +
  "</step>" +
  "<step id='4' type='ActionStep'>" +
    "<parameterizedString isformatted='true'>Click Send to execute the POST request.</parameterizedString>" +
    "<parameterizedString isformatted='true'>Response HTTP status is 409 or 400. Response body contains a conflict or duplicate error message for recId PSP-00055274. No new user is created.</parameterizedString>" +
  "</step>" +
"</steps>"

# ── TC004 (2682892) — Missing authorization header ───────────────────────────
$xml4 = "<steps id='0' last='4'>" +
  "<step id='2' type='ActionStep'>" +
    "<parameterizedString isformatted='true'>$s1NoAuthAct</parameterizedString>" +
    "<parameterizedString isformatted='true'>$s1NoAuthExp</parameterizedString>" +
  "</step>" +
  "<step id='3' type='ActionStep'>" +
    "<parameterizedString isformatted='true'>$(Body-Step 'In the request body editor, paste this valid JSON payload:' $bodyNoAuth)</parameterizedString>" +
    "<parameterizedString isformatted='true'>Request body editor shows a valid JSON payload. Authorization header remains absent or empty.</parameterizedString>" +
  "</step>" +
  "<step id='4' type='ActionStep'>" +
    "<parameterizedString isformatted='true'>Click Send to execute the POST request without the Authorization header.</parameterizedString>" +
    "<parameterizedString isformatted='true'>Response HTTP status is 401 or 403. Response body contains an authentication or authorization error. No user is created.</parameterizedString>" +
  "</step>" +
"</steps>"

# ── Apply updates ─────────────────────────────────────────────────────────────
$updates = @(
    @{ id = 2682889; xml = $xml1; label = "TC001 - Create user successfully" },
    @{ id = 2682890; xml = $xml2; label = "TC002 - Missing required field cws" },
    @{ id = 2682891; xml = $xml3; label = "TC003 - Duplicate recId" },
    @{ id = 2682892; xml = $xml4; label = "TC004 - Missing authorization header" }
)

foreach ($u in $updates) {
    Write-Host "Updating $($u.label) (ID $($u.id)) ..."
    $result = az boards work-item update --org $org --id $u.id `
        --field "Microsoft.VSTS.TCM.Steps=$($u.xml)" `
        --only-show-errors 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ID $($u.id) : UPDATED OK"
    } else {
        Write-Host "  ID $($u.id) : ERROR - $result"
    }
}

Write-Host ""
Write-Host "Verify: https://dev.azure.com/cat-digital/Cat%20Digital/_testPlans/execute?planId=2654621&suiteId=2682875"
