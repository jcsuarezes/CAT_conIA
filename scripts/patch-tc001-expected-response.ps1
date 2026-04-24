# patch-tc001-expected-response.ps1
$org = "https://dev.azure.com/cat-digital"

$s1Action = "Open BRUNO or Swagger. Set URL: https://sis-ws-admin-dev.cat.com/sis-ws-admin/services/users/ | Method: POST | Accept: application/addupdateuser-v1+json | Authorization: Bearer Token Dealer"
$s1Expected = "BRUNO or Swagger is open. URL set, method POST selected, Accept and Authorization headers configured. Request is ready to execute."

$bodyFull = "{&quot;userTypeCode&quot;:&quot;005&quot;,&quot;cws&quot;:&quot;td04xx3&quot;,&quot;recId&quot;:&quot;PSP-00055274&quot;,&quot;name&quot;:&quot;td00nv&quot;,&quot;affiliationOrgCode&quot;:&quot;TD03&quot;,&quot;organization&quot;:&quot;CATERPILLAR DEMO DEALER TD00&quot;,&quot;dealerCode&quot;:&quot;TD00&quot;,&quot;accessTypeIds&quot;:[1],&quot;isTechnicalCommunicator&quot;:false,&quot;isActive&quot;:true,&quot;isAdmin&quot;:true,&quot;reasonId&quot;:1,&quot;note&quot;:&quot;toggle test&quot;}"

$expectedResp = "Response HTTP status is 200 or 201. Response body contains user: created. Expected response body:&lt;br/&gt;&lt;pre&gt;{&lt;br/&gt;&amp;nbsp;&amp;nbsp;&quot;infoMessage&quot;: &quot;User td04xx3 updated successfully&quot;&lt;br/&gt;}&lt;/pre&gt;"

$xml1 = "<steps id='0' last='4'>" +
  "<step id='2' type='ActionStep'>" +
    "<parameterizedString isformatted='true'>$s1Action</parameterizedString>" +
    "<parameterizedString isformatted='true'>$s1Expected</parameterizedString>" +
  "</step>" +
  "<step id='3' type='ActionStep'>" +
    "<parameterizedString isformatted='true'>In the request body editor, paste this JSON payload:&lt;br/&gt;&lt;pre&gt;$bodyFull&lt;/pre&gt;</parameterizedString>" +
    "<parameterizedString isformatted='true'>Request body editor shows all required fields: userTypeCode, cws, recId, name, affiliationOrgCode, organization, dealerCode, accessTypeIds, isTechnicalCommunicator, isActive, isAdmin, reasonId, note.</parameterizedString>" +
  "</step>" +
  "<step id='4' type='ActionStep'>" +
    "<parameterizedString isformatted='true'>Click Send to execute the POST request.</parameterizedString>" +
    "<parameterizedString isformatted='true'>$expectedResp</parameterizedString>" +
  "</step>" +
"</steps>"

$r = az boards work-item update --org $org --id 2682889 --field "Microsoft.VSTS.TCM.Steps=$xml1" --only-show-errors 2>&1
if ($LASTEXITCODE -eq 0) { Write-Output "2682889 : UPDATED OK" } else { Write-Output "ERROR: $r" }
