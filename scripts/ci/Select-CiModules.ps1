[CmdletBinding()]
param([Parameter(Mandatory)][string]$Branch)

$ErrorActionPreference = 'Stop'
$modules = switch -Regex ($Branch) {
    '^Bookmarks/|^fix/update-check-startup$' { 'Bookmarks'; break }
    '^(7Zip|7-Zip)/|^fix/7zip-runtime-help$' { '7zip-Archive'; break }
    '^Currency-Conv/|^fix/currency-cache-expiry$' { 'Currency-Conv'; break }
    '^base64(tring|String)/|^fix/base64-encoding$' { 'Base64String'; break }
    '^Pipe/' { 'Pipe'; break }
    default { 'Bookmarks', '7zip-Archive', 'Currency-Conv', 'Base64String', 'Pipe' }
}
$entries = @(
    foreach ($module in $modules) {
        # The legacy 7Zip suite exercises Windows-specific runtime installation.
        $platforms = if ($module -eq '7zip-Archive') {
            @('windows-latest')
        } else {
            @('windows-latest', 'ubuntu-latest', 'macos-latest')
        }
        foreach ($platform in $platforms) {
            @{ module = $module; os = $platform }
        }
    }
)
$matrix = @{ include = $entries } | ConvertTo-Json -Depth 4 -Compress
if ($env:GITHUB_OUTPUT) { "matrix=$matrix" >> $env:GITHUB_OUTPUT }
$matrix
