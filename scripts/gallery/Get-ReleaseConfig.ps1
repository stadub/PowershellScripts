[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Bookmarks', '7zip-Archive', 'Currency-Conv', 'Base64String', 'Pipe')]
    [string]$Module
)

# Package branches are deliberately distinct from feature/PR development bases.
# Do not substitute master or dynamically accept arbitrary branch names here.
$configs = @{
    Bookmarks = @{
        ReleaseBranch = 'Bookmarks/release/latest'
        PackagePath = 'Bookmarks/out'
        Manifest = 'Bookmarks.psd1'
        GalleryAccount = 'Stadub'
        GallerySecret = 'PSGALLERY_API_KEY'
    }
    '7zip-Archive' = @{
        ReleaseBranch = '7-Zip/release/1.1'
        PackagePath = '7Zip'
        Manifest = '7zip-Archive.psd1'
        GalleryAccount = 'Stadub'
        GallerySecret = 'PSGALLERY_API_KEY'
    }
    'Currency-Conv' = @{
        ReleaseBranch = 'Currency-Conv/release/1.5'
        PackagePath = 'Currency-Conv'
        Manifest = 'Currency-Conv.psd1'
        GalleryAccount = 'Stadub'
        GallerySecret = 'PSGALLERY_API_KEY'
    }
    Base64String = @{
        ReleaseBranch = 'base64String/release/latest'
        PackagePath = 'Shared-Functions/Base64String/out'
        Manifest = 'Base64String.psd1'
        GalleryAccount = 'MiniModules'
        GallerySecret = 'PSGALLERY_API_KEY'
    }
    Pipe = @{
        ReleaseBranch = 'Pipe/release/latest'
        PackagePath = 'Shared-Functions/Pipe/out'
        Manifest = 'Pipe.psd1'
        GalleryAccount = 'MiniModules'
        GallerySecret = 'PSGALLERY_API_KEY'
    }
}
[pscustomobject]$configs[$Module]
