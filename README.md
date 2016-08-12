# Powershell Scripts

### Uninstall - Uninstall installed Application from system 
---------------------

Allow to download git repo from github unpack it and start config script in one click:

Script arguments:
  githubRepo - github repository url(browser url pointed on repo)
  destDir - destanation folder where will be unpacked github repo
  installScrip (optional) - script ile to be invocked after repo unpacking

Usage
>./DownloadGithub "https://github.com/stadub/CmdScripts/archive/master.zip" "C:\Sources\Cmd" "InstallBin.cmd"


### Uninstall - Uninstall installed Application from system 
---------------------

Allows to uninstall Application from system via commandline

Usage
>./Uninstall-Application "Microsoft*4.5*"


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
---------------------

Extended version of bookmarks creation code from stackowerflow http://stackoverflow.com/questions/7984974/directory-bookmarks-in-powershell

Commands:
>Save-PSBookmark [ bs]  BookmarkName (Opt)Directory 

>Load-PSBookmark [ bl ] BookmarkName

>List-PSBookmarks [ bv ]
