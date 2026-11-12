# Offline contracts for the three modules added to CI. No registry/process operations.
$ErrorActionPreference = 'Stop'
$fixture = Join-Path ([IO.Path]::GetTempPath()) "ci-structure-$([guid]::NewGuid())"
$runner = Join-Path $PSScriptRoot '../scripts/ci/Invoke-ModuleTests.ps1'
function Assert-StructureFailure([string]$Module, [string]$Pattern) {
    $caught = $null
    try { & $runner -Module $Module -SourceRoot $fixture } catch { $caught = $_ }
    if (-not $caught -or $caught.Exception.Message -notlike $Pattern) { throw "Expected '$Pattern', got '$caught'" }
    $report = [xml](Get-Content "$fixture/TestResults/$Module-structure.xml" -Raw)
    if ([int]$report.'test-results'.failures -lt 1) { throw 'Failed check has no failed report' }
}
try {
    New-Item "$fixture/FolderEncoder", "$fixture/Shell-Functions" -ItemType Directory -Force | Out-Null
    $folder = "$fixture/FolderEncoder/FolderEncoder.psd1"
    "@{ ModuleVersion='1.0.0'; NestedModules=@('Functions.ps1'); FunctionsToExport=@('EncodeFolder') }" | Set-Content $folder
    Assert-StructureFailure FolderEncoder '*Functions.ps1*'
    'function EncodeFolder { throw "must not execute during import checks" }' | Set-Content "$fixture/FolderEncoder/Functions.ps1"
    & $runner -Module FolderEncoder -SourceRoot $fixture
    $shellManifest = "$fixture/Shell-Functions/Shell-Function.psd1"
    "@{ ModuleVersion='1.0.0'; FunctionsToExport=@() }" | Set-Content $shellManifest
    Assert-StructureFailure Shell-Functions '*exports no commands*'
    "@{ ModuleVersion='1.0.0'; RootModule='Shell-Function.psm1'; FunctionsToExport=@('Get-Fixture') }" | Set-Content $shellManifest
    'function Get-Fixture { "fixture" }; Export-ModuleMember -Function Get-Fixture' | Set-Content "$fixture/Shell-Functions/Shell-Function.psm1"
    & $runner -Module Shell-Functions -SourceRoot $fixture
    'function Broken {' | Set-Content "$fixture/Shell-Functions/Shell-Function.psm1"
    Assert-StructureFailure Shell-Functions '*Syntax errors*'
    'throw "import fixture failure"' | Set-Content "$fixture/Shell-Functions/Shell-Function.psm1"
    Assert-StructureFailure Shell-Functions '*import fixture failure*'
    'function Wrong-Command {}; Export-ModuleMember -Function Wrong-Command' | Set-Content "$fixture/Uninstall.psm1"
    Assert-StructureFailure Uninstall '*command/parameter contract*'
    # Destructive body would fail if the checker invoked the exported command.
    'function Uninstall-Application { param([Alias("Application")][string]$SoftwareName); throw "must never uninstall" }; Export-ModuleMember -Function Uninstall-Application' | Set-Content "$fixture/Uninstall.psm1"
    & $runner -Module Uninstall -SourceRoot $fixture
    foreach ($name in 'FolderEncoder', 'Uninstall') {
        $report = [xml](Get-Content "$fixture/TestResults/$name-structure.xml" -Raw)
        if ([int]$report.'test-results'.failures -ne 0) { throw 'Successful check has failed report' }
    }
    Write-Host 'Extended CI contracts passed: missing dependency, empty exports, syntax/import failure, safe standalone import and reports.'
} finally { Remove-Item $fixture -Recurse -Force -ErrorAction SilentlyContinue }
