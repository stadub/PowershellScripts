
<#
.SYNOPSIS
Convert text to Base64 String

.DESCRIPTION
Encode provided text to Base64 String

.PARAMETER Value
Value to convert

.EXAMPLE

        ConvertFrom-Base64String "dABlAHgAdAA="
        echo "dABlAHgAdAA=" | decode64 
#>

Function ConvertTo-Base64String {
    param (
        [Parameter(Position = 0, ValueFromPipeline  = $True)]
        [Alias("Text")]
        [string]$Value,
        [Parameter(Position = 1)]
        [bool]$UrlSafe = $false
    )
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($Value)
    $encoded = [Convert]::ToBase64String($bytes)
    if($UrlSafe){
        $encoded = $encoded.TrimEnd('=').Replace('+', '-').Replace('/', '_')
    }
    return $encoded
}


<#
.SYNOPSIS
Convert text from Base 64 String

.DESCRIPTION
Decode provided text to Base64 String

.PARAMETER Value
Value to convert

.EXAMPLE

        ConvertFrom-Base64String "text"
        echo "text" | decode64 
#>
Function ConvertFrom-Base64String {
    param (
        [Parameter(Position = 0, ValueFromPipeline  = $True)]
        [string]$EncodedValue
    )

    $EncodedValue = $EncodedValue.Replace('_', '/').Replace('-', '+')

    if( $EncodedValue.Length%2 -ne 0 ){
        $EncodedValue += '='
    }

    try { 
        $bytes = [System.Convert]::FromBase64String($EncodedValue)
     
    }
    catch {
        $EncodedValue += '=='
        $bytes = [System.Convert]::FromBase64String($EncodedValue)
    }

    $decodedText = [System.Text.Encoding]::Unicode.GetString($bytes)
    return  $decodedText
    
}
