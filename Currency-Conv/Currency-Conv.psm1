. $PSScriptRoot\Shared-Functions.ps1

. $PSScriptRoot\Functions.ps1

CurrencyCheckPsGalleryUpdate "Currency-Conv" "1.5.0"

_Initalize

Export-ModuleMember -Function Get-Currencies
Export-ModuleMember -Function Get-ExchangeRate
Export-ModuleMember -Function Get-Countries
Export-ModuleMember -Function Remove-CurrencyApiKey
. $PSScriptRoot\Aliases.ps1