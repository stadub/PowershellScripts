# Currency-Conv - Currecny converter

[![PowerShell 3](https://dev.azure.com/Stadub-Gh/PowershellScripts/_apis/build/status/Currency-Conv?branchName=master)](https://dev.azure.com/Stadub-Gh/PowershellScripts/_build/latest?definitionId=5&branchName=master)
[![PowerShell 4, 5 & Core on Windows build](https://ci.appveyor.com/api/projects/status/7tmg8wy30ipanjsd?svg=true)](https://ci.appveyor.com/project/stadub/powershellscripts)
[![Linux & MacOS build](https://img.shields.io/travis/stadub/PowershellScripts/master.svg?label=linux/macos+build)](https://travis-ci.org/stadub/PowershellScripts)
[![latest version](https://img.shields.io/powershellgallery/v/Currency-Conv.svg?label=latest+version)](https://www.powershellgallery.com/packages/Currency-Conv/)
[![downloads](https://img.shields.io/powershellgallery/dt/Currency-Conv.svg?label=downloads)](https://www.powershellgallery.com/packages/Currency-Conv)
<!-- [Documentation](https://powershellscripts.readthedocs.io/en/latest/) -->

---------------------

![ConsoleDemo](https://raw.githubusercontent.com/stadub/PowershellScripts/master/Currency-Conv/Assets/demo.gif)

## Instalation

Powershell Gallery:

[![https://www.powershellgallery.com/packages/Currency-Conv/](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/Currency-Conv/)

`PowerShellGet` Installation :

```powershell
Install-Module -Name Currency-Conv
```

Direct download instalation:

```powershell
iex ('$module="Currency-Conv"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/stadub/PowershellScripts/master/install.ps1'))
```

Module import:

```powershell
Import-Module Currency-Conv
```

## Commands

```powershell
Get-ExchangeRate - Get exchange rate for amount
  [-From] <string>
  [-To] <string> (Optional "USD")
  [-Amount] <integer> (Optional 1.0)

Get-Countries -Countries list with currencies

Get-Currencies - Supported currencies list

Remove-CurrencyApi-Key- Clean key
```

## Aliases

| Cmdlet           | Alias    |
| -----------------|:--------:|
| Get-Currencies   | gxc      |
| Get-ExchangeRate |  xe      |

## Usage

Currency exchange rates:

```powershell
/> Get-ExchangeRate All BDD 5
```

```powershell
/> Get-ExchangeRate -From USD -To BYN 5
```

```powershell
/> Get-ExchangeRate -Base PHP -Result EUR -Amount 5
```

```powershell
/> ([PSCustomObject]@{From="BYN"; To="USD";Value=4}) |  Get-ExchangeRate
```

```powershell
/> ([PSCustomObject]@{Base="PHP"; Amount=400})|  Get-ExchangeRate
```

List supported countries:

```powershell
/> Get-Countries
```

List supported currencies:

```powershell
/> Get-Currencies
```

Remove currconv.com api key fromthe system:

```powershell
/> Remove-CurrencyApi-Key
```

## Changelog

### [v1.0.2](https://github.com/stadub/PowershellScripts/releases/tag/v0.9.0) Spet 1, 2019

* Add functions:

```powershell
Get-ExchangeRate - Get exchange rate for amount
  [-From] <string>
  [-To] <string> (Optional "USD")
  [-Amount] <integer> (Optional 1.0)

Get-Countries -Countries list with currencies

Get-Currencies - Supported currencies list

Remove-CurrencyApi-Key- Clean key
```

* Create tests


## Motivation

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
