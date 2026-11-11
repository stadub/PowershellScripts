<#
.SYNOPSIS
Convert text to a Base64 string.
.DESCRIPTION
Encodes text using Unicode (UTF-16 little-endian) by default, without a byte order mark.
.PARAMETER Value
Text to encode. Accepts pipeline input, including empty strings.
.PARAMETER UrlSafe
Replace + and / with - and _ and omit trailing padding when true.
.PARAMETER Encoding
Text encoding: Unicode (default), UTF8, BigEndianUnicode, UTF32, or ASCII.
Use the same encoding when decoding; Base64 does not record the text encoding.
.EXAMPLE
ConvertTo-Base64String "text"
.EXAMPLE
"text" | encode64 -Encoding UTF8 -UrlSafe $true
#>
Function ConvertTo-Base64String {
    param (
        [Parameter(Position = 0, ValueFromPipeline = $True)]
        [AllowEmptyString()]
        [Alias("Text")]
        [string]$Value,
        [Parameter(Position = 1)]
        [bool]$UrlSafe = $false,
        [Parameter(Position = 2)]
        [ValidateSet('Unicode', 'UTF8', 'BigEndianUnicode', 'UTF32', 'ASCII')]
        [string]$Encoding = 'Unicode'
    )
    process {
        $bytes = [System.Text.Encoding]::$Encoding.GetBytes($Value)
        $encoded = [Convert]::ToBase64String($bytes)
        if ($UrlSafe) {
            $encoded = $encoded.TrimEnd('=').Replace('+', '-').Replace('/', '_')
        }
        $encoded
    }
}

<#
.SYNOPSIS
Convert a Base64 string to text.
.DESCRIPTION
Accepts standard or URL-safe Base64, with or without padding. Decodes using
Unicode (UTF-16 little-endian) by default. Malformed Base64 raises an error.
.PARAMETER EncodedValue
Base64 to decode. Accepts pipeline input, including empty strings.
.PARAMETER Encoding
Text encoding: Unicode (default), UTF8, BigEndianUnicode, UTF32, or ASCII.
Must match the encoding used to create the Base64 string.
.EXAMPLE
ConvertFrom-Base64String "dABlAHgAdAA="
.EXAMPLE
"dGV4dA" | decode64 -Encoding UTF8
#>
Function ConvertFrom-Base64String {
    param (
        [Parameter(Position = 0, ValueFromPipeline = $True)]
        [AllowEmptyString()]
        [string]$EncodedValue,
        [Parameter(Position = 1)]
        [ValidateSet('Unicode', 'UTF8', 'BigEndianUnicode', 'UTF32', 'ASCII')]
        [string]$Encoding = 'Unicode'
    )
    process {
        # Ignore only the whitespace accepted by Convert.FromBase64String.
        $normalized = ($EncodedValue -replace '[ \t\r\n]', '').Replace('_', '/').Replace('-', '+')
        # Restore padding only for fully unpadded input. Existing padding must
        # already be complete; impossible lengths and invalid characters are
        # rejected by FromBase64String rather than repaired by a retry.
        if (-not $normalized.Contains('=')) {
            switch ($normalized.Length % 4) {
                2 { $normalized += '==' }
                3 { $normalized += '=' }
            }
        }
        try {
            $bytes = [System.Convert]::FromBase64String($normalized)
        }
        catch {
            throw
        }
        [System.Text.Encoding]::$Encoding.GetString($bytes)
    }
}
