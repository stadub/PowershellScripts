[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Bookmarks', '7zip-Archive', 'Currency-Conv', 'Base64String', 'Pipe', 'FolderEncoder', 'Shell-Functions', 'MiniModules.Uninstall')]
    [string]$Module,
    [switch]$RequireGalleryAccount,
    [switch]$RequirePublication
)

# Package branches are deliberately distinct from feature/PR development bases.
# Do not substitute master or dynamically accept arbitrary branch names here.
# These are literal reviewed Git branch names, separate from GitHub Releases
# /releases/latest URL alias. Never resolve a package from development as fallback.
# All configured packages use <module source directory>/out within the snapshot.
# PackagePath is relative to that immutable snapshot, not the runner or branch name.
# GallerySecret is a GitHub environment SECRET NAME, never the API key value.
$configs = @{
    Bookmarks = @{
        ReleaseBranch = 'Bookmarks/release/latest'
        PackagePath = 'Bookmarks/out'
        Manifest = 'Bookmarks.psd1'
        GalleryAccount = 'Stadub'
        PublicationBlockReason = 'Bookmarks requires reconciliation with the published 3.0.1 implementation before preparing 3.0.2; do not relabel the repository 2.2.0 implementation.'
    }
    '7zip-Archive' = @{
        ReleaseBranch = '7-Zip/release/1.1'
        PackagePath = '7Zip/out'
        Manifest = '7zip-Archive.psd1'
        GalleryAccount = 'Stadub'
    }
    'Currency-Conv' = @{
        ReleaseBranch = 'Currency-Conv/release/1.5'
        PackagePath = 'Currency-Conv/out'
        Manifest = 'Currency-Conv.psd1'
        GalleryAccount = 'Stadub'
    }
    Base64String = @{
        ReleaseBranch = 'base64String/release/latest'
        PackagePath = 'Shared-Functions/Base64String/out'
        Manifest = 'Base64String.psd1'
        GalleryAccount = 'MiniModules'
    }
    Pipe = @{
        ReleaseBranch = 'Pipe/release/latest'
        PackagePath = 'Shared-Functions/Pipe/out'
        Manifest = 'Pipe.psd1'
        GalleryAccount = 'MiniModules'
    }
    FolderEncoder = @{
        ReleaseBranch = 'FolderEncoder/release/2.0.1'
        PackagePath = 'FolderEncoder/out'
        Manifest = 'FolderEncoder.psd1'
        GalleryAccount = 'Stadub'
        UseRepositoryLicense = $false
        PublicationBlockReason = 'The new FolderEncoder release candidate requires owner review and integration approval.'
    }
    'Shell-Functions' = @{
        ReleaseBranch = 'Shell-Functions/release/0.0.1'
        PackagePath = 'Shell-Functions/out'
        Manifest = 'Shell-Functions.psd1'
        GalleryAccount = 'MiniModules'
        PublicationBlockReason = 'The new Shell-Functions package requires owner review and integration approval.'
    }
    'MiniModules.Uninstall' = @{
        ReleaseBranch = 'Uninstall/release/1.0.1'
        PackagePath = './out'
        Manifest = 'MiniModules.Uninstall.psd1'
        CiModule = 'Uninstall'
        GalleryAccount = 'MiniModules'
        RuntimeFiles = @('Uninstall.psm1')
        Readme = 'Uninstall.md'
        IncludeIcon = $false
        PublicationBlockReason = 'The new MiniModules.Uninstall release candidate requires owner review and integration approval.'
    }
}
# Gallery usernames are public configuration. API key values live only in the
# protected environment; module selection never accepts an account/secret input.
$accountSecrets = @{
    Stadub = 'PSGALLERY_API_KEY_STADUB'
    MiniModules = 'PSGALLERY_API_KEY_MINIMODULES'
}
$config = $configs[$Module]
$references = Get-Content (Join-Path $PSScriptRoot 'version-reference.json') -Raw | ConvertFrom-Json
$reference = @($references.packages | Where-Object module -eq $Module)
if ($reference.Count -ne 1) { throw "Missing or ambiguous Gallery version reference for $Module" }
$config.LatestGalleryVersion = $reference[0].latestListedVersion
$config.HighestRegisteredVersion = $reference[0].highestRegisteredVersion
$config.PlannedVersion = $reference[0].plannedVersion
$config.VersionChange = $reference[0].change
$config.VersionPlanStatus = $reference[0].status
if (-not $config.ContainsKey('CiModule')) { $config.CiModule = $Module }
if (-not $config.ContainsKey('UseRepositoryLicense')) { $config.UseRepositoryLicense = $true }
if (-not $config.ContainsKey('IncludeIcon')) { $config.IncludeIcon = $true }
if (-not $config.ContainsKey('RuntimeFiles')) { $config.RuntimeFiles = @() }
if (-not $config.ContainsKey('Readme')) { $config.Readme = 'README.md' }
if (-not $config.ContainsKey('PublicationBlockReason')) { $config.PublicationBlockReason = $null }
$config.GallerySecret = $null
if (-not [string]::IsNullOrWhiteSpace($config.GalleryAccount) -and $accountSecrets.ContainsKey($config.GalleryAccount)) {
    $config.GallerySecret = $accountSecrets[$config.GalleryAccount]
}
if (($RequireGalleryAccount -or $RequirePublication) -and -not $config.GallerySecret) {
    throw "No approved Gallery account/key mapping for $Module. Owner selection or ownership access is required."
}
if ($RequirePublication -and $config.PublicationBlockReason) {
    throw $config.PublicationBlockReason
}
[pscustomobject]$config
