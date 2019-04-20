# ExportGithub - Export github repo and execute repo script

---------------------

Allow to download git repo from github unpack it and start config script in one click:


[![https://www.powershellgallery.com/packages/Bookmarks/1.1.3](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/Bookmarks/1.1.3)

---------------------

![ConsoleDemo](https://raw.githubusercontent.com/stadub/PowershellScripts/master/Bookmarks/Assets/demo.gif)

## Script arguments

```powershell
Export-Github  - Add folder to bookmarks list
  [-Repo] (Optional) <string> Github repository url(browser url pointed on repo)
  [-Destanation]  <string> Destanation folder where will be unpacked github repo
  [-InstallScript]  (Optional)  <string> Script file to be invoked after repo unpacking

```

## Usage

```powershell
/>echo "https://github.com/dotnet/core/tree/2.2.103" | ExportGithub  (will download to current directory)
```

```powershell
/>ExportGithub "https://github.com/torvalds/linux/archive/master.zip" "C:\Sources\Linux"
```

Export to specific directory and start script

```powershell
/>ExportGithub "https://github.com/stadub/CmdScripts/archive/master.zip" "C:\CmdScripts\Cmd" "InstallBin.cmd"
```

Export the specific branch and start script

```powershell
/>ExportGithub -User electron -Repo electron -Branch chromium-upgrade/73 -Destanation "C:\Sources\Electron"  InstallScript="npm install"
```

Export the main repo to current directory

```powershell
/>ExportGithub -User Microsoft -Repo vscode
```

## Changelog

### [v1.1.3](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Add versioning to Markdown page.
* Move Assets to individual folder.
* Fix psget package - remove extra files.

### [v1.1.2](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Separate functions and aliases.

### [v1.1.1](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Move module to individual foler.
* Add module methods description.

### [v1.1.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Added parameters pipeline for `Add-PSBookmark` and `Open-PSBookmark`

>$pwd |  Add-PSBookmark -Name "ThisDirectory"
>"SourcesDir" |  Open-PSBookmark [ bo ]


### [v1.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Added command aliases.

### [v0.9](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Added CRUD Bookmark commands:

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

## Motivation

Hi, I written this module(and ther from repo) for my own usage.
But if you found it usefull you can Buy me a beer/cup of tee😊

<!--   By Paypal [![PayPal.me](https://img.shields.io/badge/PayPal-me-blue.svg?maxAge=2592000)](https://www.paypal.me/dima.by)

 <> Or 
 -->
[![Yandex Money](https://money.yandex.ru/i/ym2015_icon.png)](https://money.yandex.ru/to/410014572567962)

<!-- Yandex Money (https://money.yandex.ru/i/ym2015_icon.png)(https://money.yandex.ru/to/410014572567962) -->

If you have any idea or suggestion - please add a github issue and I'll try to implement it😉
