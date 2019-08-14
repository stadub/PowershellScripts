# Bookmarks - Directory bookmarks

[![PowerShell 3](https://Stadub-Gh.visualstudio.com/PowershellScripts/_apis/build/status/Bookmarks?branchName=master)](https://Stadub-Gh.visualstudio.com/PowershellScripts/_build/latest?definitionId=3?branchName=master)
[![PowerShell 4, 5 & Core on Windows build](https://ci.appveyor.com/api/projects/status/7tmg8wy30ipanjsd?svg=true)](https://ci.appveyor.com/project/stadub/powershellscripts)
[![Linux & MacOS build](https://img.shields.io/travis/stadub/PowershellScripts/master.svg?label=linux/macos+build)](https://travis-ci.org/stadub/PowershellScripts)
[![latest version](https://img.shields.io/powershellgallery/v/Bookmarks.svg?label=latest+version)](https://www.powershellgallery.com/packages/Bookmarks/)
[![downloads](https://img.shields.io/powershellgallery/dt/Bookmarks.svg?label=downloads)](https://www.powershellgallery.com/packages/Bookmarks)

<!-- [Documentation](https://powershellscripts.readthedocs.io/en/latest/) -->

![ConsoleDemo](https://raw.githubusercontent.com/stadub/PowershellScripts/master/Bookmarks/Assets/demo.gif)

## Instalation

Powershell Gallery:

[![https://www.powershellgallery.com/packages/Bookmarks/](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/Bookmarks/)

`PowerShellGet` Installation :

```powershell
Install-Module -Name Bookmarks
```

Direct download instalation:

```powershell
iex ('$module="Bookmarks"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/stadub/PowershellScripts/master/install.ps1'))
```

Module import:

```powershell
Import-Module Bookmarks
```

# Commands


```powershell
Add-PSBookmark  - Add folder to the bookmarks list
  [-Name] <string>
  [-Path] <string> (Optional)

Remove-PSBookmark - Remove bookmark from the list
  [-Bookmark] <string>

Open-PSBookmark - Navigate to bookmark
  [-Bookmark] <string>

Get-PSBookmarks - List bookmarks

Save-PSBookmarkk - Save bookmarks to file

Remove-AllPSBookmarks - Clear bookmarks list

Update-PSBookmark  - Update folder location in the bookmarks list
  [-Name] <string>
  [-Path] <string> (Optional)
```

## Aliases

| Cmdlet                  | Alias  |
| ------------------------|:------:|
| Add-PSBookmark          | ba     |
| Remove-PSBookmark       | br     |
| Open-PSBookmark         | bo     |
| Get-PSBookmarks         | bv | bl|
| Remove-AllPSBookmarks   | bcl    |

## Usage

Add bookmark:

```powershell
/>Add-PSBookmark -Bookmark BookmarkName
```

```powershell
/> $pwd |  Add-PSBookmark -Name "ThisDirectory"
```

Open bookmarks:

```powershell
/>Open-PSBookmark -Bookmark "Project"
```

```powershell
/>"SourcesDir" |  Open-PSBookmark
```

List bookmarks:

```powershell
/>Get-PSBookmarks [ bv ]
```

```powershell
.>Get-PSBookmarks [ bl ]
```

Clear bookmarks:

```powershell
/>Remove-AllPSBookmarks [ bcl ]
```

## Changelog

### [v1.2.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.2.2)

* Tests added
* Added function `Remove-AllPSBookmarks`
* Fix bookmarks collection access


### [v1.1.3](https://github.com/stadub/PowershellScripts/releases/tag/v0.2.0)

* Add versioning to Markdown page.
* Move Assets to an individual folder.
* Fix psget package - remove extra files.

### [v1.1.2](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Separate functions and aliases.

### [v1.1.1](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Move module to individual folder.
* Add module methods description.

### [v1.1.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Added parameters pipeline for `Add-PSBookmark` and `Open-PSBookmark`

>$pwd |  Add-PSBookmark -Name "ThisDirectory"
>"SourcesDir" |  Open-PSBookmark [ bo ]


### [v1.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Added command aliases.

### [v0.9](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0) Aug 18, 2015

* Added CRUD Bookmark commands:

```powershell
Add-PSBookmark  - Add folder to the bookmarks list
  [-Name] <string>
  [-Path] <string> (Optional)

Remove-PSBookmark - Remove bookmark from the list
  [-Bookmark] <string>

Open-PSBookmark - Navigate to bookmark
  [-Bookmark] <string>

Get-PSBookmarks - List bookmarks

Save-PSBookmarkk - Save bookmarks to file

```

## Donate

The modules are created and actively maintained during evenings and weekends for my own needs.
If it's useful for you too, that's great. I don't demand anything in return.

However, if you like it and feel the urge to give something back,
a coffee or a beer is always appreciated. Thank you very much in advance.

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png)](https://www.buymeacoffee.com/dima)
[![Support by Yandex](https://raw.githubusercontent.com/GitStatic/Resources/master/yaMoney.png)](https://money.yandex.ru/to/410014572567962/200)

<!--   By Paypal [![PayPal.me](https://img.shields.io/badge/PayPal-me-blue.svg?maxAge=2592000)](https://www.paypal.me/dima.by)
 -->

If you have any idea or suggestion - please add a github issue.

<!-- https://www.contributor-covenant.org/version/1/4/code-of-conduct -->