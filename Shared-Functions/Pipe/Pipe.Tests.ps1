
$NoExport = $true
$ModuleDevelopment = $true
$DebugPreference = "Continue"

Set-StrictMode -version Latest

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Import-Module .\Base64String.psd1

Describe "ConvertTo-Base64String" {

    It "Encodes text to Base64" {
        $text="text"
        $encoded="dABlAHgAdAA="

        $result = ConvertTo-Base64String -Value $text -UrlSafe $true

        $result | Should -Be $encoded
    }

    It "UrlSafe produce urlsafe  text " {
        $text="text"
        $encoded="dABlAHgAdAA"

        $result = ConvertTo-Base64String -Value $text -UrlSafe $true


        $result | Should -Be $encoded
    }
}

Describe "ConvertFrom-Base64String" {

    It "Decodes text from Base64" {
        $encoded="MQAyADMAcQB3AGUA"
        $text="123qwe"

        $result = ConvertFrom-Base64String $encoded


        $result | Should -Be $text
    }
    It "Support url safe Base64" {
        $encoded="dABlAHgAdAA"
        $text="text"

        $result = ConvertFrom-Base64String $encoded


        $result | Should -Be $text
    }
    
}
