# fix-steps-quote-attrs.ps1
# Rewrites Microsoft.VSTS.TCM.Steps XML with properly single-quoted attributes
# so Azure Test Plans renders the steps grid correctly.
# Usage: .\scripts\fix-steps-quote-attrs.ps1

$org   = "https://dev.azure.com/cat-digital"
$ids   = @(2682889, 2682890, 2682891, 2682892)

function Add-Quotes {
    param([string]$xml)
    # Quote numeric/boolean attributes: id=N, last=N, isformatted=true/false
    $xml = $xml -replace '(\s|<)(steps|step|parameterizedString)\s+([^>]+)>', {
        $tag = $matches[0]
        # Replace unquoted attribute values: attr=value -> attr='value'
        $tag = [regex]::Replace($tag, '(\w+)=([^''"\s>]+)', { "$(($args[0].Groups[1].Value))='$(($args[0].Groups[2].Value))'" })
        $tag
    }
    return $xml
}

foreach ($id in $ids) {
    Write-Host "Processing TC $id ..."

    # Get current XML
    $obj   = az boards work-item show --org $org --id $id -o json | ConvertFrom-Json
    $steps = $obj.fields.'Microsoft.VSTS.TCM.Steps'

    if (-not $steps) {
        Write-Host "  SKIP: no steps field found"
        continue
    }

    # Fix: add single quotes around all unquoted XML attribute values
    $fixed = [regex]::Replace($steps, '(\w+)=([^''"\s>/]+)', { "$($args[0].Groups[1].Value)='$($args[0].Groups[2].Value)'" })

    # Verify the fix looks correct before applying
    Write-Host "  Fixed XML (first 200 chars): $($fixed.Substring(0, [Math]::Min(200, $fixed.Length)))"

    # Write UTF-8 without BOM to temp file
    $tmpFile = "tmp_fix_steps_$id.xml"
    [System.IO.File]::WriteAllText(
        (Join-Path (Get-Location) $tmpFile),
        $fixed,
        [System.Text.UTF8Encoding]::new($false)
    )

    # Apply via az boards work-item update
    $result = az boards work-item update --org $org --id $id --field "Microsoft.VSTS.TCM.Steps=$fixed" --only-show-errors 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  TC $id : UPDATED OK"
    } else {
        Write-Host "  TC $id : ERROR - $result"
    }

    Remove-Item $tmpFile -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Done. Verify in Test Plans: https://dev.azure.com/cat-digital/Cat%20Digital/_testPlans/execute?planId=2654621&suiteId=2682875"
