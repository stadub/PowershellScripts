[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Module,
    [Parameter(Mandatory)][string]$Version,
    [Parameter(Mandatory)][string]$SourceSha,
    [Parameter(Mandatory)][string]$EvidencePath,
    [Parameter(Mandatory)][string]$SourceRoot,
    [Parameter(Mandatory)][string]$OutputRoot
)
$ErrorActionPreference = 'Stop'
# A successful upload is insufficient: wait for exact-version visibility, bounded.
$found = $null
for ($attempt=0; $attempt -lt 6; $attempt++) {
    try {
        $found = Find-Module -Name $Module -RequiredVersion $Version -Repository PSGallery -ErrorAction Stop
        if ($found.Name -cne $Module -or [version]$found.Version -ne [version]$Version) { throw 'Gallery identity mismatch' }
        break
    } catch {
        if ($attempt -eq 5) { throw }
        Start-Sleep -Seconds 20
    }
}
Save-Module -Name $Module -RequiredVersion $Version -Repository PSGallery -Path $OutputRoot -ErrorAction Stop
$download = Join-Path $OutputRoot "$Module/$Version"
$flat = Join-Path $OutputRoot 'verify'
New-Item $flat -ItemType Directory -Force | Out-Null
Copy-Item $download (Join-Path $flat $Module) -Recurse
& "$PSScriptRoot/Package-Evidence.ps1" -PackageRoot $flat -EvidencePath $EvidencePath -Module $Module -Version $Version -SourceSha $SourceSha -Verify
& "$PSScriptRoot/Test-ReleasePackage.ps1" -Module $Module -SourceRoot $SourceRoot -PackageRoot $flat -ExpectedVersion $Version -InstalledOnly
"Verified https://www.powershellgallery.com/packages/$Module/$Version from $SourceSha" | Write-Host
