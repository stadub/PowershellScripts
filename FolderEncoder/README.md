# Invoke-FolderEncode - Encode files from folder for(for example) uploading to cloud

Used as backups encoding solution.
Encoding performed with 7z password protection

[PowerShell Gallery](https://www.powershellgallery.com/packages/FolderEncoder/2.0.0) [![https://www.powershellgallery.com/packages/FolderEncoder/2.0.0](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/FolderEncoder/2.0.0)

---------------------

![ConsoleDemo](https://raw.githubusercontent.com/stadub/PowershellScripts/master/FolderEncoder/Assets/demo.gif)


## Commands

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



## Changelog

### [v2.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.2.0)

* Added dependencies auto donwload.
* Added platfrom specific tools for Linux/MacOs

### [v1.0.2](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Fixed key file check.

### [v1.0.1](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Moved module to individual foler.
* Added module methods description.

### [v1.0.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Created description and usage examples

### [v0.9](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Create Windows folder encoding scripts:

```powershell
ZipFile
  [FileName]<string>
  [Key]<string>
  [SrcFolder]<string>
  [DestFolder]<string>

GetFileHash
  [FilePath]<string>

EncodeFile
  [Salt]<string>
  [SrcFolder]<string>
  [DestFolder]<string>
  [FileName]<string>

Invoke-FolderEncode
  [SrcFolder]<string>
  [DestFolder]<string>

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