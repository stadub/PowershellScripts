[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Bookmarks', '7zip-Archive', 'Currency-Conv', 'Base64String', 'Pipe')]
    [string]$Module
)

# Package branches are deliberately distinct from feature/PR development bases.
# Do not substitute master or dynamically accept arbitrary branch names here.
# These are literal reviewed Git branch names, separate from GitHub Releases
# /releases/latest URL alias. Never resolve a package from development as fallback.
# All configured packages use <module source directory>/out within the snapshot.
# PackagePath is relative to that immutable snapshot, not the runner or branch name.
# GallerySecret is a GitHub environment SECRET NAME, never the API key value.
$configs = @{
    Bookmarks = @{
        ReleaseBranch = 'Bookmarks/release/latest'
        PackagePath = 'Bookmarks/out'
        Manifest = 'Bookmarks.psd1'
        GalleryAccount = 'Stadub'
    }
    '7zip-Archive' = @{
        ReleaseBranch = '7-Zip/release/1.1'
        PackagePath = '7Zip/out'
        Manifest = '7zip-Archive.psd1'
        GalleryAccount = 'Stadub'
    }
    'Currency-Conv' = @{
        ReleaseBranch = 'Currency-Conv/release/1.5'
        PackagePath = 'Currency-Conv/out'
        Manifest = 'Currency-Conv.psd1'
        GalleryAccount = 'Stadub'
    }
    Base64String = @{
        ReleaseBranch = 'base64String/release/latest'
        PackagePath = 'Shared-Functions/Base64String/out'
        Manifest = 'Base64String.psd1'
        GalleryAccount = 'MiniModules'
    }
    Pipe = @{
        ReleaseBranch = 'Pipe/release/latest'
        PackagePath = 'Shared-Functions/Pipe/out'
        Manifest = 'Pipe.psd1'
        GalleryAccount = 'MiniModules'
    }
}
# Gallery usernames are public configuration. API key values live only in the
# protected environment; module selection never accepts an account/secret input.
$accountSecrets = @{
    Stadub = 'PSGALLERY_API_KEY_STADUB'
    MiniModules = 'PSGALLERY_API_KEY_MINIMODULES'
}
$config = $configs[$Module]
if (-not $accountSecrets.ContainsKey($config.GalleryAccount)) {
    throw 'No credential route for the configured Gallery account'
}
$config.GallerySecret = $accountSecrets[$config.GalleryAccount]
[pscustomobject]$config
