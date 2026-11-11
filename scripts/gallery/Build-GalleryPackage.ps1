[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Module,
    [Parameter(Mandatory)][string]$SourceRoot,
    [Parameter(Mandatory)][string]$OutputRoot,
    [Parameter(Mandatory)][version]$ExpectedVersion
)

$ErrorActionPreference = 'Stop'
$config = & (Join-Path $PSScriptRoot 'Get-ReleaseConfig.ps1') -Module $Module
$source = Join-Path (Resolve-Path $SourceRoot).Path $config.PackagePath
$manifestPath = Join-Path $source $config.Manifest
if (-not (Test-Path $manifestPath -PathType Leaf)) {
    throw "Release package is missing: $manifestPath. Generate and review release output first."
}
$metadata = Import-PowerShellDataFile $manifestPath
if ([version]$metadata.ModuleVersion -ne $ExpectedVersion) {
    throw "Expected $ExpectedVersion, but release manifest declares $($metadata.ModuleVersion)."
}
if ($metadata.PrivateData.PSData.Prerelease) {
    throw 'This workflow currently supports stable manifest versions only.'
}

$destination = Join-Path $OutputRoot $Module
if (Test-Path $destination) { throw "Output already exists: $destination. Use a fresh staging directory." }
New-Item $destination -ItemType Directory -Force | Out-Null
# These five release packages are flat. Never publish the monorepo, tests, CI,
# secrets, or nested build output by passing a module source tree wholesale.
$allowed = '.ps1', '.psm1', '.psd1', '.dll', '.xml', '.ps1xml', '.md', '.txt', '.ico', '.png'
Get-ChildItem $source -File | Where-Object {
    $_.Extension -in $allowed -and $_.Name -notmatch '\.(Tests?|SmokeTests)\.ps1$'
} | Copy-Item -Destination $destination
$license = Join-Path $SourceRoot 'LICENSE'
if (Test-Path $license -PathType Leaf) { Copy-Item $license (Join-Path $destination 'LICENSE') }
Test-ModuleManifest (Join-Path $destination $config.Manifest) -ErrorAction Stop | Out-Null
Write-Host "Validated $Module $ExpectedVersion in $destination"
if ($env:GITHUB_STEP_SUMMARY) {
    "Package: $Module $ExpectedVersion. Review gallery-package before publishing." >> $env:GITHUB_STEP_SUMMARY
}
