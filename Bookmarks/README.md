# Powershell Scripts

### Bookmarsk - Create directory bookmark script

---------------------

Commands:
  Add-PSBookmark - Add folder to bookmarks list
  Remove-PSBookmarks - Remove bookmark from list

  Restore-PSBookmarks - Reload bookmarks list
  Open-PSBookmark - Navigate to bookmark
  Save-PSBookmarks - Save bookmarks to file
  Get-PSBookmarks - List bookmarks

#### Aliases created by script:

Set-Alias ba Add-PSBookmark
Set-Alias br Remove-PSBookmark
Set-Alias bo Open-PSBookmark
Set-Alias bv Get-PSBookmarks
Set-Alias bl Get-PSBookmarks


Usage:
Add bookmark
>./Add-PSBookmark [ ba ]  BookmarkName (Opt)Directory 

>$pwd |  Add-PSBookmark -Name "ThisDirectory"

Open bookmsrks:
>./Open-PSBookmark [ bo ]  -Bookmark "Project" 

>"SourcesDir" |  Open-PSBookmark [ bo ]

List bookmsrks:
>./Get-PSBookmarks [ bv ] 

>./Get-PSBookmarks [ bl ]
