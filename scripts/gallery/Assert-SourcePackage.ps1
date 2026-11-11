param([string]$Module, [string]$SourceRoot, [string]$PackageRoot)
$ErrorActionPreference = 'Stop'
$config = & "$PSScriptRoot/Get-ReleaseConfig.ps1" -Module $Module
$source = Join-Path $SourceRoot ($config.PackagePath -replace '/out$', '')
foreach ($file in Get-ChildItem (Join-Path $PackageRoot $Module) -File | Where-Object Extension -in '.ps1','.psm1','.psd1') {
    $matches = @(Get-ChildItem $source -File -Recurse | Where-Object { $_.Name -eq $file.Name -and $_.FullName -notmatch '[/\\]out[/\\]' })
    if ($matches.Count -ne 1 -or (Get-FileHash $matches[0].FullName).Hash -ne (Get-FileHash $file.FullName).Hash) {
        throw "Source/package divergence: $($file.Name). Reconcile and review before releasing."
    }
}
