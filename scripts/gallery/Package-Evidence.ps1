[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$PackageRoot,
    [Parameter(Mandatory)][string]$EvidencePath,
    [string]$Module, [string]$Version, [string]$SourceSha,
    [switch]$Verify
)
$ErrorActionPreference = 'Stop'
if ($Verify) {
    $evidence = Get-Content $EvidencePath -Raw | ConvertFrom-Json
    if ($evidence.module -cne $Module -or $evidence.version -cne $Version -or $evidence.sourceSha -cne $SourceSha) {
        throw 'Evidence identity mismatch'
    }
} else {
    if ($SourceSha -cnotmatch '^[0-9a-f]{40}$') { throw 'Full immutable SHA required' }
    $evidence = [ordered]@{ module=$Module; version=$Version; sourceSha=$SourceSha; files=@() }
}
$root = (Resolve-Path (Join-Path $PackageRoot $Module)).Path
$files = @(Get-ChildItem $root -Recurse -File | Where-Object Name -ne 'PSGetModuleInfo.xml' | Sort-Object FullName | ForEach-Object {
    [ordered]@{ path=$_.FullName.Substring($root.Length + 1).Replace('\','/'); sha256=(Get-FileHash $_.FullName -Algorithm SHA256).Hash }
})
if ($Verify) {
    if (($files | ConvertTo-Json -Depth 5 -Compress) -cne ($evidence.files | ConvertTo-Json -Depth 5 -Compress)) {
        throw 'Package content hash mismatch'
    }
} else {
    $evidence.files = $files
    $evidence | ConvertTo-Json -Depth 5 | Set-Content $EvidencePath -Encoding utf8
}
