# Offline contract tests: a fixture Pester module checks runner orchestration only.
# Real module assertions still run under Pester 4.10.1 in the matrix jobs.
$ErrorActionPreference = 'Stop'
$fixture = Join-Path ([IO.Path]::GetTempPath()) "ci-runner-$([guid]::NewGuid())"
$savedModulePath = $env:PSModulePath
$originalLocation = Get-Location
$savedPester = @(Get-Module Pester | Select-Object -ExpandProperty Path)
function Assert-RunnerFailure {
    param([string]$Module, [string]$Message)
    $caught = $null
    try { & $runner -Module $Module } catch { $caught = $_ }
    if (-not $caught -or $caught.ToString() -notlike "*$Message*") {
        throw "Expected '$Message', got '$caught'"
    }
    if ((Get-Location).Path -ne $originalLocation.Path) { throw 'Runner did not restore location' }
}
try {
    $ci = New-Item (Join-Path $fixture 'scripts/ci') -ItemType Directory -Force
    Copy-Item (Join-Path $PSScriptRoot '../scripts/ci/Invoke-ModuleTests.ps1') $ci
    $runner = Join-Path $ci 'Invoke-ModuleTests.ps1'
    $pester = New-Item (Join-Path $fixture 'modules/Pester/4.10.1') -ItemType Directory -Force
    @'
@{ RootModule = 'Pester.psm1'; ModuleVersion = '4.10.1'; GUID = '2b264083-fd6b-4897-a827-2d99b548ff29'; FunctionsToExport = @('Invoke-Pester') }
'@ | Set-Content (Join-Path $pester 'Pester.psd1')
    @'
function Invoke-Pester {
    param([string[]]$Script, [switch]$PassThru, [string]$OutputFile, [string]$OutputFormat)
    if (-not $PassThru -or $OutputFormat -ne 'NUnitXml') { throw 'Wrong Pester arguments' }
    foreach ($path in $Script) {
        if ((Split-Path $path) -ne (Get-Location).Path) { throw 'Wrong suite location' }
    }
    if ($Script.Count -ne 2) { throw 'Runner must discover both source suites and exclude out/' }
    '<test-results />' | Set-Content -LiteralPath $OutputFile
    $counts = Get-Content -LiteralPath $Script[0] | ConvertFrom-Json
    [pscustomobject]@{ TotalCount = $counts.TotalCount; FailedCount = $counts.FailedCount }
}
Export-ModuleMember -Function Invoke-Pester
'@ | Set-Content (Join-Path $pester 'Pester.psm1')
    Remove-Module Pester -Force -ErrorAction SilentlyContinue
    $env:PSModulePath = "$(Join-Path $fixture 'modules')$([IO.Path]::PathSeparator)$savedModulePath"
    Assert-RunnerFailure Bookmarks 'Module directory missing'
    $moduleDir = New-Item (Join-Path $fixture 'Bookmarks') -ItemType Directory
    Assert-RunnerFailure Bookmarks 'No test files found'
    $suite = Join-Path $moduleDir 'A.Tests.ps1'
    '{"TotalCount":2,"FailedCount":0}' | Set-Content $suite
    '{}' | Set-Content (Join-Path $moduleDir 'B.Tests.ps1')
    $out = New-Item (Join-Path $moduleDir 'out') -ItemType Directory
    '{}' | Set-Content (Join-Path $out 'Ignored.Tests.ps1')
    & $runner -Module Bookmarks
    if (-not (Test-Path (Join-Path $fixture 'TestResults/Bookmarks.xml'))) { throw 'Missing report' }
    if ((Get-Location).Path -ne $originalLocation.Path) { throw 'Runner did not restore location' }
    '{"TotalCount":0,"FailedCount":0}' | Set-Content $suite
    Assert-RunnerFailure Bookmarks 'No tests discovered'
    '{"TotalCount":2,"FailedCount":1}' | Set-Content $suite
    Assert-RunnerFailure Bookmarks '1 tests failed'
    $pipe = New-Item (Join-Path $fixture 'Shared-Functions/Pipe') -ItemType Directory -Force
    "@{ ModuleVersion = '1.0.0'; NestedModules = @('Missing.ps1') }" |
        Set-Content (Join-Path $pipe 'Pipe.psd1')
    Assert-RunnerFailure Pipe 'Missing.ps1'
    "@{ ModuleVersion = '1.0.0' }" | Set-Content (Join-Path $pipe 'Pipe.psd1')
    & $runner -Module Pipe
} finally {
    Set-Location $originalLocation
    Remove-Module Pester -Force -ErrorAction SilentlyContinue
    $env:PSModulePath = $savedModulePath
    foreach ($path in $savedPester) { Import-Module $path -Force }
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Host 'CI runner contract checks passed (success, failures, discovery, reports, location, manifest).'
