# Currency-Conv - Currecny converter

[![https://www.powershellgallery.com/packages/Currency-Conv/0.9.0](https://img.shields.io/badge/PowerShell%20Gallery-download-blue.svg?style=popout&logo=powershell)](https://www.powershellgallery.com/packages/Currency-Conv/0.9.0)

<!-- [Documentation](https://powershellscripts.readthedocs.io/en/latest/) -->

---------------------

![ConsoleDemo](https://raw.githubusercontent.com/stadub/PowershellScripts/master/Currency-Conv/Assets/demo.gif)

## Commands

```powershell
Get-ExchangeRate - Get exchange rate for amount
  [-From] <string>
  [-To] <string> (Optional "USD")
  [-Amount] <integer> (Optional 1.0)

Get-Countries -Countries list with currencies

Get-Currencies - Supported currencies list
```

## Aliases

| Cmdlet           | Alias    |
| -----------------|:--------:|
| Get-Currencies   | gxc | xe |

## Usage

Currency exchange rates:

```powershell
/> Get-ExchangeRate USD BYN 5
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

### [v0.9.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.8.2) May 17, 2019

* Add demo gif and documentation

### [v0.8.5](https://github.com/stadub/PowershellScripts/releases/tag/v0.8.0)

* Move module to individual foler.
* Create Markdown page.

### [v0.8.1](https://github.com/stadub/PowershellScripts/releases/tag/v0.2.0)

* Separate functions and aliases.

### [v0.8.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0)

* Add module methods description.


### [v0.7.0](https://github.com/stadub/PowershellScripts/releases/tag/v0.1.0) Mar 18, 2019

* Added exchange convertion functions:

```powershell
Get-ExchangeRate - Get exchange rate for amount
  [-From] <string>
  [-To] <string> (Optional "USD")
  [-Amount] <integer> (Optional 1.0)

Get-Countries -Countries list with currencies

Get-Currencies - Supported currencies list

```

## Motivation

Hi, I written this module(and other modules of the repo) for my own usage.
But if you found it usefull you can Buy me a beer/cup of tee😊

<!--   By Paypal [![PayPal.me](https://img.shields.io/badge/PayPal-me-blue.svg?maxAge=2592000)](https://www.paypal.me/dima.by)

 <> Or 
 -->
[![Yandex Money](https://money.yandex.ru/i/ym2015_icon.png)](https://money.yandex.ru/to/410014572567962)

<!-- Yandex Money (https://money.yandex.ru/i/ym2015_icon.png)(https://money.yandex.ru/to/410014572567962) -->

If you have any idea or suggestion - please add a github issue and I'll try to implement it😉
