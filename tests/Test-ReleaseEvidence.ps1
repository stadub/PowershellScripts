$ErrorActionPreference = 'Stop'
$root = Join-Path ([IO.Path]::GetTempPath()) "evidence-$([guid]::NewGuid())"
$scripts = Join-Path $PSScriptRoot '../scripts/gallery'
function Expect-Failure([scriptblock]$Action) {
    $failed=$false
    try { & $Action } catch { $failed=$true }
    if (-not $failed) { throw 'Expected fail-closed behavior' }
}
try {
    $module = New-Item "$root/package/Base64String" -ItemType Directory -Force
    'reviewed bytes' | Set-Content "$module/module.ps1"
    $evidenceArgs = @{PackageRoot="$root/package"; EvidencePath="$root/evidence.json";Module='Base64String';Version='1.3.0';SourceSha=('a'*40)}
    & "$scripts/Package-Evidence.ps1" @evidenceArgs
    & "$scripts/Package-Evidence.ps1" @evidenceArgs -Verify
    $wrong=$evidenceArgs.Clone();$wrong.Version='1.2.0'
    Expect-Failure { & "$scripts/Package-Evidence.ps1" @wrong -Verify }
    'generated metadata' | Set-Content "$module/PSGetModuleInfo.xml"
    & "$scripts/Package-Evidence.ps1" @evidenceArgs -Verify
    'tampered bytes' | Set-Content "$module/module.ps1"
    Expect-Failure { & "$scripts/Package-Evidence.ps1" @evidenceArgs -Verify }
    'reviewed bytes' | Set-Content "$module/module.ps1"
    'extra file' | Set-Content "$module/extra.ps1"
    Expect-Failure { & "$scripts/Package-Evidence.ps1" @evidenceArgs -Verify }
    Remove-Item "$module/extra.ps1", "$module/module.ps1"
    Expect-Failure { & "$scripts/Package-Evidence.ps1" @evidenceArgs -Verify }
    # Detect release source/out divergence before code can be tested or published.
    $source=New-Item "$root/source/Shared-Functions/Base64String" -ItemType Directory -Force
    'source' | Set-Content "$source/Base64String.ps1"
    'stale' | Set-Content "$module/Base64String.ps1"
    Expect-Failure { & "$scripts/Assert-SourcePackage.ps1" -Module Base64String -SourceRoot "$root/source" -PackageRoot "$root/package" }
    Copy-Item "$source/Base64String.ps1" "$module/Base64String.ps1" -Force
    & "$scripts/Assert-SourcePackage.ps1" -Module Base64String -SourceRoot "$root/source" -PackageRoot "$root/package"
    Write-Host 'Release evidence: exact identity, tampering, extra/missing files and source/package drift passed.'
} finally { Remove-Item $root -Recurse -Force -ErrorAction SilentlyContinue }
