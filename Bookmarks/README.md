# Bookmarsk - Directory bookmarks

[PowerShell Gallery](https://www.powershellgallery.com/packages/Bookmarks/1.1.2)

---------------------

<p align="center"><img src="/Assets/demo.gif?raw=true"/></p>

## Commands

  Add-PSBookmark - Add folder to bookmarks list

  Remove-PSBookmarks - Remove bookmark from list
  
  Restore-PSBookmarks - Reload bookmarks list

  Open-PSBookmark - Navigate to bookmark

  Save-PSBookmarks - Save bookmarks to file

  Get-PSBookmarks - List bookmarks

## Aliases created by script

- ba Add-PSBookmark
- br Remove-PSBookmark
- bo Open-PSBookmark
- bv Get-PSBookmarks
- bl Get-PSBookmarks

## Usage

Add bookmark:
>./Add-PSBookmark [ ba ]  BookmarkName (Opt)Directory

>$pwd |  Add-PSBookmark -Name "ThisDirectory"

Open bookmsrks:
>./Open-PSBookmark [ bo ]  -Bookmark "Project"

>"SourcesDir" |  Open-PSBookmark [ bo ]

List bookmsrks:
>./Get-PSBookmarks [ bv ]

>./Get-PSBookmarks [ bl ]
