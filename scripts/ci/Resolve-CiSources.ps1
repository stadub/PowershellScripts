[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Branch,
    [Parameter(Mandatory)][ValidatePattern('^[0-9a-f]{40}$')][string]$CurrentSha,
    [Parameter(Mandatory)][AllowEmptyCollection()][hashtable]$RemoteRefs,
    [string[]]$ChangedPaths = @()
)
$ErrorActionPreference = 'Stop'
$selected = (& "$PSScriptRoot/Select-CiModules.ps1" -Branch $Branch -NoGitHubOutput) | ConvertFrom-Json
$all = (& "$PSScriptRoot/Select-CiModules.ps1" -Branch master -NoGitHubOutput) | ConvertFrom-Json
$routed = @($selected.include.module | Select-Object -Unique)
$componentRun = $routed.Count -eq 1
$changedModules = @()
foreach ($name in @($all.include.module | Select-Object -Unique)) {
    $config = & "$PSScriptRoot/Get-CiModuleConfig.ps1" -Module $name
    foreach ($item in $ChangedPaths) {
        $path = $item.Replace('\','/')
        if ($name -eq 'Uninstall') {
            $matchesSource = $path -eq 'Uninstall.psm1' -or ($path -notlike '*/*' -and $path -like 'Uninstall*.Tests.ps1')
        } else {
            $prefix = "$($config.SourcePath)/"
            $matchesSource = $path.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase) -and
                -not $path.StartsWith("${prefix}out/", [StringComparison]::OrdinalIgnoreCase) -and
                ([IO.Path]::GetExtension($path) -in '.ps1','.psm1','.psd1','.dll','.ps1xml','.xml' -or
                    [IO.Path]::GetFileName($path) -eq '.gitattributes')
        }
        if ($matchesSource) { $changedModules += $name; break }
    }
}
# A source change outside a branch's usual component must not escape testing.
$entries = @($selected.include)
foreach ($name in $changedModules) {
    if ($name -notin $routed) { $entries += @($all.include | Where-Object module -eq $name) }
}
$matrix = @(
    foreach ($entry in $entries) {
        $config = & "$PSScriptRoot/Get-CiModuleConfig.ps1" -Module $entry.module
        $useSnapshot = ($componentRun -and $entry.module -in $routed) -or $entry.module -in $changedModules
        $sha = if ($useSnapshot) { $CurrentSha } else { $RemoteRefs[$config.DevelopmentBranch] }
        if ($sha -cnotmatch '^[0-9a-f]{40}$') {
            throw "Missing or invalid immutable source ref for $($entry.module): $($config.DevelopmentBranch)"
        }
        [ordered]@{
            module=$entry.module
            os=$entry.os
            source_sha=$sha
            source_ref=$(if ($useSnapshot) { 'workflow snapshot' } else { $config.DevelopmentBranch })
            source_mode=$(if ($useSnapshot) { 'snapshot' } else { 'development' })
        }
    }
)
$json = @{include=$matrix} | ConvertTo-Json -Depth 5 -Compress
if ($env:GITHUB_OUTPUT) { "matrix=$json" >> $env:GITHUB_OUTPUT }
$json
