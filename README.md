# Powershell Scripts     [![https://github.com/stadub/PowershellScripts/tree/master/](https://img.shields.io/github/license/stadub/PowershellScripts?style=plastic)](https://github.com/stadub/PowershellScripts/tree/master/)

---------------------

## Powershell Micro Modules

### Base64String - Convert text from/to Base 64 String

[![https://www.powershellgallery.com/packages/Base64String/](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/Base64String)
[![https://github.com/stadub/PowershellScripts/tree/master/Shared-Functions/Base64String/](https://img.shields.io/badge/Base64String-repo-blue.svg?style=flat&logo=github&logoWidth=40)](https://github.com/stadub/PowershellScripts/tree/master/Shared-Functions/Base64String)

[![Base64String](https://raw.githubusercontent.com/stadub/PowershellScripts/master/Shared-Functions/Base64String/Assets/Icon.ico) Base64String](https://github.com/stadub/PowershellScripts/tree/master/Shared-Functions/Base64String)

```powershell
ConvertFrom-Base64String
  [-EncodedValue] <string>
  [bool]$UrlSafe (default- $false) - Set to produce url safe string


ConvertTo-Base64String
  [-Value] <string>

```

[Full documentation and code](https://github.com/stadub/PowershellScripts/tree/master/Shared-Functions/Base64String)

---------------------

### Pipe - Powershell Pipe filtering functions

[![https://www.powershellgallery.com/packages/Pipe/](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/Pipe)
[![https://github.com/stadub/PowershellScripts/tree/master/Shared-Functions/Base64String/](https://img.shields.io/badge/Pipe-repo-blue.svg?style=flat&logo=github&logoWidth=40)](https://github.com/stadub/PowershellScripts/tree/master/Shared-Functions/Pipe)

 [![Pipe](https://raw.githubusercontent.com/stadub/PowershellScripts/master/Shared-Functions/Pipe/Assets/Icon.ico) Pipe](https://github.com/stadub/PowershellScripts/tree/master/Shared-Functions/Pipe)

```powershell
Limit-Type - Filter by element type
   [-Type] <Type>
   [-Strict] (default- $true) - $true - filter by exact type, $false - any assigname type
```powershell

Limit-Type - Filter by element type name
   [-TypeName] <string> Type name
   [-Strict] (default- $true) - $true - filter by exact type, $false - 'like' comparision used

Limit-First - Return only the first element of pipe

Limit-Last - Return only the last element of pipe

Skip-Items - Skip N elements
   [-Count] <int>

Hide-Out - supress output

Limit-Items - Return only N elements from pipe
   [-Count] <int>
```

[Full documentation and code](https://github.com/stadub/PowershellScripts/tree/master/Shared-Functions/Pipe)

---------------------

## Powershell Modules

---------------------

### Bookmarks - Directory bookmarks

[![https://www.powershellgallery.com/packages/Bookmarks/](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/Bookmarks)
[![https://github.com/stadub/PowershellScripts/tree/master/Bookmarks/](https://img.shields.io/badge/Bookmarks-repo-blue.svg?style=flat&logo=github&logoWidth=40)](https://github.com/stadub/PowershellScripts/tree/master/Bookmarks)

[![Bookmarks](https://raw.githubusercontent.com/stadub/PowershellScripts/master/Bookmarks/Assets/Icon.ico) Bookmarks](https://github.com/stadub/PowershellScripts/tree/master/Bookmarks)

```powershell
Add-PSBookmark  - Add folder to the bookmarks list
  [-Name] <string>
  [-Path] <string> (Optional)

Remove-PSBookmark - Remove bookmark from the list
  [-Bookmark] <string>

Open-PSBookmark - Navigate to bookmark
  [-Bookmark] <string>

Get-PSBookmarks - List bookmarks

Save-PSBookmarkk - Save bookmarks to file

Remove-AllPSBookmarks - Clear bookmarks list

Update-PSBookmark  - Update folder location in the bookmarks list
  [-Name] <string>
  [-Path] <string> (Optional)
```

[Full documentation and code](https://github.com/stadub/PowershellScripts/tree/master/Bookmarks)

---------------------

### 7zip-Archive - 7zip utility powershell wrapper

[![https://www.powershellgallery.com/packages/7zip-Archive/](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/7zip-Archive)
[![https://github.com/stadub/PowershellScripts/tree/master/7Zip/](https://img.shields.io/badge/7Zip-repo-blue.svg?style=flat&logo=github&logoWidth=40)](https://github.com/stadub/PowershellScripts/tree/master/7Zip)

[![7Zip](https://raw.githubusercontent.com/stadub/PowershellScripts/master/7Zip/Assets/Icon.ico) 7Zip](https://github.com/stadub/PowershellScripts/tree/master/7Zip)

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

[Full documentation and code](https://github.com/stadub/PowershellScripts/tree/master/7Zip)

---------------------

### Currency-Conv - Currecny converter

[![https://www.powershellgallery.com/packages/Currency-Conv/](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/Currency-Conv)
[![https://github.com/stadub/PowershellScripts/tree/master/Currency-Conv/](https://img.shields.io/badge/CurrencyConv-repo-blue.svg?style=flat&logo=github&logoWidth=40)](https://github.com/stadub/PowershellScripts/tree/master/Currency-Conv)

 [![Currency-Conv](https://raw.githubusercontent.com/stadub/PowershellScripts/master/Currency-Conv/Assets/Icon.ico) Currency-Conv](https://github.com/stadub/PowershellScripts/tree/master/Currency-Conv)

```powershell
Get-ExchangeRate - Get exchange rate for amount
  [-From] <string>
  [-To] <string> (Optional "USD")
  [-Amount] <integer> (Optional 1.0)

Get-Countries -Countries list with currencies

Get-Currencies - Supported currencies list

Remove-CurrencyApiKey- Clean key
```

[Full documentation and code](https://github.com/stadub/PowershellScripts/tree/master/Currency-Conv)

---------------------

### Invoke-FolderEncode - Encode files from a folder for(for example) uploading to the cloud

Used as backups encoding solution.

Encoding performed with 7z password protection

[![https://www.powershellgallery.com/packages/FolderEncoder/](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/FolderEncoder)
[![https://github.com/stadub/PowershellScripts/tree/master/FolderEncoder/](https://img.shields.io/badge/FolderEncoder-repo-blue.svg?style=flat&logo=github&logoWidth=40)](https://github.com/stadub/PowershellScripts/tree/master/FolderEncoder)

[![FolderEncoder](https://raw.githubusercontent.com/stadub/PowershellScripts/master/FolderEncoder/Assets/Icon.ico) FolderEncoder](https://github.com/stadub/PowershellScripts/tree/master/FolderEncoder)

```powershell
Invoke-FolderEncode - Encode folder
  [-DestFolder] <string>
  [-SrcFolder] <string> (Optional)
```

[Full documentation and code](https://github.com/stadub/PowershellScripts/tree/master/FolderEncoder)

---------------------

## 💲 Motivation

The modules are created and actively maintained during evenings and weekends for my own needs.
If it's useful for you too, that's great. I don't demand anything in return.

However, if you like it and feel the urge to give something back,
a coffee or a beer is always appreciated. Thank you very much in advance.

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png)](https://www.buymeacoffee.com/dima)
[![Support by Yandex](https://raw.githubusercontent.com/GitStatic/Resources/master/yaMoney.png)](https://money.yandex.ru/to/410014572567962/200)

<!--   By Paypal [![PayPal.me](https://img.shields.io/badge/PayPal-me-blue.svg?maxAge=2592000)](https://www.paypal.me/dima.by)
 -->

## 📬 Suggestions and feedback

If you have any idea or suggestion - please add a github issue.

<!-- https://www.contributor-covenant.org/version/1/4/code-of-conduct -->
