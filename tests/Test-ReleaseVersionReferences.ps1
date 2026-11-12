# Recorded public Gallery observations only: no network, secrets or publication.
$ErrorActionPreference = 'Stop'
$scripts = Join-Path $PSScriptRoot '../scripts/gallery'
$data = Get-Content (Join-Path $scripts 'version-reference.json') -Raw | ConvertFrom-Json
function Expect-VersionFailure([string]$Module, [string]$Version, [string]$Pattern) {
    $caught = $null
    try { & "$scripts/Test-ReleaseVersionReference.ps1" -Module $Module -Version $Version } catch { $caught = $_ }
    if (-not $caught -or $caught.Exception.Message -notlike $Pattern) { throw "Expected $Module $Version '$Pattern', got '$caught'" }
}
if ($data.packages.Count -ne 8 -or @($data.packages.module | Select-Object -Unique).Count -ne 8) { throw 'Version references must cover exactly eight distinct configured packages' }
if (@($data.packages | Where-Object change -eq major).Count -ne 1 -or
    @($data.packages | Where-Object change -eq major)[0].module -cne '7zip-Archive') { throw 'Only 7Zip may receive a new major version' }
foreach ($entry in $data.packages) {
    $config = & "$scripts/Get-ReleaseConfig.ps1" -Module $entry.module
    if ($config.GalleryAccount -cne $entry.galleryAccount) { throw 'Version reference account differs from trusted package routing' }
    & "$scripts/Test-ReleaseVersionReference.ps1" -Module $entry.module -Version $entry.plannedVersion
    if ($entry.latestListedVersion) {
        $baseline = [version]$entry.latestListedVersion
        $planned = [version]$entry.plannedVersion
        if ($entry.module -ne '7zip-Archive' -and $planned.Major -ne $baseline.Major) { throw 'Unapproved major bump from Gallery baseline' }
        if ($entry.downloadedReference.nupkgSha256 -cnotmatch '^[0-9a-f]{64}$') { throw 'Missing exact downloaded Gallery package evidence' }
    }
}
Expect-VersionFailure Bookmarks 1.3.0 '*highest registered Gallery version 3.0.1*'
Expect-VersionFailure Bookmarks 2.2.0 '*highest registered Gallery version 3.0.1*'
Expect-VersionFailure Bookmarks 4.0.0 '*Only 7zip-Archive*'
Expect-VersionFailure Currency-Conv 1.0.3 '*highest registered Gallery version 1.5.0*'
Expect-VersionFailure Currency-Conv 1.5.0 '*including unlisted versions*'
Expect-VersionFailure Currency-Conv 1.5.0.0 '*including unlisted versions*'
Expect-VersionFailure Base64String 2.0.0 '*Only 7zip-Archive*'
Expect-VersionFailure Pipe 2.0.0 '*Only 7zip-Archive*'
Expect-VersionFailure 7zip-Archive 1.2.0 '*Only 7zip-Archive*'
Expect-VersionFailure 7zip-Archive 3.0.0 '*Only 7zip-Archive*'
Expect-VersionFailure Shell-Functions 0.0.0 '*approved initial version*'
Expect-VersionFailure MiniModules.Uninstall 2.0.0 '*Only 7zip-Archive*'
$bookmarks = & "$scripts/Get-ReleaseConfig.ps1" -Module Bookmarks
if ($bookmarks.PlannedVersion -cne '3.0.2') { throw 'Bookmarks was based on stale source instead of Gallery 3.0.1' }
$caught = $null
try { & "$scripts/Get-ReleaseConfig.ps1" -Module Bookmarks -RequirePublication } catch { $caught = $_ }
if (-not $caught -or $caught.Exception.Message -notlike '*do not relabel*2.2.0*') { throw 'Unreconciled Bookmarks publication was not blocked' }
Write-Host 'Version references passed: all eight modules, latest Gallery baselines, unlisted reservation, zero revision normalization, sole 7Zip major bump and unreconciled Bookmarks block.'
