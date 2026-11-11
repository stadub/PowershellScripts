$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module (Join-Path $here 'Base64String.psd1') -Force

Describe 'Base64String encoding compatibility' {
    It 'preserves the default UTF-16 little-endian bytes' {
        ConvertTo-Base64String 'text' | Should -BeExactly 'dABlAHgAdAA='
        ConvertTo-Base64String -Text 'text' | Should -BeExactly 'dABlAHgAdAA='
        ConvertFrom-Base64String 'dABlAHgAdAA=' | Should -BeExactly 'text'
        ConvertFrom-Base64String 'MQAyADMAcQB3AGUA' | Should -BeExactly '123qwe'
    }

    It 'preserves Unicode and the historical 1-ending regression' {
        # Code points keep this test readable by Windows PowerShell without a UTF-8 BOM.
        $text = '.d_''+' + [char]0x2642 + [char]0xA2 + [char]0xA3 + '1'
        $expected = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($text))
        ConvertTo-Base64String $text | Should -BeExactly $expected
        ConvertFrom-Base64String $expected | Should -BeExactly $text
        ConvertFrom-Base64String $expected.TrimEnd('=') | Should -BeExactly $text
    }

    It 'interoperates with the non-ASCII UTF-8 example from issue 22' {
        $text = '.d_''+' + [char]0x2642 + [char]0xA2 + [char]0xA3
        ConvertTo-Base64String $text -Encoding UTF8 | Should -BeExactly 'LmRfJyvimYLCosKj'
        ConvertFrom-Base64String 'LmRfJyvimYLCosKj' -Encoding UTF8 | Should -BeExactly $text
    }

    It 'accepts supported encoding <Encoding>' -TestCases @(
        @{ Encoding = 'Unicode'; Expected = 'QQA=' }
        @{ Encoding = 'UTF8'; Expected = 'QQ==' }
        @{ Encoding = 'BigEndianUnicode'; Expected = 'AEE=' }
        @{ Encoding = 'UTF32'; Expected = 'QQAAAA==' }
        @{ Encoding = 'ASCII'; Expected = 'QQ==' }
    ) {
        param($Encoding, $Expected)
        ConvertTo-Base64String 'A' -Encoding $Encoding | Should -BeExactly $Expected
        ConvertFrom-Base64String $Expected -Encoding $Encoding | Should -BeExactly 'A'
    }

    It 'rejects unsupported encodings in both directions' {
        { ConvertTo-Base64String 'text' -Encoding invalid } | Should -Throw
        { ConvertFrom-Base64String 'dGV4dA==' -Encoding invalid } | Should -Throw
    }

    It 'supports positional UrlSafe, aliases, and multiple pipeline values' {
        ConvertTo-Base64String 'text' $true | Should -BeExactly 'dABlAHgAdAA'
        $encoded = @('one', 'two' | encode64 -Encoding UTF8)
        $encoded.Count | Should -Be 2
        $encoded[0] | Should -BeExactly 'b25l'
        $encoded[1] | Should -BeExactly 'dHdv'
        $decoded = @($encoded | decode64 -Encoding UTF8)
        $decoded.Count | Should -Be 2
        $decoded[0] | Should -BeExactly 'one'
        $decoded[1] | Should -BeExactly 'two'
    }

    It 'produces and decodes both URL-safe substitutions' {
        $text = [string][char]0xFBFF
        ConvertTo-Base64String $text | Should -BeExactly '//s='
        ConvertTo-Base64String $text $true | Should -BeExactly '__s'
        ConvertFrom-Base64String '__s' | Should -BeExactly $text
        # UTF-8 for U+FFFF contains both + and / in Base64.
        $text = [string][char]0xFFFF
        ConvertTo-Base64String $text -Encoding UTF8 | Should -BeExactly '77+/'
        ConvertTo-Base64String $text -UrlSafe $true -Encoding UTF8 | Should -BeExactly '77-_'
        ConvertFrom-Base64String '77-_' -Encoding UTF8 | Should -BeExactly $text
        ConvertFrom-Base64String '__s=' | Should -BeExactly ([string][char]0xFBFF)
    }

    It 'accepts padded and unpadded valid input <InputText>' -TestCases @(
        @{ InputText = 'Zg=='; Expected = 'f' }
        @{ InputText = 'Zg'; Expected = 'f' }
        @{ InputText = 'Zm8='; Expected = 'fo' }
        @{ InputText = 'Zm8'; Expected = 'fo' }
        @{ InputText = 'Zm9v'; Expected = 'foo' }
        @{ InputText = " Z g `t`r`n"; Expected = 'f' }
        @{ InputText = " Z g = = `r`n"; Expected = 'f' }
        @{ InputText = 'dGV4dDE'; Expected = 'text1' }
    ) {
        param($InputText, $Expected)
        ConvertFrom-Base64String $InputText -Encoding UTF8 | Should -BeExactly $Expected
    }

    It 'converts empty strings directly and in pipelines' {
        ConvertTo-Base64String '' | Should -BeExactly ''
        ConvertFrom-Base64String '' | Should -BeExactly ''
        ConvertTo-Base64String '' -Encoding UTF8 | Should -BeExactly ''
        ConvertFrom-Base64String '' -Encoding UTF8 | Should -BeExactly ''
        $encoded = @('', 'a' | encode64 -Encoding UTF8)
        $encoded.Count | Should -Be 2
        $encoded[0] | Should -BeExactly ''
        $encoded[1] | Should -BeExactly 'YQ=='
        $decoded = @('', 'YQ==' | decode64 -Encoding UTF8)
        $decoded.Count | Should -Be 2
        $decoded[0] | Should -BeExactly ''
        $decoded[1] | Should -BeExactly 'a'
        ConvertFrom-Base64String " `t`r`n" | Should -BeExactly ''
    }

    It 'rejects malformed Base64 <InputText>' -TestCases @(
        @{ InputText = 'A' }
        @{ InputText = 'AAAAA' }
        @{ InputText = 'Zg=' }
        @{ InputText = 'Zm8==' }
        @{ InputText = 'Zg===' }
        @{ InputText = '=Zg=' }
        @{ InputText = 'Z=g=' }
        @{ InputText = 'Zg==AA==' }
        @{ InputText = '!!!!' }
        @{ InputText = 'Zm$8' }
        @{ InputText = ('Zg' + [char]0xA0) }
    ) {
        param($InputText)
        { ConvertFrom-Base64String $InputText } | Should -Throw
    }
}
