# Offline checks: fixtures and command mocks; never contacts or publishes to Gallery.
$ErrorActionPreference = 'Stop'
$scripts = Join-Path $PSScriptRoot '../scripts/gallery'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
$oldKey = $env:PSGALLERY_API_KEY
$oldMarker = $env:GALLERY_TEST_MARKER
$oldMode = $env:GALLERY_TEST_MODE
$oldSummary = $env:GITHUB_STEP_SUMMARY
function Assert-Throws([scriptblock]$Action, [string]$Pattern) {
    $caught = $false
    try { & $Action } catch {
        $caught = $true
        if ($_.Exception.Message -notlike $Pattern) { throw }
    }
    if (-not $caught) { throw "Expected failure matching $Pattern" }
}
try {
    # Keep offline fixture runs out of any enclosing Actions job summary.
    $env:GITHUB_STEP_SUMMARY = ''
    $expectedConfigs = @{
        Bookmarks = @('Bookmarks/release/latest', 'Bookmarks/out', 'Bookmarks.psd1', 'Stadub', 'PSGALLERY_API_KEY')
        '7zip-Archive' = @('7-Zip/release/latest', '7Zip/out', '7zip-Archive.psd1', 'Stadub', 'PSGALLERY_API_KEY')
        'Currency-Conv' = @('Currency-Conv/release/latest', 'Currency-Conv/out', 'Currency-Conv.psd1', 'Stadub', 'PSGALLERY_API_KEY')
        Base64String = @('base64String/release/latest', 'Shared-Functions/Base64String/out', 'Base64String.psd1', 'MiniModules', 'PSGALLERY_API_KEY')
        Pipe = @('Pipe/release/latest', 'Shared-Functions/Pipe/out', 'Pipe.psd1', 'MiniModules', 'PSGALLERY_API_KEY')
    }
    foreach ($name in $expectedConfigs.Keys) {
        $config = & "$scripts/Get-ReleaseConfig.ps1" -Module $name
        if ((@($config.ReleaseBranch, $config.PackagePath, $config.Manifest, $config.GalleryAccount, $config.GallerySecret) -join '|') -cne ($expectedConfigs[$name] -join '|')) {
            throw "Unexpected release configuration for $name"
        }
    }
    # Every module must stage out/, even when a source manifest exists beside it.
    foreach ($name in $expectedConfigs.Keys) {
        $config = & "$scripts/Get-ReleaseConfig.ps1" -Module $name
        $layoutRoot = Join-Path $fixture "layout-$name"
        $moduleSource = Join-Path $layoutRoot ($config.PackagePath -replace '/out$', '')
        New-Item $moduleSource -ItemType Directory -Force | Out-Null
        $fixtureManifest = "@{ ModuleVersion = '1.2.0'; GUID = 'fb5ca217-8826-4570-8241-10a37250331d'; Author = 'Test'; Description = 'Offline layout fixture' }"
        $fixtureManifest | Set-Content (Join-Path $moduleSource $config.Manifest)
        Assert-Throws { & "$scripts/Build-GalleryPackage.ps1" -Module $name -SourceRoot $layoutRoot -OutputRoot "$fixture/layout-stage-$name" -ExpectedVersion 1.2.0 } '*Release package is missing*'
        $releaseOut = New-Item (Join-Path $layoutRoot $config.PackagePath) -ItemType Directory -Force
        $fixtureManifest | Set-Content (Join-Path $releaseOut $config.Manifest)
        & "$scripts/Build-GalleryPackage.ps1" -Module $name -SourceRoot $layoutRoot -OutputRoot "$fixture/layout-stage-$name" -ExpectedVersion 1.2.0
        & "$scripts/Assert-SourcePackage.ps1" -Module $name -SourceRoot $layoutRoot -PackageRoot "$fixture/layout-stage-$name"
    }
    $source = Join-Path $fixture 'source'
    $package = Join-Path $source 'Shared-Functions/Base64String/out'
    New-Item $package -ItemType Directory -Force | Out-Null
    @"
@{
 ModuleVersion = '1.2.0'
 GUID = 'fb5ca217-8826-4570-8241-10a37250331d'
 Author = 'Test'
 Description = 'Offline fixture'
 NestedModules = @('Base64String.ps1')
}
"@ | Set-Content (Join-Path $package 'Base64String.psd1')
    'function ConvertTo-Fixture { param($Value) $Value }' | Set-Content (Join-Path $package 'Base64String.ps1')
    'excluded' | Set-Content (Join-Path $package 'Base64String.Tests.ps1')
    'excluded' | Set-Content (Join-Path $package 'Base64String.SmokeTests.ps1')
    'excluded' | Set-Content (Join-Path $package 'azure-pipelines.yml')
    $stage = Join-Path $fixture 'stage'
    & "$scripts/Build-GalleryPackage.ps1" -Module Base64String -SourceRoot $source -OutputRoot $stage -ExpectedVersion 1.2.0
    $built = Join-Path $stage 'Base64String'
    if (@(Get-ChildItem $built -File).Count -ne 2) { throw 'Package includes unexpected files' }
    Assert-Throws { & "$scripts/Build-GalleryPackage.ps1" -Module Base64String -SourceRoot $source -OutputRoot "$fixture/wrong" -ExpectedVersion 1.3.0 } '*Expected 1.3.0*'
    Assert-Throws { & "$scripts/Build-GalleryPackage.ps1" -Module Base64String -SourceRoot $source -OutputRoot $stage -ExpectedVersion 1.2.0 } '*Output already exists*'
    Assert-Throws { & "$scripts/Get-ReleaseConfig.ps1" -Module '../invalid' } '*ValidateSet*'
    Assert-Throws { & "$scripts/Get-ReleaseConfig.ps1" -Module 'FolderEncoder' } '*ValidateSet*'
    $manifest = Join-Path $built 'Base64String.psd1'
    $originalManifest = Get-Content $manifest -Raw
    $prereleaseManifest = $originalManifest.Replace("ModuleVersion = '1.2.0'", "ModuleVersion = '1.2.0'; PrivateData = @{ PSData = @{ Prerelease = 'beta1' } }")
    $prereleaseManifest | Set-Content (Join-Path $package 'Base64String.psd1')
    Assert-Throws { & "$scripts/Build-GalleryPackage.ps1" -Module Base64String -SourceRoot $source -OutputRoot "$fixture/prerelease" -ExpectedVersion 1.2.0 } '*stable manifest versions only*'
    $originalManifest | Set-Content (Join-Path $package 'Base64String.psd1')
    Remove-Item (Join-Path $package 'Base64String.ps1')
    Assert-Throws { & "$scripts/Build-GalleryPackage.ps1" -Module Base64String -SourceRoot $source -OutputRoot "$fixture/missing-dependency" -ExpectedVersion 1.2.0 } '*'

    function global:Find-Module {
        param($Name, $Repository, $ErrorAction)
        switch ($env:GALLERY_TEST_MODE) {
            'duplicate' { [pscustomobject]@{ Version = [version]'1.2.0' } }
            'newer' { [pscustomobject]@{ Version = [version]'2.0.0' } }
            'empty' { return }
            'network' { throw 'Simulated network failure' }
            'new' { Write-Error 'No package found' -ErrorId NoMatchFoundForCriteria -ErrorAction Stop }
            default { [pscustomobject]@{ Version = [version]'1.1.0' } }
        }
    }
    function global:Publish-Module {
        param($Path, $Repository, $NuGetApiKey, $ErrorAction)
        if ($NuGetApiKey -ne 'offline-test-key') { throw 'Unexpected test key' }
        $Path | Set-Content $env:GALLERY_TEST_MARKER
    }
    $env:GALLERY_TEST_MARKER = Join-Path $fixture 'published.txt'
    Assert-Throws { & "$scripts/Publish-GalleryPackage.ps1" -Module Base64String -PackageRoot $stage -ExpectedVersion 1.3.0 } '*Artifact version*'
    $prereleaseManifest | Set-Content $manifest
    Assert-Throws { & "$scripts/Publish-GalleryPackage.ps1" -Module Base64String -PackageRoot $stage -ExpectedVersion 1.2.0 } '*stable manifest versions only*'
    $originalManifest | Set-Content $manifest
    $env:PSGALLERY_API_KEY = ''
    # Validate missing selected credentials for every configured module. These
    # fixtures contain no module code and the Gallery commands remain mocked.
    foreach ($name in $expectedConfigs.Keys) {
        $config = & "$scripts/Get-ReleaseConfig.ps1" -Module $name
        $accountPackage = Join-Path "$fixture/accounts" $name
        New-Item $accountPackage -ItemType Directory -Force | Out-Null
        "@{ ModuleVersion = '1.2.0'; GUID = 'fb5ca217-8826-4570-8241-10a37250331d'; Author = 'Test'; Description = 'Offline fixture' }" | Set-Content (Join-Path $accountPackage $config.Manifest)
        Assert-Throws { & "$scripts/Publish-GalleryPackage.ps1" -Module $name -PackageRoot "$fixture/accounts" -ExpectedVersion 1.2.0 } "*Configure the $($config.GallerySecret) secret for $($config.GalleryAccount)*"
    }
    $env:PSGALLERY_API_KEY = 'offline-test-key'
    $env:GALLERY_TEST_MODE = 'duplicate'
    Assert-Throws { & "$scripts/Publish-GalleryPackage.ps1" -Module Base64String -PackageRoot $stage -ExpectedVersion 1.2.0 } '*Gallery already has*'
    $env:GALLERY_TEST_MODE = 'newer'
    Assert-Throws { & "$scripts/Publish-GalleryPackage.ps1" -Module Base64String -PackageRoot $stage -ExpectedVersion 1.2.0 } '*Gallery already has*'
    $env:GALLERY_TEST_MODE = 'empty'
    Assert-Throws { & "$scripts/Publish-GalleryPackage.ps1" -Module Base64String -PackageRoot $stage -ExpectedVersion 1.2.0 } '*Gallery lookup returned no result*'
    $env:GALLERY_TEST_MODE = 'network'
    Assert-Throws { & "$scripts/Publish-GalleryPackage.ps1" -Module Base64String -PackageRoot $stage -ExpectedVersion 1.2.0 } '*Simulated network failure*'
    if (Test-Path $env:GALLERY_TEST_MARKER) { throw 'Published despite a failed preflight' }
    foreach ($mode in @('upgrade', 'new')) {
        $env:GALLERY_TEST_MODE = $mode
        & "$scripts/Publish-GalleryPackage.ps1" -Module Base64String -PackageRoot $stage -ExpectedVersion 1.2.0
        if (-not (Test-Path $env:GALLERY_TEST_MARKER)) { throw 'Expected mocked publish call' }
        Remove-Item $env:GALLERY_TEST_MARKER
    }
    Write-Host 'Offline packaging and publishing checks passed.'
} finally {
    Remove-Item function:global:Find-Module, function:global:Publish-Module -ErrorAction SilentlyContinue
    $env:PSGALLERY_API_KEY = $oldKey
    $env:GALLERY_TEST_MARKER = $oldMarker
    $env:GALLERY_TEST_MODE = $oldMode
    $env:GITHUB_STEP_SUMMARY = $oldSummary
    if (Test-Path $fixture) { Remove-Item $fixture -Recurse -Force }
}
