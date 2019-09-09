. $PSScriptRoot\Shared-Functions.ps1

. $PSScriptRoot\Functions.ps1

szCheckPsGalleryUpdate 7Zip "1.1.0"

_Initalize


Export-ModuleMember -Function: Read-ZipFile
Export-ModuleMember -Function: Add-ZipFileContent
Export-ModuleMember -Function: Remove-ZipFileContent
Export-ModuleMember -Function: Test-ZipFileContent
Export-ModuleMember -Function: Get-ZipFileContent
Export-ModuleMember -Function: New-ZipFile


. $PSScriptRoot\Aliases.ps1