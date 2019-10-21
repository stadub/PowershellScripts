# Invoke-FolderEncode - Encode files from a folder for(for example) uploading to the cloud

Used as backups encoding solution.

Encoding performed with 7z password protection

[![PowerShell 3](https://Stadub-Gh.visualstudio.com/PowershellScripts/_apis/build/status/Bookmarks?branchName=master)](https://Stadub-Gh.visualstudio.com/PowershellScripts/_build/latest?definitionId=3?branchName=master)
[![PowerShell 4, 5 & Core on Windows build](https://ci.appveyor.com/api/projects/status/7tmg8wy30ipanjsd?svg=true)](https://ci.appveyor.com/project/stadub/powershellscripts)
[![Linux & MacOS build](https://img.shields.io/travis/stadub/PowershellScripts/master.svg?label=linux/macos+build)](https://travis-ci.org/stadub/PowershellScripts)
[![latest version](https://img.shields.io/powershellgallery/v/FolderEncoder.svg?label=latest+version)](https://www.powershellgallery.com/packages/FolderEncoder/)
[![downloads](https://img.shields.io/powershellgallery/dt/FolderEncoder.svg?label=download)](https://www.powershellgallery.com/packages/FolderEncoder)

 [![https://www.powershellgallery.com/packages/FolderEncoder/](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/FolderEncoder/2.0.0)

![ConsoleDemo](https://raw.githubusercontent.com/stadub/PowershellScripts/master/FolderEncoder/Assets/demo.gif)

## 📘 Commands

```powershell
Invoke-FolderEncode - Encode folder
  [-DestFolder] <string>
  [-SrcFolder] <string> (Optional)
```

## 📃 Usage

```powershell
/>Invoke-FolderEncode -DestFolder "d:\System\" -SrcFolder "c:\windows\System42"
/> cd c:\Windows; Invoke-FolderEncode "d:\backup\" #use current folder as src
```

## Decoding

There is no decoding script. Because currently used only for backups and(thank goodness) there was no necessity to decode it.
To decrypt manually:

There were no reasons (thank goodness) decoding stored data so currently there no decoder script.
If you need - please create GitHub issue and I'll add a script for folder decoding.

Manually files can be decoded with the next algorithm:
1 Concat value from .masterKey and add ':' to the beginning and by using resulting key extract .keys file from .keys.7z

2 Find the appropriate row in .key for a file that should be decoded.

3 Concat first row from .masterKey with the first row from .key file and ':' to beginning

4 Use the key from the previous step as 7z password for decode file

## 📈 Changelog

### [v2.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.2.0)

* Added dependencies auto download.
* Added platform-specific tools for Linux/MacOs

### [v1.0.2](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Fixed key file check.

### [v1.0.1](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Moved module to an individual folder.
* Added module methods description.

### [v1.0.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Created description and usage examples

### [v0.9](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0) Aug 15, 2015

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

## 💲 Motivation

The modules are actively maintained during evenings and weekends,
so if you found it useful you can Buy me a beer/cup of tea 😊.

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png)](https://www.buymeacoffee.com/dima) [![Support by Yandex](https://raw.githubusercontent.com/GitStatic/Resources/master/yaMoney.png)](https://money.yandex.ru/to/410014572567962/200)

<!--   By Paypal [![PayPal.me](https://img.shields.io/badge/PayPal-me-blue.svg?maxAge=2592000)](https://www.paypal.me/dima.by)

 -->

## 📬 Suggestions and feedback

If you have any idea or suggestion - please add a github issue and I'll try to implement it as soon as possible😉

<!-- https://www.contributor-covenant.org/version/1/4/code-of-conduct -->