# EncodeVia7z -  Encode files from folder for(for example) uploading to cloud

Used as backups encoding solution.
Encoding performed with 7z password protection

[PowerShell Gallery](https://www.powershellgallery.com/packages/FolderEncoder/1.0.0)

---------------------

## Script arguments

  SrcFolder (optional) - Folder to be encoded
  DestFolder - Destanation folder where encoded files be created

## Usage

>./EncodeVia7z "c:\windows\System42" "d:\System\"

## Decoding

There is no decoding script. Because currently used only for backups and(thank goodness) there was no necessity to decode it.
To decrypt manually:

There was no reasons (thank goodness) decoding stored data so currently there no decoder script.
It you need - please create github issue and I'll add scrpit for folder decoding.

Manually files can be decoded with the next algorithm:
1 Concat value from .masterKey and add ':' to beginign and by using resulting key extract .keys file from .keys.7z

2 Find apropriate row in .key for file that shoudl be decoded.

3 Concat first row from .masterKey with first row from .key file and ':' to beginign

4 Use key from previouse step as 7z password for decode file