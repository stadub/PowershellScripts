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
    foreach ($name in 'Bookmarks', '7zip-Archive', 'Currency-Conv', 'Base64String', 'Pipe', 'FolderEncoder', 'Shell-Functions', 'MiniModules.Uninstall') {
        $config = & "$scripts/Get-ReleaseConfig.ps1" -Module $name
        $modulePath = Join-Path $source ($config.PackagePath -replace '/out$', '')
        New-Item "$modulePath/Functions", "$modulePath/out", "$modulePath/tests", "$modulePath/Assets" -ItemType Directory -Force | Out-Null
        $manifest = Join-Path $modulePath $config.Manifest
        $runtime = if ($config.RuntimeFiles.Count) { $config.RuntimeFiles[0] } else { 'Commands.ps1' }
        "@{ ModuleVersion='1.3.0'; GUID='fb5ca217-8826-4570-8241-10a37250331d'; Author='Fixture'; Description='Offline output fixture'; NestedModules=@('$runtime') }" | Set-Content $manifest
        $runtimePath = if ($config.RuntimeFiles.Count) { Join-Path $modulePath $runtime } else { "$modulePath/Functions/$runtime" }
        'function Get-Fixture { throw "Runtime code must not execute in generator" }' | Set-Content $runtimePath
        'excluded stale artifact' | Set-Content "$modulePath/out/stale.ps1"
        'excluded fixture' | Set-Content "$modulePath/tests/Fixtures.ps1"
        'excluded tests' | Set-Content "$modulePath/Fixture.Tests.ps1"
        'excluded CI' | Set-Content "$modulePath/azure-pipelines.yml"
        $expectedLicense = if ($name -eq 'Base64String') { 'explicit module license bytes' } elseif (-not $config.UseRepositoryLicense) { $null } else { 'canonical license bytes' }
        if ($name -eq 'Base64String') { $expectedLicense | Set-Content "$modulePath/LICENSE" }
        'reviewed docs' | Set-Content (Join-Path $modulePath $config.Readme)
        'icon bytes' | Set-Content "$modulePath/Assets/Icon.ico"
        foreach ($attempt in 1,2) {
            & "$scripts/New-ReleaseOutput.ps1" -Module $name -SourceRoot $source -OutputRoot "$fixture/build-$attempt" -ExpectedVersion 1.3.0
        }
        $first = Join-Path "$fixture/build-1" $config.PackagePath
        $second = Join-Path "$fixture/build-2" $config.PackagePath
        $expectedCount = 3 + [int]$config.IncludeIcon + [int]($null -ne $expectedLicense)
        if (@(Get-ChildItem $first -File).Count -ne $expectedCount) { throw "Unexpected generated package contents for $name" }
        foreach ($file in Get-ChildItem $first -File) {
            if ((Get-FileHash $file.FullName).Hash -ne (Get-FileHash (Join-Path $second $file.Name)).Hash) { throw 'Non-reproducible output bytes' }
        }
        Copy-Item "$source/LICENSE" "$fixture/build-1/LICENSE" -Force
        & "$scripts/Build-GalleryPackage.ps1" -Module $name -SourceRoot "$fixture/build-1" -OutputRoot "$fixture/stage" -ExpectedVersion 1.3.0
        & "$scripts/Assert-SourcePackage.ps1" -Module $name -SourceRoot $source -PackageRoot "$fixture/stage"
        if ($null -eq $expectedLicense) {
            if (Test-Path "$fixture/stage/$name/LICENSE") { throw 'Repository license incorrectly replaced a module-specific license declaration' }
        } elseif ((Get-Content "$fixture/stage/$name/LICENSE") -ne $expectedLicense) { throw 'Generation/staging lost selected package license' }
        if ($name -eq 'MiniModules.Uninstall' -and @(Get-ChildItem $first -File | Where-Object { $_.Name -notin @('MiniModules.Uninstall.psd1','Uninstall.psm1','Uninstall.md','LICENSE') }).Count) { throw 'Root standalone package included unrelated repository files' }
        Assert-OutputFailure { & "$scripts/New-ReleaseOutput.ps1" -Module $name -SourceRoot $source -OutputRoot "$fixture/build-1" -ExpectedVersion 1.3.0 } '*Output already exists*'
        if ((Get-Content "$modulePath/out/stale.ps1") -ne 'excluded stale artifact') { throw 'Generator modified existing source output' }
    }
    # Negative cases use Pipe: no partial valid-looking output.
    $config = & "$scripts/Get-ReleaseConfig.ps1" -Module Pipe
    $modulePath = Join-Path $source ($config.PackagePath -replace '/out$', '')
    Assert-OutputFailure { & "$scripts/New-ReleaseOutput.ps1" -Module Pipe -SourceRoot $source -OutputRoot "$fixture/wrong-version" -ExpectedVersion 1.4.0 } '*Expected 1.4.0*'
    'different file' | Set-Content "$modulePath/Commands.ps1"
    Assert-OutputFailure { & "$scripts/New-ReleaseOutput.ps1" -Module Pipe -SourceRoot $source -OutputRoot "$fixture/ambiguous" -ExpectedVersion 1.3.0 } '*Ambiguous flat package filenames*'
    Remove-Item "$modulePath/Commands.ps1", "$modulePath/Functions/Commands.ps1"
    Assert-OutputFailure { & "$scripts/New-ReleaseOutput.ps1" -Module Pipe -SourceRoot $source -OutputRoot "$fixture/missing" -ExpectedVersion 1.3.0 } '*Commands.ps1*'
    if (Test-Path (Join-Path "$fixture/missing" $config.PackagePath)) { throw 'Invalid package left behind' }
    Write-Host 'Release output checks passed: all eight routes, deterministic bytes, flattening, exclusions, module-license precedence, no overwrite, version, ambiguity and missing dependencies.'
} finally { Remove-Item $fixture -Recurse -Force -ErrorAction SilentlyContinue }
