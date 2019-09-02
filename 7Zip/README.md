# 7zip-Archive - 7zip utility warpper

Download 7Zip utility from internet and use own bin floder

[![PowerShell 3](https://dev.azure.com/Stadub-Gh/PowershellScripts/_apis/build/status/7Zip?branchName=master)](https://dev.azure.com/Stadub-Gh/PowershellScripts/_build/latest?definitionId=4&branchName=master)
[![PowerShell 4, 5 & Core on Windows build](https://ci.appveyor.com/api/projects/status/7tmg8wy30ipanjsd?svg=true)](https://ci.appveyor.com/project/stadub/powershellscripts)
[![Linux & MacOS build](https://img.shields.io/travis/stadub/PowershellScripts/master.svg?label=linux/macos+build)](https://travis-ci.org/stadub/PowershellScripts)
[![latest version](https://img.shields.io/powershellgallery/v/7zip-Archive.svg?label=latest+version)](https://www.powershellgallery.com/packages/Bookmarks/)
[![downloads](https://img.shields.io/powershellgallery/dt/7zip-Archive.svg?label=downloads)](https://www.powershellgallery.com/packages/Bookmarks)

<!-- [Documentation](https://powershellscripts.readthedocs.io/en/latest/) -->

![ConsoleDemo](https://raw.githubusercontent.com/stadub/PowershellScripts/master/Bookmarks/Assets/demo.gif)

## Instalation

Powershell Gallery:

[![https://www.powershellgallery.com/packages/7zip-Archive/](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/7zip-Archive/)

`PowerShellGet` Installation :

```powershell
Install-Module -Name 7zip-Archive
```

Direct download instalation:

```powershell
iex ('$module="7Zip"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/stadub/PowershellScripts/master/install.ps1'))
```

Module import:

```powershell
Import-Module 7zip-Archive
```

## Commands

```powershell

New-ZipFile - Create new archive
  [-Archive] <string>
  [-Files] <string[]>
  [-Compression] (Optional) {Store, Fastest, Fast, Normal, Maximum, Ultra}
  [-Password] <string> (Optional)
  [-SplitSize] <string> (Optional)
  [-SplitSizeFactor] (Optional) {Byte, Kilobyte, Megabyte, Gigabytes}
  [-UpdateMode] (Optional) {Add, Update, Freshen, Sync}

Get-ZipFileContent - Extract archive new archive
  [-Archive] <string>
  [-FileName] <string> (Optional) - Extrct single file
  [-Password] <string> (Optional)
  [-Force] <Boolean> (Optional) - Overwrite existing file
  [-OutputPath] <string> (Optional) - folder to extract

Read-ZipFile  - List 7zip file content
  [-Archive] <string>
  [-Password] <string> (Optional)

Add-ZipFileContent - Add file to archive
  [-Archive] <string>
  [-File] <string>
  [-Password] <string> (Optional)

Remove-ZipFileContent - Remove file from archive
  [-Archive] <string>
  [-File] <string>
  [-Password] <string> (Optional)


Test-ZipFileContent - Perform zip file check
  [-Archive] <string>
  [-File] <string> (Optional)
  [-Password] <string> (Optional)

```

## Aliases

| Cmdlet               | Alias  |
| ---------------------|:------:|
| Read-ZipFile         | szr    |
| Add-ZipFileContent   | sza    |
| Remove-ZipFileContent| szrm   |
| Test-ZipFileContent  | szt    |
| Get-ZipFileContent   | sz     |

## Usage

### Create new 7zip archive from file

```powershell
/> New-ZipFile -Archive 'folder.7z' -Files 'file1.txt', 'file2.bin'
```

```powershell
/> ./file.txt |  New-ZipFile -Archive 'encodedFile.7z' -Password 'pass' -Compression Ultra -SplitSize 1,2,3,20 -SplitSizeFactor Megabyte
```

### Create new 7zip archive from file list

```powershell
/> New-ZipFile -Archive folder.7z -Files 'file1.txt', 'file2.txt'
```

```powershell
/> ls -Exclude .git | New-ZipFile "scripts" -Password "pass" -Compression Store -SplitSize 1 -SplitSizeFactor Gigabytes
```

### Extract file(s) from 7zip archive

```powershell
/> Get-ZipFileContent -Archive folder.7z -Files 'file1.txt', 'file2.txt'
```

```powershell
/> Get-ZipFileContent "scripts" -Password "pass" -Force $True  -OutDir "out"
```

### List 7zip file content

```powershell
/>Read-ZipFile  -Archive 'file.7z'
```

```powershell
/>Read-ZipFile  -Archive 'encodedFile.7z' -Password 'pass'
```

```powershell
/> ./file.7z |  Read-ZipFile
```

### Add file to archive

```powershell
/>Add-ZipFileContent  -Archive 'folder.7z' -File 'file.txt'
```

```powershell
/> ./file.txt |  Add-ZipFileContent -Archive 'File.7z'
```

```powershell
/> ./file.txt |  Add-ZipFileContent -Archive 'encodedFile.7z' -Password "pass"
```

### Remove file from archive

```powershell
/>Remove-ZipFileContent  -Archive 'folder.7z' -File 'file.txt'
```

```powershell
/> ./File.7z |  Remove-ZipFileContent -File 'file.txt'
```

```powershell
/> ./encodedFile.7z |  Remove-ZipFileContent  -File 'file.txt' -Password 'pass'
```


### Perform 7Zip arhive integrity check

```powershell
/>Test-ZipFileContent  -Archive 'folder.7z'
```

```powershell
/>Test-ZipFileContent  -Archive 'folder.7z' -File 'file.txt'
```

```powershell
/> ([PSCustomObject]@{File='file.txt',  Archive='File.7z', Password="pass"} | Test-ZipFileContent -Archive 'File.7z'
```

## Changelog

### [v1.0.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.4.0)

*First public release.
*Supported function:
  `Read-ZipFile` `szr`
  `Add-ZipFileContent` `sza`
  `Remove-ZipFileContent` `szrm`
  `Test-ZipFileContent` `szt`
  `Get-ZipFileContent` `br`

* Changelog:
  Update icon.
  Remove extra shared functions
  Add update checker
  Change test environment to  StrictMode=Latest
* Adding Icon/Readme file/Usage video.

### [v0.9.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.3.0)

* Adding unit tests
* Extracted `7zip` module from `FolderEncoder`
* Module `7zip` adding aliazes and tests
* `7zip` moduel add readme file, icon and build def

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