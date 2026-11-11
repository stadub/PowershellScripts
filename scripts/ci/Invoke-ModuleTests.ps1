[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Bookmarks', '7zip-Archive', 'Currency-Conv', 'Base64String', 'Pipe', 'FolderEncoder', 'Shell-Functions', 'Uninstall')]
    [string]$Module,
    [string]$SourceRoot
)

$ErrorActionPreference = 'Stop'
$root = if ($SourceRoot) { (Resolve-Path $SourceRoot).Path } else { (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path }
$config = & (Join-Path $PSScriptRoot 'Get-CiModuleConfig.ps1') -Module $Module
$modulePath = Join-Path $root $config.SourcePath

if (-not (Test-Path $modulePath -PathType Container)) {
    throw "Module directory missing on this branch: $modulePath"
}

if ($Module -in 'FolderEncoder', 'Shell-Functions', 'Uninstall') {
    & (Join-Path $PSScriptRoot 'Test-ModuleStructure.ps1') -Module $Module -SourceRoot $root
    $suiteFilter = if ($Module -eq 'Uninstall') { 'Uninstall*.Tests.ps1' } else { '*.Tests.ps1' }
    if (-not (Get-ChildItem -LiteralPath $modulePath -Filter $suiteFilter -File)) {
        Write-Host "$Module structure/import checks passed; no functional Pester suite exists yet."
        return
    }
}

if ($Module -eq 'Pipe') {
    # Validate Pipe imports even on older branches without a Pester suite.
    Test-ModuleManifest (Join-Path $modulePath 'Pipe.psd1') -ErrorAction Stop | Out-Null
    if (-not (Get-ChildItem -LiteralPath $modulePath -Filter '*.Tests.ps1' -File)) { return }
}

# Discover source suites beside the manifest, excluding packaged out/ copies.
$suiteFilter = if ($Module -eq 'Uninstall') { 'Uninstall*.Tests.ps1' } else { '*.Tests.ps1' }
$testPaths = @(Get-ChildItem -LiteralPath $modulePath -Filter $suiteFilter -File |
    Sort-Object Name | Select-Object -ExpandProperty FullName)
if ($testPaths.Count -eq 0) { throw "No test files found for $Module" }

# Existing suites use Pester 4 mocks and assertions; do not implicitly upgrade them.
if (-not (Get-Module -ListAvailable Pester | Where-Object Version -eq '4.10.1')) {
    Install-Module Pester -RequiredVersion 4.10.1 -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module Pester -RequiredVersion 4.10.1 -Force
$results = Join-Path $root 'TestResults'
New-Item $results -ItemType Directory -Force | Out-Null
$report = Join-Path $results "$Module.xml"
Push-Location $modulePath
try {
    $result = Invoke-Pester -Script $testPaths -PassThru -OutputFile $report -OutputFormat NUnitXml
    if ($result.TotalCount -eq 0) { throw "No tests discovered for $Module" }
    if ($result.FailedCount -gt 0) { throw "$($result.FailedCount) tests failed for $Module" }
} finally {
    Pop-Location
}
