[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Bookmarks','7zip-Archive','Currency-Conv','Base64String','Pipe','FolderEncoder','Shell-Functions','Uninstall')]
    [string]$Module
)
$configs = @{
    Bookmarks = @{ SourcePath='Bookmarks'; DevelopmentBranch='Bookmarks/develop' }
    '7zip-Archive' = @{ SourcePath='7Zip'; DevelopmentBranch='7Zip/develop' }
    'Currency-Conv' = @{ SourcePath='Currency-Conv'; DevelopmentBranch='Currency-Conv/develop' }
    Base64String = @{ SourcePath='Shared-Functions/Base64String'; DevelopmentBranch='base64tring/develop' }
    Pipe = @{ SourcePath='Shared-Functions/Pipe'; DevelopmentBranch='Pipe/develop' }
    FolderEncoder = @{ SourcePath='FolderEncoder'; DevelopmentBranch='FolderEncoder/develop' }
    'Shell-Functions' = @{ SourcePath='Shell-Functions'; DevelopmentBranch='Shell-Functions/develop' }
    Uninstall = @{ SourcePath='.'; DevelopmentBranch='Uninstall/develop' }
}
[pscustomobject]$configs[$Module]
