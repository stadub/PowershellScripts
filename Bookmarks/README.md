# Bookmarsk - Directory bookmarks


[PowerShell Gallery](https://www.powershellgallery.com/packages/Bookmarks/1.1.3) [![https://www.powershellgallery.com/packages/Bookmarks/1.1.3](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg)](https://www.powershellgallery.com/packages/Bookmarks/1.1.3)

---------------------

![ConsoleDemo](https://raw.githubusercontent.com/stadub/PowershellScripts/master/Bookmarks/Assets/demo.gif)

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

## Aliases


| Cmdlet             | Alias    |
| -------------------|:--------:|
| `Add-PSBookmark`   | `ba`     |
| `Remove-PSBookmark`| `br`     |
| `Open-PSBookmark`  | `bo`     |
| `Get-PSBookmarks`  | `bv` `bl`|

## Usage

Add bookmark:
`/>Add-PSBookmark -Bookmark BookmarkName`
`/>$pwd |  Add-PSBookmark -Name "ThisDirectory"`

Open bookmsrks:
`/>./Open-PSBookmark -Bookmark "Project"`

`/>"SourcesDir" |  Open-PSBookmark`

List bookmsrks:
`>./Get-PSBookmarks [ bv ]`

`>./Get-PSBookmarks [ bl ]`

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
