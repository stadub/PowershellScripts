# Fully offline Gallery visibility/download failures; never uses credentials.
$ErrorActionPreference='Stop'
$root=Join-Path ([IO.Path]::GetTempPath()) "gallery-verify-$([guid]::NewGuid())"
$scripts=Join-Path $PSScriptRoot '../scripts/gallery'
function Expect-Failure([scriptblock]$Action) {
    $caught=$false
    try { & $Action } catch { $caught=$true }
    if (-not $caught) { throw 'Expected verification failure' }
}
try {
    New-Item "$root/scripts", "$root/expected/Base64String" -ItemType Directory -Force | Out-Null
    Copy-Item "$scripts/Verify-GalleryPackage.ps1", "$scripts/Package-Evidence.ps1" "$root/scripts"
    # Installed smoke invocation contract; real runtime is tested separately.
    'param($Module,$SourceRoot,$PackageRoot,$ExpectedVersion,[switch]$InstalledOnly); if (-not $InstalledOnly) { throw "Not installed" }; if ($global:verifyMode -eq "smoke-failure") { throw "Bad import" }; $global:smoked=$true' | Set-Content "$root/scripts/Test-ReleasePackage.ps1"
    'exact bytes' | Set-Content "$root/expected/Base64String/module.ps1"
    & "$scripts/Package-Evidence.ps1" -Module Base64String -Version 1.3.0 -SourceSha ('a'*40) -PackageRoot "$root/expected" -EvidencePath "$root/evidence.json"
    function global:Start-Sleep { param($Seconds) }
    function global:Find-Module {
        param($Name,$RequiredVersion,$Repository,$ErrorAction)
        if ($Name -ne 'Base64String' -or $RequiredVersion -ne '1.3.0' -or $Repository -ne 'PSGallery') { throw 'Wrong query' }
        if ($global:verifyMode -eq 'invisible') { throw 'Not visible' }
        if ($global:verifyMode -eq 'wrong-version') { return [pscustomobject]@{Name=$Name;Version='1.2.0'} }
        [pscustomobject]@{Name=$Name;Version=$RequiredVersion}
    }
    function global:Save-Module {
        param($Name,$RequiredVersion,$Repository,$Path,$ErrorAction)
        if ($RequiredVersion -ne '1.3.0') { throw 'Wrong download version' }
        $dest=New-Item "$Path/$Name/$RequiredVersion" -ItemType Directory -Force
        Copy-Item "$root/expected/Base64String/*" $dest
        if ($global:verifyMode -eq 'wrong-bytes') { 'imposter' | Set-Content "$dest/module.ps1" }
    }
    foreach($mode in 'invisible','wrong-version','wrong-bytes','smoke-failure','success') {
        $global:verifyMode=$mode;$global:smoked=$false
        $invoke = { & "$root/scripts/Verify-GalleryPackage.ps1" -Module Base64String -Version 1.3.0 -SourceSha ('a'*40) -SourceRoot "$root/source" -EvidencePath "$root/evidence.json" -OutputRoot "$root/$mode" }
        if($mode -eq 'success') { & $invoke; if(-not $global:smoked) {throw 'Smoke not invoked'} }
        else { Expect-Failure $invoke; if($global:smoked) {throw 'Unexpected smoke success'} }
    }
    Write-Host 'Gallery verification: invisible, wrong version, wrong bytes, import failure and exact success passed.'
} finally {
    Remove-Item function:global:Start-Sleep,function:global:Find-Module,function:global:Save-Module -ErrorAction SilentlyContinue
    Remove-Variable verifyMode,smoked -Scope Global -ErrorAction SilentlyContinue
    Remove-Item $root -Recurse -Force -ErrorAction SilentlyContinue
}
