[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Module,
    [Parameter(Mandatory)][string]$SourceRoot,
    [Parameter(Mandatory)][string]$PackageRoot,
    [Parameter(Mandatory)][version]$ExpectedVersion,
    [switch]$InstalledOnly
)
$ErrorActionPreference = 'Stop'
$config = & "$PSScriptRoot/Get-ReleaseConfig.ps1" -Module $Module
$sourcePath = $config.PackagePath -replace '/out$', ''
$source = Join-Path $SourceRoot $sourcePath
$package = Join-Path $PackageRoot $Module
$manifest = Join-Path $package $config.Manifest
$data = Import-PowerShellDataFile $manifest
if ([version]$data.ModuleVersion -ne $ExpectedVersion) { throw 'Installed version mismatch' }
Test-ModuleManifest $manifest -ErrorAction Stop | Out-Null
# Test a copy under the normal module layout, never inject tests into publish payload.
$testRoot = Join-Path ([IO.Path]::GetTempPath()) "release-test-$([guid]::NewGuid())"
try {
    $installed = Join-Path $testRoot $sourcePath
    New-Item $installed -ItemType Directory -Force | Out-Null
    Copy-Item "$package/*" $installed -Recurse
    Copy-Item "$source/*.Tests.ps1" $installed -ErrorAction SilentlyContinue
    $loaded = Import-Module (Join-Path $installed $config.Manifest) -Force -PassThru -ErrorAction Stop
    if ($loaded.Version -ne $ExpectedVersion -or $loaded.ExportedCommands.Count -eq 0) {
        throw 'Installed module version/exports smoke check failed'
    }
    Remove-Module $loaded -Force
    if (-not $InstalledOnly) {
        & "$PSScriptRoot/../ci/Invoke-ModuleTests.ps1" -Module $Module -SourceRoot $SourceRoot
    }
    & "$PSScriptRoot/../ci/Invoke-ModuleTests.ps1" -Module $Module -SourceRoot $testRoot
} finally {
    $reports = Join-Path $SourceRoot 'TestResults'
    New-Item $reports -ItemType Directory -Force | Out-Null
    Get-ChildItem (Join-Path $testRoot 'TestResults') -Filter '*.xml' -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item $_.FullName (Join-Path $reports ("installed-" + $_.Name))
    }
    if (Test-Path $testRoot) { Remove-Item $testRoot -Recurse -Force }
}
