<#
.SYNOPSIS
Optional offline source smoke test; requires an already installed 7-Zip runtime.
.DESCRIPTION
Exercises the archive implementation directly to avoid the module's separate
Gallery update check. Never installs/downloads tools or writes in the checkout.
#>
[CmdletBinding()]
param ([string]$Executable = $env:SEVENZIP_PATH)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'Shared-Functions.ps1')
. (Join-Path $PSScriptRoot 'Functions.ps1')

$savedRuntime = $env:SEVENZIP_PATH
$temporaryDirectory = $null
$pushed = $false
try {
    if (-not [string]::IsNullOrWhiteSpace($Executable)) {
        $env:SEVENZIP_PATH = $Executable
    }
    _Initalize
    # Fail clearly if unavailable; no implicit download or installation.
    Test-7ZipInstall
    Write-Host "Smoke testing runtime: $script:_7zPath"
    $temporaryDirectory = Join-Path ([IO.Path]::GetTempPath()) ('7zip smoke ' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $temporaryDirectory | Out-Null
    Push-Location -LiteralPath $temporaryDirectory
    $pushed = $true
    $archive = 'archive name.7z'
    $source = 'source file.txt'
    $additional = 'added file.txt'
    # Quotes and trailing backslash also exercise the native argument encoder.
    $password = 'smoke "quoted" password\'
    Set-Content -LiteralPath $source -Value 'archive smoke payload'
    Set-Content -LiteralPath $additional -Value 'additional payload'

    New-ZipFile -Archive $archive -Files $source -Password $password -Compression Ultra | Out-Host
    if (-not (Test-Path -LiteralPath $archive -PathType Leaf)) { throw 'Archive creation failed' }
    Read-ZipFile -Archive $archive -Password $password | Out-Host
    Add-ZipFileContent -Archive $archive -File $additional -Password $password | Out-Host
    Test-ZipFileContent -Archive $archive -Password $password | Out-Host
    Get-ZipFileContent -Archive $archive -OutDir 'output dir' -Force $true -Password $password | Out-Host
    foreach ($file in @($source, $additional)) {
        $extracted = Join-Path 'output dir' $file
        if (-not (Test-Path -LiteralPath $extracted -PathType Leaf)) { throw "Missing extracted file: $file" }
        if ((Get-Content -LiteralPath $extracted -Raw) -ne (Get-Content -LiteralPath $file -Raw)) {
            throw "Extracted content mismatch: $file"
        }
    }
    Remove-ZipFileContent -Archive $archive -File $additional -Password $password | Out-Host
    Get-ZipFileContent -Archive $archive -OutDir 'after delete' -Force $true -Password $password | Out-Host
    if (Test-Path -LiteralPath (Join-Path 'after delete' $additional)) { throw 'Archive member deletion failed' }
    Test-ZipFileContent -Archive $archive -Password $password | Out-Host
    Write-Host 'PASS: create, list, add, test, extract, delete; spaced paths/password and content roundtrip.'
}
finally {
    if ($pushed) { Pop-Location }
    $env:SEVENZIP_PATH = $savedRuntime
    if ($null -ne $temporaryDirectory -and (Test-Path -LiteralPath $temporaryDirectory)) {
        Remove-Item -LiteralPath $temporaryDirectory -Recurse -Force
    }
}
