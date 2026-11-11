# Load only the maintained source filters; exclude historical examples and out/.
foreach ($name in @('Limit-First', 'Limit-Last', 'Hide-Out', 'Limit-Items', 'Limit-Type', 'Skip-Items')) {
    . (Join-Path $PSScriptRoot "Functions/$name.ps1")
}
. (Join-Path $PSScriptRoot 'Aliases.ps1')
Export-ModuleMember -Function Limit-First, Limit-Last, Hide-Out, Limit-Items, Limit-Type, Skip-Items -Alias skip, wtype, filter-type, where-type, take, first, last, suppress
