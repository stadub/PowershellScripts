$ErrorActionPreference = 'Stop'
$selector = Join-Path $PSScriptRoot '../scripts/ci/Select-CiModules.ps1'
$cases = @{
    'Bookmarks/develop' = 'Bookmarks'
    'Bookmarks/release/latest' = 'Bookmarks'
    'base64tring/develop' = 'Base64String'
    'base64String/release/latest' = 'Base64String'
    '7Zip/develop' = '7zip-Archive'
    '7-Zip/release/1.1' = '7zip-Archive'
    '7-Zip/release/latest' = '7zip-Archive'
    'Currency-Conv/develop' = 'Currency-Conv'
    'Currency-Conv/release/1.5' = 'Currency-Conv'
    'Currency-Conv/release/latest' = 'Currency-Conv'
    'FolderEncoder/develop' = 'FolderEncoder'
    'Shell-Functions/develop' = 'Shell-Functions'
    'Uninstall/develop' = 'Uninstall'
    'Pipe/develop' = 'Pipe'
    'Pipe/release/latest' = 'Pipe'
    'fix/base64-encoding' = 'Base64String'
    'fix/currency-cache-expiry' = 'Currency-Conv'
    'fix/update-check-startup' = 'Bookmarks'
    'fix/7zip-runtime-help' = '7zip-Archive'
}
$all = @('Bookmarks', '7zip-Archive', 'Currency-Conv', 'Base64String', 'Pipe', 'FolderEncoder', 'Shell-Functions', 'Uninstall')
foreach ($branch in @('master', 'ci/github-actions', 'fix/new-feature', 'feature/new-feature',
    'EXportGithub/develop', 'Git-Functions/develop', 'Shared-Functions/develop')) {
    $cases[$branch] = $all
}

# Keep tests from writing matrices into the calling Actions step's outputs.
$savedOutput = $env:GITHUB_OUTPUT
$outputPath = Join-Path ([IO.Path]::GetTempPath()) "ci-selection-$([guid]::NewGuid()).txt"
try {
    $env:GITHUB_OUTPUT = $null
    foreach ($branch in $cases.Keys) {
        $matrix = (& $selector -Branch $branch) | ConvertFrom-Json
        $expected = @(
            foreach ($module in $cases[$branch]) {
                "$module/windows-latest"
                if ($module -ne '7zip-Archive') {
                    "$module/ubuntu-latest"
                    "$module/macos-latest"
                }
            }
        )
        $actual = @($matrix.include | ForEach-Object { "$($_.module)/$($_.os)" })
        if ($actual.Count -ne $expected.Count -or
            @(Compare-Object ($expected | Sort-Object) ($actual | Sort-Object)).Count -gt 0) {
            throw "Wrong module/platform coverage for $branch"
        }
    }
    $env:GITHUB_OUTPUT = $outputPath
    $json = & $selector -Branch 'Pipe/develop'
    $lines = @(Get-Content -LiteralPath $outputPath)
    if ($lines.Count -ne 1 -or $lines[0] -cne "matrix=$json") {
        throw 'Selector did not emit the matrix as a single GitHub output line'
    }
} finally {
    $env:GITHUB_OUTPUT = $savedOutput
    Remove-Item -LiteralPath $outputPath -Force -ErrorAction SilentlyContinue
}
Write-Host "Module branch selection checks passed ($($cases.Count) branches and GitHub output)."
