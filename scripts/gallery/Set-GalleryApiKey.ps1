<#
.SYNOPSIS
Create or rotate the selected module owner's GitHub environment secret.
.DESCRIPTION
Resolves the account and secret name from Get-ReleaseConfig.ps1. GitHub CLI
prompts for the Gallery key and encrypts it locally. This script never receives
the key as a parameter, command argument, environment variable or file.
.EXAMPLE
./scripts/gallery/Set-GalleryApiKey.ps1 -Module Base64String -WhatIf
.EXAMPLE
./scripts/gallery/Set-GalleryApiKey.ps1 -Module Base64String
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Bookmarks', '7zip-Archive', 'Currency-Conv', 'Base64String', 'Pipe', 'FolderEncoder', 'Shell-Functions', 'MiniModules.Uninstall')]
    [string]$Module,
    [ValidatePattern('^[A-Za-z0-9-]+/[A-Za-z0-9_.-]+$')]
    [string]$Repository = 'stadub/PowershellScripts'
)
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
$config = & "$PSScriptRoot/Get-ReleaseConfig.ps1" -Module $Module -RequireGalleryAccount
$environmentName = 'powershell-gallery'
$target = "$Repository / $environmentName / $($config.GallerySecret) (Gallery account $($config.GalleryAccount))"
if (-not $PSCmdlet.ShouldProcess($target, 'Create or update environment secret')) { return }
try { $ghCommand = Get-Command gh -CommandType Application -ErrorAction Stop | Select-Object -First 1 } catch {
    throw 'Install GitHub CLI (gh) and authenticate to github.com before updating the environment secret.'
}
$environmentEndpoint = "repos/$Repository/environments/$environmentName"
$metadata = & $ghCommand.Source api --hostname github.com $environmentEndpoint
if ($LASTEXITCODE -ne 0) { throw 'Cannot read the existing powershell-gallery environment. Check gh authentication and environment-secret permissions.' }
$environment = $metadata | ConvertFrom-Json
if ($environment.name -cne $environmentName -or
    -not $environment.deployment_branch_policy.custom_branch_policies -or
    $environment.deployment_branch_policy.protected_branches) {
    throw 'The existing environment must use the configured master-only deployment branch policy. No settings were changed.'
}
$metadata = & $ghCommand.Source api --hostname github.com "$environmentEndpoint/deployment-branch-policies?per_page=100"
if ($LASTEXITCODE -ne 0) { throw 'Cannot verify environment deployment restrictions. No secret was updated.' }
$policies = $metadata | ConvertFrom-Json
if ($policies.total_count -ne 1 -or @($policies.branch_policies).Count -ne 1 -or
    $policies.branch_policies[0].name -cne 'master' -or $policies.branch_policies[0].type -cne 'branch') {
    throw 'The environment must allow only the master branch. No settings were changed.'
}
Write-Host "Enter the PowerShell Gallery API key for $($config.GalleryAccount) when gh prompts. Target: $target"
# No --body / --env-file / key-valued arguments: gh owns the hidden interactive
# prompt (or its standard input), local encryption and upload. Never print a key.
& $ghCommand.Source secret set $config.GallerySecret --env $environmentName --repo "github.com/$Repository" --app actions
if ($LASTEXITCODE -ne 0) { throw "GitHub CLI could not update $($config.GallerySecret). No deployment was started." }
$metadata = & $ghCommand.Source api --hostname github.com "$environmentEndpoint/secrets/$($config.GallerySecret)"
if ($LASTEXITCODE -ne 0) { throw 'The update command succeeded, but secret metadata verification failed. Check environment settings before retrying.' }
$secret = $metadata | ConvertFrom-Json
if ($secret.name -cne $config.GallerySecret -or -not $secret.updated_at) { throw 'The update command succeeded, but returned secret metadata was unexpected.' }
[pscustomobject]@{
    Repository = $Repository
    Environment = $environmentName
    GalleryAccount = $config.GalleryAccount
    SecretName = $secret.name
    UpdatedAt = $secret.updated_at
}
