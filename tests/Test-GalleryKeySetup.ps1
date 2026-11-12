# Offline command contracts: no real gh process, key prompt, network or secret update.
$ErrorActionPreference = 'Stop'
$scriptPath = Join-Path $PSScriptRoot '../scripts/gallery/Set-GalleryApiKey.ps1'
$fixtureState = [pscustomobject]@{ Mode='success'; Calls=[System.Collections.Generic.List[object]]::new(); Secret=''; MissingGh=$false }
function Get-Command {
    param($Name, $CommandType, $ErrorAction)
    if ($Name -ne 'gh' -or $CommandType -ne 'Application') { throw 'Unexpected command lookup' }
    if ($fixtureState.MissingGh) { throw 'Fixture gh missing' }
    [pscustomobject]@{ Source='Invoke-KeySetupGhFixture' }
}
function Invoke-KeySetupGhFixture {
    param([Parameter(ValueFromRemainingArguments)][string[]]$GhArguments)
    $fixtureState.Calls.Add([object]$GhArguments)
    $global:LASTEXITCODE = 0
    if ($GhArguments[0] -eq 'secret') {
        if ($GhArguments[1] -ne 'set') { throw 'Unexpected secret operation' }
        $fixtureState.Secret = $GhArguments[2]
        if ($fixtureState.Mode -eq 'set-failure') { $global:LASTEXITCODE=1 }
        return
    }
    if ($GhArguments[0] -ne 'api' -or $GhArguments[2] -ne 'github.com') { throw 'Unexpected API command' }
    $endpoint=$GhArguments[3]
    if ($endpoint -like '*/secrets/*') {
        if ($fixtureState.Mode -eq 'verify-failure') { $global:LASTEXITCODE=1; return }
        return @{name=$fixtureState.Secret; updated_at='2026-11-11T20:00:00Z'} | ConvertTo-Json -Compress
    }
    if ($endpoint -like '*/deployment-branch-policies?*') {
        if ($fixtureState.Mode -eq 'policy-failure') { $global:LASTEXITCODE=1; return }
        $policies=@(@{name='master';type='branch'})
        if ($fixtureState.Mode -eq 'wrong-branch') { $policies=@(@{name='develop';type='branch'}) }
        if ($fixtureState.Mode -eq 'tag-policy') { $policies=@(@{name='master';type='tag'}) }
        if ($fixtureState.Mode -eq 'extra-policy') { $policies+=@{name='*';type='branch'} }
        return @{total_count=$policies.Count;branch_policies=$policies} | ConvertTo-Json -Depth 4 -Compress
    }
    if ($fixtureState.Mode -eq 'missing-environment') { $global:LASTEXITCODE=1; return }
    @{ name='powershell-gallery'; deployment_branch_policy=@{custom_branch_policies=($fixtureState.Mode -ne 'unrestricted');protected_branches=$false} } | ConvertTo-Json -Compress
}
function Expect-KeySetupFailure([string]$Mode, [string]$Pattern) {
    $fixtureState.Mode=$Mode; $fixtureState.Calls.Clear(); $caught=$null
    try { & $scriptPath -Module Base64String } catch { $caught=$_ }
    if (-not $caught -or $caught.Exception.Message -notlike $Pattern) { throw "Expected '$Pattern', got '$caught'" }
    if ($Mode -notin 'set-failure','verify-failure' -and @($fixtureState.Calls | Where-Object { $_[0] -eq 'secret' }).Count) { throw 'Secret write attempted despite failed preflight' }
}
$savedExitCode=$global:LASTEXITCODE
try {
    & $scriptPath -Module Base64String -WhatIf
    if ($fixtureState.Calls.Count) { throw 'WhatIf contacted gh' }
    $expected=@{Bookmarks='PSGALLERY_API_KEY_STADUB';'7zip-Archive'='PSGALLERY_API_KEY_STADUB';'Currency-Conv'='PSGALLERY_API_KEY_STADUB';Base64String='PSGALLERY_API_KEY_MINIMODULES';Pipe='PSGALLERY_API_KEY_MINIMODULES';FolderEncoder='PSGALLERY_API_KEY_STADUB';'Shell-Functions'='PSGALLERY_API_KEY_MINIMODULES';'MiniModules.Uninstall'='PSGALLERY_API_KEY_MINIMODULES'}
    foreach ($name in $expected.Keys) {
        $fixtureState.Mode='success';$fixtureState.Calls.Clear()
        $result=& $scriptPath -Module $name
        if ($result.SecretName -cne $expected[$name] -or $result.Environment -cne 'powershell-gallery' -or $fixtureState.Calls.Count -ne 4) { throw 'Wrong environment/account secret route' }
        $set=@($fixtureState.Calls | Where-Object { $_[0] -eq 'secret' })
        if ($set.Count -ne 1) { throw 'Expected exactly one secret update' }
        $expectedArguments=@('secret','set',$expected[$name],'--env','powershell-gallery','--repo','github.com/stadub/PowershellScripts','--app','actions')
        if (($set[0] -join '|') -cne ($expectedArguments -join '|')) { throw 'Secret scope or stdin-only CLI arguments differ' }
    }
    Expect-KeySetupFailure missing-environment '*Cannot read the existing*'
    Expect-KeySetupFailure unrestricted '*master-only*'
    Expect-KeySetupFailure wrong-branch '*allow only the master*'
    Expect-KeySetupFailure tag-policy '*allow only the master*'
    Expect-KeySetupFailure extra-policy '*allow only the master*'
    Expect-KeySetupFailure policy-failure '*Cannot verify*'
    Expect-KeySetupFailure set-failure '*could not update*'
    Expect-KeySetupFailure verify-failure '*update command succeeded*'
    $fixtureState.MissingGh=$true
    Expect-KeySetupFailure missing-gh '*Install GitHub CLI*'
    Write-Host 'Key setup contracts passed: eight owner-approved account routes, hidden-prompt arguments, environment-only scope, WhatIf, protection/auth/update/verification failures.'
} finally { $global:LASTEXITCODE=$savedExitCode }
