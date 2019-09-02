. $PSScriptRoot\Shared-Functions.ps1

. $PSScriptRoot\Functions.ps1

CheckPsGalleryUpdate "Currency-Conv" "1.0.0"

_Initalize

Export-ModuleMember -Function Get-Currencies
Export-ModuleMember -Function GetImpo-ExchangeRate
Export-ModuleMember -Function Get-Countries
. $PSScriptRoot\Aliases.ps1