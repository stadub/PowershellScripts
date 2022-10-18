# Powershell Scripts     [![https://github.com/stadub/PowershellScripts/tree/master/](https://img.shields.io/github/license/stadub/PowershellScripts?style=plastic)](https://github.com/stadub/PowershellScripts/tree/master/)

---------------------

## Powershell Micro Modules

### [![Base64String](https://raw.githubusercontent.com/stadub/PowershellScripts/master/Shared-Functions/Base64String/Assets/Icon.Small.png)](https://github.com/stadub/PowershellScripts/tree/master/Shared-Functions/Base64String) Base64String - Convert text from/to Base 64 String

[![https://www.powershellgallery.com/packages/Base64String/](https://img.shields.io/badge/dynamic/xml?label=Download%20From%20PowerShell%20Gallery&query=%2F%2F%2A%5Blocal-name%28%29%3D%27DownloadCount%27%5D&url=https%3A%2F%2Fwww.powershellgallery.com%2Fapi%2Fv2%2FPackages%28%29%3F%24filter%3DId%2520eq%2520%2527Base64String%2527%2520and%2520IsLatestVersion%2520eq%2520true%26%24select%3DDownloadCount&logo=powershell)](https://www.powershellgallery.com/packages/Base64String)
[![https://github.com/stadub/PowershellScripts/tree/master/Shared-Functions/Base64String/](https://img.shields.io/badge/Base64String-GitHub%20Repository-blue.svg?style=flat&logo=github&logoWidth=40)](https://github.com/stadub/PowershellScripts/tree/master/Shared-Functions/Base64String)

```powershell
ConvertFrom-Base64String
  [-EncodedValue] <string>
  [-UrlSafe] <bool>  (default- $false) - Set to produce url safe string


ConvertTo-Base64String
  [-Value] <string>

```

[👉🏿 Full documentation and code](https://github.com/stadub/PowershellScripts/tree/master/Shared-Functions/Base64String)

---------------------

### [![Pipe](https://raw.githubusercontent.com/stadub/PowershellScripts/master/Shared-Functions/Pipe/Assets/Icon.Small.png)](https://github.com/stadub/PowershellScripts/tree/master/Shared-Functions/Pipe) Pipe - Powershell Pipe filtering functions

[![https://www.powershellgallery.com/packages/Pipe/](https://img.shields.io/badge/dynamic/xml?label=%20%20Download%20From%20PowerShell%20Gallery&query=%2F%2F%2A%5Blocal-name%28%29%3D%27DownloadCount%27%5D&url=https%3A%2F%2Fwww.powershellgallery.com%2Fapi%2Fv2%2FPackages%28%29%3F%24filter%3DId%2520eq%2520%2527Pipe%2527%2520and%2520IsLatestVersion%2520eq%2520true%26%24select%3DDownloadCount&logo=powershell)](https://www.powershellgallery.com/packages/Pipe)
[![https://github.com/stadub/PowershellScripts/tree/master/Shared-Functions/Base64String/](https://img.shields.io/badge/Pipe-GitHub%20Repository-blue.svg?style=flat&logo=github&logoWidth=40)](https://github.com/stadub/PowershellScripts/tree/master/Shared-Functions/Pipe)

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

[👉🏿 Full documentation and code](https://github.com/stadub/PowershellScripts/tree/master/Shared-Functions/Pipe)

---------------------

## Powershell Modules

---------------------

### [![Bookmarks](https://raw.githubusercontent.com/stadub/PowershellScripts/master/Bookmarks/Assets/Icon.Small.png)](https://github.com/stadub/PowershellScripts/tree/master/Bookmarks)  Bookmarks - Directory bookmarks

[![https://www.powershellgallery.com/packages/Bookmarks/](https://img.shields.io/badge/dynamic/xml?label=Download%20From%20PowerShell%20Gallery&query=%2F%2F%2A%5Blocal-name%28%29%3D%27DownloadCount%27%5D&url=https%3A%2F%2Fwww.powershellgallery.com%2Fapi%2Fv2%2FPackages%28%29%3F%24filter%3DId%2520eq%2520%2527Bookmarks%2527%2520and%2520IsLatestVersion%2520eq%2520true%26%24select%3DDownloadCount&logo=powershell
)](https://www.powershellgallery.com/packages/Bookmarks)
[![https://github.com/stadub/PowershellScripts/tree/master/Bookmarks/](https://img.shields.io/badge/Bookmarks-GitHub%20Repository-blue.svg?style=flat&logo=github&logoWidth=40)](https://github.com/stadub/PowershellScripts/tree/master/Bookmarks)

```powershell
Add-PSBookmark  - Add folder to the bookmarks list
  [-Name] <string>
  [-Path] <string> (Optional)

Remove-PSBookmark - Remove bookmark from the list
  [-Bookmark] <string>

Open-PSBookmark - Navigate to bookmark
  [-Bookmark] <string>

Get-PSBookmarks - List bookmarks

Remove-AllPSBookmarks - Clear bookmarks list

Update-PSBookmark  - Update folder location in the bookmarks list
  [-Name] <string>
  [-Path] <string> (Optional)
```

[👉🏿 Full documentation and code](https://github.com/stadub/PowershellScripts/tree/master/Bookmarks)

---------------------

### [![7Zip](https://raw.githubusercontent.com/stadub/PowershellScripts/master/7Zip/Assets/Icon.Small.png)](https://github.com/stadub/PowershellScripts/tree/master/7Zip) 7zip-Archive - 7zip utility powershell wrapper

[![https://www.powershellgallery.com/packages/7zip-Archive/](https://img.shields.io/badge/dynamic/xml?label=Download%20From%20PowerShell%20Gallery&query=%2F%2F%2A%5Blocal-name%28%29%3D%27DownloadCount%27%5D&url=https%3A%2F%2Fwww.powershellgallery.com%2Fapi%2Fv2%2FPackages%28%29%3F%24filter%3DId%2520eq%2520%25277zip-Archive%2527%2520and%2520IsLatestVersion%2520eq%2520true%26%24select%3DDownloadCount&logo=powershell)
[![https://github.com/stadub/PowershellScripts/tree/master/7Zip/](https://img.shields.io/badge/7Zip-GitHub%20Repository-blue.svg?style=flat&logo=github&logoWidth=40)](https://github.com/stadub/PowershellScripts/tree/master/7Zip)

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

[👉🏿 Full documentation and code](https://github.com/stadub/PowershellScripts/tree/master/7Zip)

---------------------

### [![Currency-Conv](https://raw.githubusercontent.com/stadub/PowershellScripts/master/Currency-Conv/Assets/Icon.Small.png)](https://github.com/stadub/PowershellScripts/tree/master/Currency-Conv) Currency-Conv - Currecny converter

[![https://www.powershellgallery.com/packages/Currency-Conv/](https://img.shields.io/badge/dynamic/xml?label=Download%20From%20PowerShell%20Gallery&query=%2F%2F%2A%5Blocal-name%28%29%3D%27DownloadCount%27%5D&url=https%3A%2F%2Fwww.powershellgallery.com%2Fapi%2Fv2%2FPackages%28%29%3F%24filter%3DId%2520eq%2520%2527Currency-Conv%2527%2520and%2520IsLatestVersion%2520eq%2520true%26%24select%3DDownloadCount&logo=powershell)](https://www.powershellgallery.com/packages/Currency-Conv)
[![https://github.com/stadub/PowershellScripts/tree/master/Currency-Conv/](https://img.shields.io/badge/CurrencyConv-GitHub%20Repository-blue.svg?style=flat&logo=github&logoWidth=40)](https://github.com/stadub/PowershellScripts/tree/master/Currency-Conv)


```powershell
Get-ExchangeRate - Get exchange rate for amount
  [-From] <string>
  [-To] <string> (Optional "USD")
  [-Amount] <integer> (Optional 1.0)

Get-Countries -Countries list with currencies

Get-Currencies - Supported currencies list

Remove-CurrencyApiKey- Clean key
```

[👉🏿 Full documentation and code](https://github.com/stadub/PowershellScripts/tree/master/Currency-Conv)

---------------------

### [![FolderEncoder](https://raw.githubusercontent.com/stadub/PowershellScripts/master/FolderEncoder/Assets/Icon.Small.png)](https://github.com/stadub/PowershellScripts/tree/master/FolderEncoder) Invoke-FolderEncode - Encode files from a folder for(for example) uploading to the cloud

Used as backups encoding solution.

Encoding performed with 7z password protection

[![https://www.powershellgallery.com/packages/FolderEncoder/](https://img.shields.io/badge/dynamic/xml?label=Download%20From%20PowerShell%20Gallery&query=%2F%2F%2A%5Blocal-name%28%29%3D%27DownloadCount%27%5D&url=https%3A%2F%2Fwww.powershellgallery.com%2Fapi%2Fv2%2FPackages%28%29%3F%24filter%3DId%2520eq%2520%2527FolderEncoder%2527%2520and%2520IsLatestVersion%2520eq%2520true%26%24select%3DDownloadCount&logo=powershell)](https://www.powershellgallery.com/packages/FolderEncoder)
[![https://github.com/stadub/PowershellScripts/tree/master/FolderEncoder/](https://img.shields.io/badge/FolderEncoder-GitHub%20Repository-blue.svg?style=flat&logo=github&logoWidth=40)](https://github.com/stadub/PowershellScripts/tree/master/FolderEncoder)


```powershell
Invoke-FolderEncode - Encode folder
  [-DestFolder] <string>
  [-SrcFolder] <string> (Optional)
```

[👉🏿 Full documentation and code](https://github.com/stadub/PowershellScripts/tree/master/FolderEncoder)

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
