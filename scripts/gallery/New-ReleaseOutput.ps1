[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Module,
    [Parameter(Mandatory)][string]$SourceRoot,
    [Parameter(Mandatory)][string]$OutputRoot,
    [Parameter(Mandatory)][version]$ExpectedVersion
)
$ErrorActionPreference = 'Stop'
$config = & "$PSScriptRoot/Get-ReleaseConfig.ps1" -Module $Module
$sourceRootPath = (Resolve-Path $SourceRoot).Path
$source = Join-Path $sourceRootPath ($config.PackagePath -replace '/out$', '')
$manifest = Join-Path $source $config.Manifest
if (-not (Test-Path $manifest -PathType Leaf)) { throw "Source manifest missing: $manifest" }
$metadata = Import-PowerShellDataFile $manifest
if ([version]$metadata.ModuleVersion -ne $ExpectedVersion) {
    throw "Expected $ExpectedVersion, but source manifest declares $($metadata.ModuleVersion)."
}
if ($metadata.PrivateData.PSData.Prerelease) { throw 'Only stable manifest versions are supported.' }
$destination = Join-Path $OutputRoot $config.PackagePath
if (Test-Path $destination) { throw "Output already exists: $destination. Use a fresh output root and review replacement separately." }

# Generate in isolation. No source changes, version rewrites, stale out/ reuse,
# import-time module execution, or Gallery calls belong in package generation.
$temporary = Join-Path ([IO.Path]::GetTempPath()) "release-output-$([guid]::NewGuid())"
try {
    $package = New-Item (Join-Path $temporary $Module) -ItemType Directory -Force
    $files = @(Get-Item $manifest)
    $files += @(Get-ChildItem $source -Recurse -File | Where-Object {
        $relative = $_.FullName.Substring($source.Length + 1)
        $_.Extension -in '.ps1', '.psm1', '.dll', '.ps1xml' -and
        $relative -notmatch '(^|[/\\])(out|tests?|TestResults|Assets|\.git|\.github)([/\\]|$)' -and
        $_.Name -notmatch '\.(Tests?|SmokeTests)\.ps1$'
    })
    foreach ($name in 'README.md', 'LICENSE') {
        $file = Join-Path $source $name
        if (Test-Path $file -PathType Leaf) { $files += Get-Item $file }
    }
    $icon = Join-Path $source 'Assets/Icon.ico'
    if (Test-Path $icon -PathType Leaf) { $files += Get-Item $icon }
    # Repository license is the canonical license for these configured modules.
    $license = Join-Path $sourceRootPath 'LICENSE'
    if (Test-Path $license -PathType Leaf) {
        $files = @($files | Where-Object Name -ne 'LICENSE') + @(Get-Item $license)
    }
    $duplicates = @($files | Group-Object Name | Where-Object Count -gt 1)
    if ($duplicates.Count) { throw "Ambiguous flat package filenames: $($duplicates.Name -join ', ')" }
    foreach ($file in $files | Sort-Object Name) {
        if ($file.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked package file is not supported: $($file.Name)" }
        Copy-Item $file.FullName (Join-Path $package $file.Name)
    }
    Test-ModuleManifest (Join-Path $package $config.Manifest) -ErrorAction Stop | Out-Null
    & "$PSScriptRoot/Assert-SourcePackage.ps1" -Module $Module -SourceRoot $sourceRootPath -PackageRoot $temporary
    # The destination appears only after validation succeeds. Existing output is
    # never deleted or replaced; copying into a release checkout remains explicit.
    New-Item (Split-Path $destination -Parent) -ItemType Directory -Force | Out-Null
    Copy-Item $package.FullName $destination -Recurse
    Write-Host "Generated $Module $ExpectedVersion at $destination. Review and run source/installed tests before committing the release snapshot."
} finally {
    if (Test-Path $temporary) { Remove-Item $temporary -Recurse -Force }
}
