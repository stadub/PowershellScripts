[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Module,
    [Parameter(Mandatory)][ValidatePattern('^\d+\.\d+\.\d+(\.\d+)?$')][string]$Version
)
$ErrorActionPreference = 'Stop'
$config = & "$PSScriptRoot/Get-ReleaseConfig.ps1" -Module $Module
function ConvertTo-ComparableVersion([string]$Value) {
    $parsed = [version]$Value
    # NuGet treats a zero fourth segment as the same version, not a new patch.
    [version]::new($parsed.Major, $parsed.Minor, $parsed.Build, [Math]::Max(0, $parsed.Revision))
}
$requested = ConvertTo-ComparableVersion $Version
$planned = ConvertTo-ComparableVersion $config.PlannedVersion
if ($config.HighestRegisteredVersion -and
    $requested -le (ConvertTo-ComparableVersion $config.HighestRegisteredVersion)) {
    throw "$Module $Version must be newer than the recorded highest registered Gallery version $($config.HighestRegisteredVersion), including unlisted versions. Latest listed: $($config.LatestGalleryVersion); planned reference: $($config.PlannedVersion). Prepare and review matching source/out before dispatch."
}
if ($requested.Major -ne $planned.Major) {
    throw "$Module $Version does not follow the reviewed version reference $($config.PlannedVersion). Only 7zip-Archive has an authorized new major bump (1.1.0 to 2.0.0); other packages retain their Gallery major or approved initial version."
}
if (-not $config.HighestRegisteredVersion -and $requested -lt $planned) {
    throw "$Module is a new package; the approved initial version reference is $($config.PlannedVersion)."
}
Write-Host "Version reference passed: $Module $Version; latest listed $($config.LatestGalleryVersion), highest registered $($config.HighestRegisteredVersion), planned $($config.PlannedVersion). Snapshot/package validation is still required."
