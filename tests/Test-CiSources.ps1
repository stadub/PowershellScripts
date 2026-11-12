$ErrorActionPreference='Stop'
$resolver=Join-Path $PSScriptRoot '../scripts/ci/Resolve-CiSources.ps1'
$current='a'*40
$refs=@{}
$allModules=@('Bookmarks','7zip-Archive','Currency-Conv','Base64String','Pipe','FolderEncoder','Shell-Functions','Uninstall')
foreach($name in $allModules) {
    $cfg=& "$PSScriptRoot/../scripts/ci/Get-CiModuleConfig.ps1" -Module $name
    $refs[$cfg.DevelopmentBranch]='b'*40
}
$savedOutput=$env:GITHUB_OUTPUT
$outputFile=Join-Path ([IO.Path]::GetTempPath()) "ci-sources-$([guid]::NewGuid()).txt"
function Get-Plan([string]$Branch,[string[]]$Paths=@(),[hashtable]$Refs=$refs) {
    (& $resolver -Branch $Branch -CurrentSha $current -RemoteRefs $Refs -ChangedPaths $Paths) | ConvertFrom-Json
}
try {
    $env:GITHUB_OUTPUT=$null
    $plan=Get-Plan master
    if($plan.include.Count -ne 22 -or @($plan.include|Where-Object source_mode -ne development).Count) {throw 'Aggregate baseline is not the eight maintained sources'}
    foreach($entry in $plan.include) {
        if($entry.source_sha -cne ('b'*40)) {throw 'Baseline SHA changed'}
        $cfg=& "$PSScriptRoot/../scripts/ci/Get-CiModuleConfig.ps1" -Module $entry.module
        if($entry.source_ref -cne $cfg.DevelopmentBranch) {throw 'Incorrect maintained ref'}
    }
    $plan=Get-Plan 'Bookmarks/develop' -Refs @{}
    if($plan.include.Count -ne 3 -or @($plan.include|Where-Object source_sha -ne $current).Count) {throw 'Component PR is not testing its actual snapshot'}
    $plan=Get-Plan 'base64String/release/latest' -Refs @{}
    if(@($plan.include|Where-Object source_mode -ne snapshot).Count) {throw 'Release branch is not testing its snapshot'}
    $plan=Get-Plan master @('Shared-Functions/Base64String/Base64String.ps1','Uninstall.psm1')
    foreach($entry in $plan.include) {
        $expected=if($entry.module -in 'Base64String','Uninstall') {$current} else {'b'*40}
        if($entry.source_sha -cne $expected) {throw 'A changed module was ignored or unrelated baseline replaced'}
    }
    $plan=Get-Plan master @('MiniModules.Uninstall.psd1')
    if (@($plan.include | Where-Object { $_.module -eq 'Uninstall' -and $_.source_sha -cne $current }).Count -or
        @($plan.include | Where-Object { $_.module -ne 'Uninstall' -and $_.source_sha -cne ('b'*40) }).Count) { throw 'New standalone manifest change did not select the Uninstall source snapshot' }
    $plan=Get-Plan master @('out/MiniModules.Uninstall.psd1')
    if (@($plan.include | Where-Object source_mode -ne development).Count) { throw 'Standalone packaged output replaced source baseline' }
    $plan=Get-Plan 'Bookmarks/develop' @('Currency-Conv/Functions.ps1')
    if($plan.include.Count -ne 6 -or @($plan.include|Where-Object source_sha -ne $current).Count) {throw 'Cross-component source changes escaped checks'}
    $plan=Get-Plan master @('Bookmarks/README.md','Shared-Functions/Base64String/out/Base64String.ps1')
    if(@($plan.include|Where-Object source_mode -ne development).Count) {throw 'Docs or packaged output falsely replaced source baseline'}
    $badRefs=$refs.Clone();$badRefs.Remove('Shell-Functions/develop');$caught=$false
    try {Get-Plan master -Refs $badRefs | Out-Null} catch {$caught=$_.Exception.Message -like '*Missing or invalid immutable source ref*'}
    if(-not $caught) {throw 'Missing source ref silently accepted'}
    $caught=$false
    try { & $resolver -Branch master -CurrentSha 'main' -RemoteRefs $refs | Out-Null } catch { $caught=$true }
    if(-not $caught) {throw 'Mutable current ref accepted'}
    $env:GITHUB_OUTPUT=$outputFile
    $json=& $resolver -Branch master -CurrentSha $current -RemoteRefs $refs
    $lines=@(Get-Content $outputFile)
    if($lines.Count -ne 1 -or $lines[0] -cne "matrix=$json") {throw 'Source plan emitted duplicate/malformed Actions output'}
    Write-Host 'CI source planning passed: eight pinned baselines, real component/release snapshots, changed-source coverage, no silent ref fallback and single output.'
} finally {
    $env:GITHUB_OUTPUT=$savedOutput
    Remove-Item $outputFile -ErrorAction SilentlyContinue
}
