[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Bookmarks', '7zip-Archive', 'Currency-Conv', 'Base64String', 'Pipe', 'FolderEncoder', 'Shell-Functions', 'MiniModules.Uninstall')]
    [string]$Module,
    [Parameter(Mandatory)]
    [ValidatePattern('^\d+\.\d+\.\d+(\.\d+)?$')]
    [string]$Version,
    [Parameter(Mandatory)]
    [string]$RepositoryRoot
)
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
$root = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$config = & "$PSScriptRoot/Get-ReleaseConfig.ps1" -Module $Module
$ref = "refs/heads/$($config.ReleaseBranch)"
# Resolve exactly once. Every checkout, evidence record and mutation in the run
# must consume this SHA, never the moving branch name or /releases/latest alias.
$remote = @(& git -C $root ls-remote --exit-code origin $ref)
if ($LASTEXITCODE -ne 0 -or $remote.Count -ne 1 -or
    $remote[0] -cnotmatch ('^([0-9a-f]{40})\s+' + [regex]::Escape($ref) + '$')) {
    throw "Cannot resolve the reviewed release branch for ${Module}: $($config.ReleaseBranch). No development or other-ref fallback is allowed."
}
$sha = $Matches[1]
if ($env:GITHUB_OUTPUT) {
    "sha=$sha" >> $env:GITHUB_OUTPUT
}
if ($env:GITHUB_STEP_SUMMARY) {
    "Reviewed release snapshot: $Module $Version | $($config.ReleaseBranch) | $sha" >> $env:GITHUB_STEP_SUMMARY
    "Gallery version reference: latest listed $($config.LatestGalleryVersion); highest registered $($config.HighestRegisteredVersion); planned $($config.PlannedVersion) ($($config.VersionChange)). $($config.VersionPlanStatus)" >> $env:GITHUB_STEP_SUMMARY
}
[pscustomobject]@{
    Module = $Module
    Version = $Version
    ReleaseBranch = $config.ReleaseBranch
    SourceSha = $sha
}
