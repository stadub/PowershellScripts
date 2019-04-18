# Powershell Scripts

---------------------

## ExportGithub - Export github repo and execute repo script

---------------------

Allow to download git repo from github unpack it and start config script in one click:

Script arguments:
  Repo - Github repository url(browser url pointed on repo)
  Destanation - Destanation folder where will be unpacked github repo
  InstallScript (optional) - script file to be invoked after repo unpacking

Usage

>echo "https://github.com/dotnet/core/tree/2.2.103" | ExportGithub  (will download to current directory)

>./ExportGithub "https://github.com/torvalds/linux/archive/master.zip" "C:\Sources\Linux" 

>./ExportGithub "https://github.com/stadub/CmdScripts/archive/master.zip" "C:\CmdScripts\Cmd" "InstallBin.cmd" 
(Export to specific directory and start script)

>./ExportGithub -User electron -Repo electron -Branch chromium-upgrade/73 -Destanation "C:\Sources\Electron"  InstallScript="npm install"

>./ExportGithub -User Microsoft -Repo vscode (Export the main repo to current directory)

>./ExportGithub "https://github.com/stadub/CmdScripts/archive/master.zip" "C:\CmdScripts\Cmd" "InstallBin.cmd"

Installation
>Install-Script -Name ExportGithub

## Uninstall - Uninstall installed Application from system

---------------------

Allows to uninstall Application from system via commandline

Usage
>./Uninstall-Application "Microsoft*4.5*"

Installation
>Install-Script -Name Uninstall

## EncodeVia7z -   Encode files from folder for(for example) uploading to cloud.


[PowerShell Gallery](https://www.powershellgallery.com/packages/FolderEncoder/1.0.0)

[GitHub Folder](https://github.com/stadub/PowershellScripts/tree/master/FolderEncoder)

---------------------

Used as backups encoding solution.
Encoding performed with 7z password protection

Script arguments:
  SrcFolder (optional) - Folder to be encoded
  DestFolder - Destanation folder where encoded files be created

Usage
>./EncodeVia7z "c:\windows\System42" "d:\System"

Full info : [FolderEncoder](https://github.com/stadub/PowershellScripts/tree/master/FolderEncoder)

## Bookmarsk - Directory bookmarks

[PowerShell Gallery](https://www.powershellgallery.com/packages/Bookmarks/1.1.1)

[GitHub Folder](https://github.com/stadub/PowershellScripts/tree/master/Bookmarks)

---------------------

### Commands

  Add-PSBookmark - Add folder to bookmarks list

  Remove-PSBookmarks - Remove bookmark from list
  
  Restore-PSBookmarks - Reload bookmarks list

  Open-PSBookmark - Navigate to bookmark

  Save-PSBookmarks - Save bookmarks to file

  Get-PSBookmarks - List bookmarks

### Usage

Add bookmark:
>./Add-PSBookmark [ ba ]  BookmarkName (Opt)Directory

>$pwd |  Add-PSBookmark -Name "ThisDirectory"

Open bookmsrks:
>./Open-PSBookmark [ bo ]  -Bookmark "Project"

>"SourcesDir" |  Open-PSBookmark [ bo ]

List bookmsrks:
>./Get-PSBookmarks [ bv ]

>./Get-PSBookmarks [ bl ]

Full info : [Bookmarsk](https://github.com/stadub/PowershellScripts/tree/master/Bookmarks)

## CurrencyConv - Currency converter.

---------------------

Exchange value from one currency to another.
Support currency name autocomplete.

Get-ExchangeRate - Convert selected amount from one currency to another

Script arguments:
   From[Base] - base currency to convert
   To[Result] {Default - USD} - the result value currency
   Amount[Value][Count] - amount to be converted
           $to,

Get-Countries - Get supported currency list by country
Get-Currencies - Get supported currency list

### Aliases created by script:

Set-Alias gxc Get-Currencies
Set-Alias xe Get-ExchangeRate

Usage:
List supported countries:
>./Get-Countries

List supported currencies:
>./Get-Currencies

Convert amount:
>./Get-ExchangeRate USD BYN 5
>./Get-ExchangeRate -From USD -To BYN 5
>./Get-ExchangeRate -Base USD -Result BYN -Amount 5

>([PSCustomObject]@{From="BYN"; To="USD";Value=4})|  Get-ExchangeRate

>([PSCustomObject]@{Base="PHP"; Amount=400})|  Get-ExchangeRate


## Shell-Functions -some function wrappers to make a bridge with bash and powershell functions

---------------------

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
>./ ls | Get-SearchAndPrint "file"
>./ ls | grep "file"

Split string:
>./ "aaa bbb" | Split-String " "
>./ "aaa bbb" | cut " "

Set Visual studio Envieronment:
>./Initialize-VisualStudioEnvieronment
>./Initialize-VisualStudioEnvieronment "12.0"
>./vsVars32 "12.0"

Search powershell alias:
>./Get-CmdletAlias "di"
>./ga "di"

Create symbolic/hard link or directory junction point:
>./New-FileSystemLink -Source "C:\windows" -Destanation "D:\Linux" Junction
>./New-FileSystemLink "C:\data.dat" "${env:appData}/file.dat"
>./New-FileSystemLink -s "C:\data.dat" -dest "${env:appData}/file.dat" Symbolic
>./New-FileSystemLink "C:\sources.dat" "d:/replicate" Hard