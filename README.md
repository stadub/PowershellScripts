# Powershell Scripts

### EncodeVia7z - Encode files from folder to upload to cloud.
---------------------

Encoding performed by 7z util

Usage
>./Encode Via 7z.ps1 Source Folder Dest Folder

There is no decoding script. Because currently used only for backups and(thank goodness) there was no necessity to decode it.
To decrypt manually:

1. Concat value from .master Key and add ':' to beginning and by using resulting key extract .keys file from .keys.7z

2. Find appropriate row in .key for file that should be decoded.

3. Concat first row from .masterKey with first row from .key file and ':' to beginning

4. Use key from previous step as 7z password for decode file

### Bookmarsk - Create directory bookmark 
Extended version of code from stackowerflow http://stackoverflow.com/questions/7984974/directory-bookmarks-in-powershell
---------------------
Commands:
Set-PSBookmark  [ bs ]
Get-PSBookmark  [ bg ]
Get-PSBookmarks [ bl ]