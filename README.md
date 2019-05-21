# Powershell Scripts

---------------------

## Donate

The modules are actively maintained during evenings and weekends,
so if you found it usefull you can Buy me a beer/cup of tee😊

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png)](https://www.buymeacoffee.com/dima)

[![Support by Yandex](https://money.yandex.ru/quickpay/button-widget?button-text=15&button-size=m&button-color=orange)](https://money.yandex.ru/to/410014572567962/200)


<!--   By Paypal [![PayPal.me](https://img.shields.io/badge/PayPal-me-blue.svg?maxAge=2592000)](https://www.paypal.me/dima.by)

 -->

If you have any idea or suggestion - please add a github issue and I'll try to implement it as soon as possible😉

<!-- https://www.contributor-covenant.org/version/1/4/code-of-conduct -->

<!-- [Documentation](https://powershellscripts.readthedocs.io/en/latest/) -->

---------------------

## ExportGithub - Export github repo and execute repo script

Allow to download git repo from github unpack it and start config script in one click:

Script arguments:
  Repo - Github repository url(browser url pointed on repo)
  Destanation - Destanation folder where will be unpacked github repo
  InstallScript (optional) - script file to be invoked after repo unpacking

Usage

```powershell
echo "https://github.com/dotnet/core/tree/2.2.103" | ExportGithub  (will download to current directory)

```powershell
ExportGithub "https://github.com/torvalds/linux/archive/master.zip" "C:\Sources\Linux"
```

```powershell
##(Export to specific directory and start script)
ExportGithub "https://github.com/stadub/CmdScripts/archive/master.zip" "C:\CmdScripts\Cmd" "InstallBin.cmd"

```

```powershell
ExportGithub -User electron -Repo electron -Branch chromium-upgrade/73 -Destanation "C:\Sources\Electron"  InstallScript="npm install"

```powershell
ExportGithub -User Microsoft -Repo vscode (Export the main repo to current directory)
```

```powershell
ExportGithub "https://github.com/stadub/CmdScripts/archive/master.zip" "C:\CmdScripts\Cmd" "InstallBin.cmd"
```

Installation

```powershell
Install-Script -Name ExportGithub
```

---------------------

## Uninstall - Uninstall installed Application from system

Allows to uninstall Application from system via commandline

Usage
```powershell
Uninstall-Application "Microsoft*4.5*"
```

Installation
```powershell
Install-Script -Name Uninstall
```

---------------------

## FolderEncode - Encode files from folder for(for example) uploading to cloud

[![https://www.powershellgallery.com/packages/FolderEncoder/2.0.0](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/FolderEncoder/2.0.0)
[![https://github.com/stadub/PowershellScripts/tree/master/FolderEncoder](https://img.shields.io/badge/Bookmarks-repo-blue.svg?style=popout&logo=github)](https://github.com/stadub/PowershellScripts/tree/master/FolderEncoder)

Used as backups encoding solution.
Encoding performed with 7z password protection

Usage

```powershell
Invoke-FolderEncode - Add folder to bookmarks list
  [-DestFolder] <string>
  [-SrcFolder] <string> (Optional)
```

## Usage

```powershell
/>Invoke-FolderEncode -DestFolder "d:\System\" -SrcFolder "c:\windows\System42"
/> cd c:\Windows; Invoke-FolderEncode "d:\bkacup\" #use current folder as src
```

Detailed info : [FolderEncoder](https://github.com/stadub/PowershellScripts/tree/master/FolderEncoder)

## Bookmarsk - Directory bookmarks

[![https://www.powershellgallery.com/packages/Bookmarks/2.0.0](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/Bookmarks/1.1.3)
[![https://github.com/stadub/PowershellScripts/tree/master/Bookmarks](https://img.shields.io/badge/Bookmarks-repo-blue.svg?style=popout&logo=github)](https://github.com/stadub/PowershellScripts/tree/master/Bookmarks)

---------------------

## Commands

```powershell
Add-PSBookmark  - Add folder to bookmarks list
  [-Name] <string>
  [-Path] <string> (Optional)

Remove-PSBookmark - Remove bookmark from list
  [-Bookmark] <string>

Open-PSBookmark - Navigate to bookmark
  [-Bookmark] <string>

Get-PSBookmarks - List bookmarks

Save-PSBookmarkk - Save bookmarks to file
```

## Usage

Add bookmark:

```powershell
/>Add-PSBookmark -Bookmark BookmarkName
```

```powershell
/> $pwd |  Add-PSBookmark -Name "ThisDirectory"
```

Open bookmsrks:

```powershell
/>Open-PSBookmark -Bookmark "Project"
```

```powershell
/>"SourcesDir" |  Open-PSBookmark
```

List bookmsrks:

```powershell
/>Get-PSBookmarks [ bv ]
```

```powershell
.>Get-PSBookmarks [ bl ]
```

Detailed info : [Bookmarsk](https://github.com/stadub/PowershellScripts/tree/master/Bookmarks)

---------------------

# CurrencyConv - Currency converter.

[![https://www.powershellgallery.com/packages/CurrencyConv/1.0.0](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/CurrencyConv/1.0.0)
[![https://github.com/stadub/PowershellScripts/tree/master/CurrencyConv](https://img.shields.io/badge/CurrencyConv-repo-blue.svg?style=popout&logo=github)](https://github.com/stadub/PowershellScripts/tree/master/CurrencyConv)


Exchange value from one currency to another.
Support currency name autocomplete.

## Commands

```powershell
Get-ExchangeRate - Get exchange rate for amount
  [-From] <string>
  [-To] <string> (Optional "USD")
  [-Amount] <integer> (Optional 1.0)

Get-Countries -Countries list with currencies

Get-Currencies - Supported currencies list
```

## Usage

Currency exchange rates:

```powershell
/> Get-ExchangeRate USD BYN 5
```

```powershell
/> Get-ExchangeRate -From USD -To BYN 5
```

```powershell
/> Get-ExchangeRate -Base PHP -Result EUR -Amount 5
```

```powershell
/> ([PSCustomObject]@{From="BYN"; To="USD";Value=4}) |  Get-ExchangeRate
```

```powershell
/> ([PSCustomObject]@{Base="PHP"; Amount=400})|  Get-ExchangeRate
```

List supported countries:

```powershell
/> Get-Countries
```

List supported currencies:

```powershell
/> Get-Currencies
```

---------------------

## Shell-Functions -some function wrappers to make a bridge with bash and powershell functions


Functions and filters which emulate cmd/bash functions absent(or have different logic) in powershell

Commands:

Get-SearchAndPrint - Text serach wrapper with more grep behaviour.

Split-String - Split string and return only the selected part.

Initialize-VisualStudioEnvieronment - Set Visual studio specific env variables.

Get-CmdletAlias - Search for alias by name.

New-FileSystemLink - Create file system link or junction.


### Aliases created by script:

Set-Alias grep Get-SearchAndPrint

Set-Alias cut Split-String

Set-Alias VsVars32 Initialize-VisualStudioEnvieronment

Set-Alias ga Get-CmdletAlias

Set-Alias fl New-FileSystemLink


Usage:

Text search:

```powershell
>./ ls | Get-SearchAndPrint "file"
>./ ls | grep "file"
```

Split string:

```powershell
>./ "aaa bbb" | Split-String " "
>./ "aaa bbb" | cut " "
```

Set Visual studio Envieronment:

```powershell
>./Initialize-VisualStudioEnvieronment
>./Initialize-VisualStudioEnvieronment "12.0"
>./vsVars32 "12.0"
```

Search powershell alias:

```powershell
>./Get-CmdletAlias "di"
>./ga "di"
```

Create symbolic/hard link or directory junction point:

```powershell
>./New-FileSystemLink -Source "C:\windows" -Destanation "D:\Linux" Junction
>./New-FileSystemLink "C:\data.dat" "${env:appData}/file.dat"
>./New-FileSystemLink -s "C:\data.dat" -dest "${env:appData}/file.dat" Symbolic
>./New-FileSystemLink "C:\sources.dat" "d:/replicate" Hard
```