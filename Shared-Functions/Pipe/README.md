# Pipe - Bunch Pipe filtering functions

[![PowerShell 3](https://dev.azure.com/Stadub-Gh/PowershellScripts/_apis/build/status/SharedFunctions?branchName=master)](https://dev.azure.com/Stadub-Gh/PowershellScripts/_build/latest?definitionId=6&branchName=master)
[![PowerShell 4, 5 & Core on Windows build](https://ci.appveyor.com/api/projects/status/7nunpf138bmp7ogf/branch/master?svg=true)](https://ci.appveyor.com/project/stadub/powershellscripts-v9ncj/branch/master)
[![Linux & MacOS build](https://img.shields.io/travis/stadub/PowershellScripts/master.svg?label=linux/macos+build)](https://travis-ci.org/stadub/PowershellScripts)
[![latest version](https://img.shields.io/powershellgallery/v/Pipe.svg?label=latest+version)](https://www.powershellgallery.com/packages/Pipe/)
[![downloads](https://img.shields.io/powershellgallery/dt/Pipe.svg?label=downloads)](https://www.powershellgallery.com/packages/Pipe)
<!-- [Documentation](https://powershellscripts.readthedocs.io/en/latest/) -->
[![https://www.powershellgallery.com/packages/Pipe/](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/Pipe/)
---------------------

<!-- ![ConsoleDemo](https://github.com/stadub/PowershellScripts/raw/master/Shared-Functions/Pipe/Assets/demo.gif) -->

## 📘 Commands

```powershell
Where-Type - Filter by element type
   [-Type] <Type>
   [-Strict] (default- $true) - $true - filter by exact type, $false - any assigname type

Where-Type - Filter by element type name
   [-TypeName] <string> Type name
   [-Strict] (default- $true) - $true - filter by exact type, $false - 'like' comparision used

```

```powershell
Limit-First - Return only the first element of pipe
```

```powershell
Limit-Last - Return only the last element of pipe
```

```powershell
Skip-Items - Skip N elements
   [-Count] <int>
```

```powershell
Hide-Out - supress output
```

```powershell
Limit-Items - Return only N elements from pipe
   [-Count] <int>
```

## ⚡ Aliases

| Filter        |  Alias   |
| --------------|:--------:|
|  Skip-Items   | skip     |
|  Where-Type   | wtype    |
|  Limit-Items  | take     |
|  Limit-First  | first    |
|  Limit-Last   | last     |
|  Hide-Out     | suppress |

## 📃 Usage

Return only 2 file names from directory:

```powershell
/> ls | take -Count 2
```

Skip 3 lins and return only the next 2:

```powershell
/> ping 8.8.8.8 | Skip-Items -Count 8 | Limit-Items -Count 2
```

Suppress command output:

```powershell
/> cp a b | Hide-Out
```

Rerurn only the first pipe item

```powershell
/> cat C:\Windows\win.ini | Limit-First
```

Rerurn the only last pipe item

```powershell
/> cat cat C:\Windows\system.ini | Limit-Last
```

Filter by Type Name

```powershell
/> "a", 3, 5 | Where-Type -TypeName "string"

/>  "a", 3, 5 | Where-Type -TypeName "*str*" -Strict  $false
```

Filter by pipe item type

```powershell
/> ls | Where-Type -Type $([System.IO.FileSystemInfo]) -Strict  $false

/> ls | Where-Type -Type $([System.IO.DirectoryInfo])
```

## 🔨 Instalation

Powershell Gallery:

`PowerShellGet` Installation :

```powershell
Install-Module -Name Pipe
```

Direct download instalation:

```powershell
iex ('$module="Shared-Functions/Pipe"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/stadub/PowershellScripts/master/install.ps1'))
```

Module import:

```powershell
Import-Module Pipe
```

## 📈 Changelog

### [v1.0.0] Oct 17, 2019

* Create a filters module

```powershell
 | Where-Type - Filter by element type

 | Where-Type - Filter by element type name

 | Limit-First - Return only the first element of pipe

 | Limit-Last - Return only the last element of pipe

 | Skip-Items - Skip N elements

 | Hide-Out - supress output

 | Limit-Items - Return only N elements from pipe
```

### 📬 Suggestions and feedback

If you have any idea or suggestion - please add a github issue.
