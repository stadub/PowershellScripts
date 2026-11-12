# Real local Git fixtures: no network, credentials, releases or Gallery mutations.
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
$resolver = Join-Path $PSScriptRoot '../scripts/gallery/Resolve-ReleaseSnapshot.ps1'
$gitExe = (Get-Command git -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
$fixture = Join-Path ([IO.Path]::GetTempPath()) "release-selection-$([guid]::NewGuid())"
$savedOutput = $env:GITHUB_OUTPUT
$savedSummary = $env:GITHUB_STEP_SUMMARY
$exitCodeVariable = Get-Variable LASTEXITCODE -Scope Global -ErrorAction SilentlyContinue
$savedExitCode = if ($null -ne $exitCodeVariable) { $exitCodeVariable.Value } else { 0 }
function Invoke-FixtureGit {
    # A plain function preserves native flags such as -d; advanced functions
    # would bind that flag to PowerShell's common Debug parameter.
    & $gitExe @args
    if ($LASTEXITCODE -ne 0) { throw "Fixture Git command failed: $($args[0])" }
}
function Assert-SelectionFailure([scriptblock]$Action, [string]$Pattern) {
    $caught = $false
    try { & $Action | Out-Null } catch {
        $caught = $true
        if ($_.Exception.Message -notlike $Pattern) { throw }
    }
    if (-not $caught) { throw "Expected selection failure: $Pattern" }
}
try {
    $env:GITHUB_OUTPUT = ''
    $env:GITHUB_STEP_SUMMARY = ''
    $seed = Join-Path $fixture 'seed'
    $remote = Join-Path $fixture 'remote.git'
    $hooks = (New-Item (Join-Path $fixture 'empty-hooks') -ItemType Directory -Force).FullName
    Invoke-FixtureGit init --bare --quiet $remote
    Invoke-FixtureGit init --quiet -b fixture $seed
    Invoke-FixtureGit -C $seed config user.name 'Offline fixture'
    Invoke-FixtureGit -C $seed config user.email 'fixture@example.invalid'
    'reviewed A' | Set-Content (Join-Path $seed 'snapshot.txt')
    Invoke-FixtureGit -C $seed add snapshot.txt
    Invoke-FixtureGit -C $seed -c commit.gpgsign=false -c "core.hooksPath=$hooks" commit --quiet -m 'reviewed A'
    $shaA = Invoke-FixtureGit -C $seed rev-parse HEAD
    Invoke-FixtureGit -C $seed remote add origin $remote
    Invoke-FixtureGit -C $seed -c "core.hooksPath=$hooks" push --quiet origin HEAD:refs/heads/fixture
    $modules = @('Bookmarks','7zip-Archive','Currency-Conv','Base64String','Pipe')
    foreach ($name in $modules) {
        $config = & "$PSScriptRoot/../scripts/gallery/Get-ReleaseConfig.ps1" -Module $name
        Invoke-FixtureGit --git-dir=$remote update-ref "refs/heads/$($config.ReleaseBranch)" $shaA
        $selected = & $resolver -Module $name -Version 1.3.0 -RepositoryRoot $seed
        if ($selected.SourceSha -cne $shaA -or $selected.ReleaseBranch -cne $config.ReleaseBranch -or $selected.Module -cne $name) {
            throw "Incorrect reviewed source selection for $name"
        }
    }
    $output = Join-Path $fixture 'output.txt'
    $summary = Join-Path $fixture 'summary.txt'
    $env:GITHUB_OUTPUT = $output
    $env:GITHUB_STEP_SUMMARY = $summary
    $pinned = & $resolver -Module Base64String -Version 1.3.0 -RepositoryRoot $seed
    if (@(Get-Content $output).Count -ne 1 -or (Get-Content $output) -cne "sha=$shaA") { throw 'Malformed or duplicate SHA output' }
    if ((Get-Content $summary -Raw) -notlike "*Base64String 1.3.0*base64String/release/latest*$shaA*") { throw 'Snapshot evidence missing from run summary' }
    $env:GITHUB_OUTPUT = ''
    $env:GITHUB_STEP_SUMMARY = ''
    'reviewed B' | Set-Content (Join-Path $seed 'snapshot.txt')
    Invoke-FixtureGit -C $seed add snapshot.txt
    Invoke-FixtureGit -C $seed -c commit.gpgsign=false -c "core.hooksPath=$hooks" commit --quiet -m 'reviewed B'
    $shaB = Invoke-FixtureGit -C $seed rev-parse HEAD
    Invoke-FixtureGit -C $seed -c "core.hooksPath=$hooks" push --quiet origin HEAD:refs/heads/base64String/release/latest
    if ($pinned.SourceSha -cne $shaA) { throw 'Pinned snapshot changed when its branch advanced' }
    $next = & $resolver -Module Base64String -Version 1.3.0 -RepositoryRoot $seed
    if ($next.SourceSha -cne $shaB) { throw 'A new selection did not resolve the current reviewed tip' }
    Invoke-FixtureGit --git-dir=$remote update-ref -d refs/heads/7-Zip/release/1.1
    Assert-SelectionFailure { & $resolver -Module 7zip-Archive -Version 1.3.0 -RepositoryRoot $seed } '*Cannot resolve the reviewed release branch*'
    Assert-SelectionFailure { & $resolver -Module Base64String -Version '1.3.0; echo injected' -RepositoryRoot $seed } '*Version*'
    Assert-SelectionFailure { & $resolver -Module Uninstall -Version 1.3.0 -RepositoryRoot $seed } '*ValidateSet*'
    Invoke-FixtureGit -C $seed remote remove origin
    Assert-SelectionFailure { & $resolver -Module Base64String -Version 1.3.0 -RepositoryRoot $seed } '*Cannot resolve the reviewed release branch*'
    Write-Host 'Release selection passed: five configured sources, one immutable SHA, advancing branches, summary evidence, missing refs/origin and invalid inputs.'
} finally {
    $env:GITHUB_OUTPUT = $savedOutput
    $env:GITHUB_STEP_SUMMARY = $savedSummary
    Remove-Item $fixture -Recurse -Force -ErrorAction SilentlyContinue
    # Expected failing native-Git cases must not make Actions' shell wrapper
    # report failure after all assertions passed.
    $global:LASTEXITCODE = $savedExitCode
}
