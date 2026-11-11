# Offline generation contracts. No imports of runtime module code, Gallery calls,
# modification of checked-out modules, or release-branch changes.
$ErrorActionPreference = 'Stop'
$scripts = Join-Path $PSScriptRoot '../scripts/gallery'
$fixture = Join-Path ([IO.Path]::GetTempPath()) "release-output-test-$([guid]::NewGuid())"
function Assert-OutputFailure([scriptblock]$Action, [string]$Pattern) {
    $caught = $null
    try { & $Action } catch { $caught = $_ }
    if (-not $caught -or $caught.Exception.Message -notlike $Pattern) { throw "Expected '$Pattern', got '$caught'" }
}
try {
    $source = New-Item "$fixture/source" -ItemType Directory -Force
    'canonical license bytes' | Set-Content "$source/LICENSE"
    foreach ($name in 'Bookmarks', '7zip-Archive', 'Currency-Conv', 'Base64String', 'Pipe') {
        $config = & "$scripts/Get-ReleaseConfig.ps1" -Module $name
        $modulePath = Join-Path $source ($config.PackagePath -replace '/out$', '')
        New-Item "$modulePath/Functions", "$modulePath/out", "$modulePath/tests", "$modulePath/Assets" -ItemType Directory -Force | Out-Null
        $manifest = Join-Path $modulePath $config.Manifest
        "@{ ModuleVersion='1.3.0'; GUID='fb5ca217-8826-4570-8241-10a37250331d'; Author='Fixture'; Description='Offline output fixture'; NestedModules=@('Commands.ps1') }" | Set-Content $manifest
        'function Get-Fixture { throw "Runtime code must not execute in generator" }' | Set-Content "$modulePath/Functions/Commands.ps1"
        'excluded stale artifact' | Set-Content "$modulePath/out/stale.ps1"
        'excluded fixture' | Set-Content "$modulePath/tests/Fixtures.ps1"
        'excluded tests' | Set-Content "$modulePath/Fixture.Tests.ps1"
        'excluded CI' | Set-Content "$modulePath/azure-pipelines.yml"
        $expectedLicense = if ($name -eq 'Base64String') { 'explicit module license bytes' } else { 'canonical license bytes' }
        if ($name -eq 'Base64String') { $expectedLicense | Set-Content "$modulePath/LICENSE" }
        'reviewed docs' | Set-Content "$modulePath/README.md"
        'icon bytes' | Set-Content "$modulePath/Assets/Icon.ico"
        foreach ($attempt in 1,2) {
            & "$scripts/New-ReleaseOutput.ps1" -Module $name -SourceRoot $source -OutputRoot "$fixture/build-$attempt" -ExpectedVersion 1.3.0
        }
        $first = Join-Path "$fixture/build-1" $config.PackagePath
        $second = Join-Path "$fixture/build-2" $config.PackagePath
        if (@(Get-ChildItem $first -File).Count -ne 5) { throw 'Unexpected generated package contents' }
        foreach ($file in Get-ChildItem $first -File) {
            if ((Get-FileHash $file.FullName).Hash -ne (Get-FileHash (Join-Path $second $file.Name)).Hash) { throw 'Non-reproducible output bytes' }
        }
        Copy-Item "$source/LICENSE" "$fixture/build-1/LICENSE" -Force
        & "$scripts/Build-GalleryPackage.ps1" -Module $name -SourceRoot "$fixture/build-1" -OutputRoot "$fixture/stage" -ExpectedVersion 1.3.0
        & "$scripts/Assert-SourcePackage.ps1" -Module $name -SourceRoot $source -PackageRoot "$fixture/stage"
        if ((Get-Content "$fixture/stage/$name/LICENSE") -ne $expectedLicense) { throw 'Generation/staging lost selected package license' }
        Assert-OutputFailure { & "$scripts/New-ReleaseOutput.ps1" -Module $name -SourceRoot $source -OutputRoot "$fixture/build-1" -ExpectedVersion 1.3.0 } '*Output already exists*'
        if ((Get-Content "$modulePath/out/stale.ps1") -ne 'excluded stale artifact') { throw 'Generator modified existing source output' }
    }
    # Negative cases use the last fixture: no partial valid-looking output.
    Assert-OutputFailure { & "$scripts/New-ReleaseOutput.ps1" -Module Pipe -SourceRoot $source -OutputRoot "$fixture/wrong-version" -ExpectedVersion 1.4.0 } '*Expected 1.4.0*'
    'different file' | Set-Content "$modulePath/Commands.ps1"
    Assert-OutputFailure { & "$scripts/New-ReleaseOutput.ps1" -Module Pipe -SourceRoot $source -OutputRoot "$fixture/ambiguous" -ExpectedVersion 1.3.0 } '*Ambiguous flat package filenames*'
    Remove-Item "$modulePath/Commands.ps1", "$modulePath/Functions/Commands.ps1"
    Assert-OutputFailure { & "$scripts/New-ReleaseOutput.ps1" -Module Pipe -SourceRoot $source -OutputRoot "$fixture/missing" -ExpectedVersion 1.3.0 } '*Commands.ps1*'
    if (Test-Path (Join-Path "$fixture/missing" $config.PackagePath)) { throw 'Invalid package left behind' }
    Write-Host 'Release output checks passed: all five routes, deterministic bytes, flattening, exclusions, module-license precedence, no overwrite, version, ambiguity and missing dependencies.'
} finally { Remove-Item $fixture -Recurse -Force -ErrorAction SilentlyContinue }
