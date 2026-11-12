[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Module,
    [Parameter(Mandatory)][string]$PackageRoot,
    [Parameter(Mandatory)][version]$ExpectedVersion
)

$ErrorActionPreference = 'Stop'
$config = & (Join-Path $PSScriptRoot 'Get-ReleaseConfig.ps1') -Module $Module -RequirePublication
if ($env:PSGALLERY_ACCOUNT -cne $config.GalleryAccount) {
    throw "Gallery account mismatch: $Module requires $($config.GalleryAccount). Select its configured credential route."
}
$package = Join-Path (Resolve-Path $PackageRoot).Path $Module
$metadata = Import-PowerShellDataFile (Join-Path $package $config.Manifest)
if ([version]$metadata.ModuleVersion -ne $ExpectedVersion) {
    throw 'Artifact version does not match the requested release.'
}
if ($metadata.PrivateData.PSData.Prerelease) {
    throw 'This workflow currently supports stable manifest versions only.'
}
Test-ModuleManifest (Join-Path $package $config.Manifest) -ErrorAction Stop | Out-Null
if ([string]::IsNullOrWhiteSpace($env:PSGALLERY_API_KEY)) {
    throw "Configure the $($config.GallerySecret) secret for $($config.GalleryAccount) in the powershell-gallery GitHub environment."
}

try {
    $published = Find-Module -Name $Module -Repository PSGallery -ErrorAction Stop
    if ($null -eq $published) {
        throw 'Gallery lookup returned no result without an explicit package-not-found error.'
    }
    if ([version]$published.Version -ge $ExpectedVersion) {
        throw "Gallery already has $Module $($published.Version). Bump the release manifest version before publishing."
    }
} catch {
    # A genuinely new package is allowed. Network/authentication errors must fail.
    if ($_.FullyQualifiedErrorId -notlike 'NoMatchFoundForCriteria*') { throw }
}
Publish-Module -Path $package -Repository PSGallery -NuGetApiKey $env:PSGALLERY_API_KEY -ErrorAction Stop
if ($env:GITHUB_STEP_SUMMARY) {
    "Published $Module $ExpectedVersion using the configured $($config.GalleryAccount) account from source commit $env:SOURCE_SHA." >> $env:GITHUB_STEP_SUMMARY
}
