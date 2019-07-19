# 7zip - 7zip utility warpper

*Can download utility from internet
*Use own bin floder

[![PowerShell 3](https://Stadub-Gh.visualstudio.com/PowershellScripts/_apis/build/status/7Zip?branchName=master)](https://Stadub-Gh.visualstudio.com/PowershellScripts/_build/latest?definitionId=3?branchName=master)
[![PowerShell 4, 5 & Core on Windows build](https://ci.appveyor.com/api/projects/status/7tmg8wy30ipanjsd?svg=true)](https://ci.appveyor.com/project/stadub/powershellscripts)
<!-- [![Linux & MacOS build](https://img.shields.io/travis/stadub/PowershellScripts/master.svg?label=linux/macos+build)](https://travis-ci.org/stadub/PowershellScripts) -->
[![latest version](https://img.shields.io/powershellgallery/v/7Zip.svg?label=latest+version)](https://www.powershellgallery.com/packages/7Zip/)
[![downloads](https://img.shields.io/powershellgallery/dt/7Zip.svg?label=download)](https://www.powershellgallery.com/packages/7Zip)

<!-- [Documentation](https://powershellscripts.readthedocs.io/en/latest/) -->

<!-- ![ConsoleDemo](https://raw.githubusercontent.com/stadub/PowershellScripts/master/7Zip/Assets/demo.gif) -->

## Instalation

Powershell Gallery:

[![https://www.powershellgallery.com/packages/7Zip/](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/7Zip/)

`PowerShellGet` Installation :

```powershell
Install-Module -Name 7Zip
```

Direct download instalation:

```powershell
iex ('$module="7zip"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/stadub/PowershellScripts/master/install.ps1'))
```

Module import:

```powershell
Import-Module 7Zip
```

## Commands

```powershell
Read-ZipFile  - List 7zip file content
  [-Archive] <string>
  [-Password] <string> (Optional)

Add-ZipFileContent - Adds file to archive
  [-Archive] <string>
  [-File] <string>
  [-Password] <string> (Optional)

Remove-ZipFileContent - Remove file from archive
  [-Archive] <string>
  [-File] <string>
  [-Password] <string> (Optional)

New-ZipFile - Create new archive (single file)
  [-Archive] <string>
  [-File] <string>
  [-Compression] (Optional) {Store, Fastest, Fast, Normal, Maximum, Ultra}
  [-Password] <string> (Optional)
  [-SplitSize] <string> (Optional)
  [-PathFormat] (Optional) {Realtive, Full, Absolute}
  [-FileMode] (Optional) {Add, Update, Freshen, Sync}

New-ZipFile - Create new archive (Files list)
  [-Archive] <string>
  [-File] <string>
  [-Files] <string[]>
  [-Compression] (Optional) {Store, Fastest, Fast, Normal, Maximum, Ultra}
  [-Password] <string> (Optional)
  [-SplitSize] <string> (Optional)
  [-PathFormat] (Optional) {Realtive, Full, Absolute}
  [-FileMode] (Optional) {Add, Update, Freshen, Sync}

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

List 7zip file content:

```powershell
/>Read-ZipFile  -Archive 'file.7z'
```

```powershell
/>Read-ZipFile  -Archive 'encodedFile.7z' -Password 'pass'
```

```powershell
/> ./file.7z |  Read-ZipFile
```

Add file to archive:

```powershell
/>Add-ZipFileContent  -Archive 'folder.7z' -File 'file.txt'
```

```powershell
/> ./file.txt |  Add-ZipFileContent -Archive 'File.7z'
```

```powershell
/> ./file.txt |  Add-ZipFileContent -Archive 'encodedFile.7z' -Password "pass"
```

Remove file from archive:

```powershell
/>Remove-ZipFileContent  -Archive 'folder.7z' -File 'file.txt'
```

```powershell
/> ./File.7z |  Remove-ZipFileContent -File 'file.txt'
```

```powershell
/> ./encodedFile.7z |  Remove-ZipFileContent  -File 'file.txt' -Password 'pass'
```

Create new 7zip archive from file

```powershell
/> New-ZipFile -Archive 'folder.7z' -File 'file.txt'
```

```powershell
/> ./file.txt |  New-ZipFileContent -Archive 'encodedFile.7z' -Password 'pass' -Compression Ultra -SplitSize '10mb' -PathFormat Absolute -FileMode Update
```

Create new 7zip archive from file list

```powershell
/> New-ZipFile -Archive folder.7z -Files 'file1.txt', 'file2.txt'
```

```powershell
/> ls |  New-ZipFileContent -Archive encodedFolder.7z -Password "pass" -Compression Store -SplitSize "1gb" -PathFormat Full -FileMode Sync
```

Perform 7Zip arhive integrity check

```powershell
/>Test-ZipFileContent  -Archive 'folder.7z'
```
s
```powershell
/>Test-ZipFileContent  -Archive 'folder.7z' -File 'file.txt'
```

```powershell
/> ([PSCustomObject]@{File='file.txt',  Archive='File.7z', Password="pass"} | Test-ZipFileContent -Archive 'File.7z'
```

## Changelog

### [v0.9.5](https://github.com/stadub/PowershellScripts/releases/tag/v0.3.1)

* Add module methods description.
* Adding Icon/Readme file/Usage video.

### [v0.9.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.3.0)

* Adding unit tests
* Added function `Remove-AllPSBookmarks`
* Add `Test-ZipFileContent` function
* Rename `Check7Zip` to `Test-7ZipInstall`

### [v0.8.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.2.0)

* Adding unit tests for all functions
* Refactor methods and extract worker process function to `Start-7Zip`
* Fix functions load flow.
* Move initalization to separated function.

### [v0.7.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Add the `Remove-ZipFileContent` `Read-ZipFile` functions
* Separate functions and aliases.

### [v0.6.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Extracted module from the `FolderEncoder` project and move to individual folder.
* Rename `Encode7zip` `Decode7Zip` to  `Add-ZipFileContent` and `Get-ZipFileContent` functions

## Motivation

The modules are creasted and actively maintained during evenings and weekends.
If it's useful for you too, that's great. I don't demand anything in return.

However, if you like it and feel the urge to give something back,
a coffee or a beer is always appreciated. Thank you very much in advance.

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png)](https://www.buymeacoffee.com/dima) [![Support by Yandex](https://raw.githubusercontent.com/GitStatic/Resources/master/yaMoney.png)](https://money.yandex.ru/to/410014572567962/200)

<!--   By Paypal [![PayPal.me](https://img.shields.io/badge/PayPal-me-blue.svg?maxAge=2592000)](https://www.paypal.me/dima.by)
 -->

If you have any idea or suggestion - please add a github issue.

<!-- https://www.contributor-covenant.org/version/1/4/code-of-conduct -->