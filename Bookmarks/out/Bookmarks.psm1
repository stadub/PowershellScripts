. $PSScriptRoot\Shared-Functions.ps1

. $PSScriptRoot\Functions.ps1

CheckPsGalleryUpdate Bookmarks "2.2.0"

_Initalize

Export-ModuleMember -Function Add-PSBookmark
Export-ModuleMember -Function Remove-PSBookmark
Export-ModuleMember -Function Remove-AllPSBookmarks
Export-ModuleMember -Function Open-PSBookmark
Export-ModuleMember -Function Restore-PSBookmarks
Export-ModuleMember -Function Save-PSBookmarks
Export-ModuleMember -Function Get-PSBookmarks
Export-ModuleMember -Function Update-PSBookmark 
. $PSScriptRoot\Aliases.ps1