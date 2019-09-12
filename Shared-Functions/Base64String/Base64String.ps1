
<#
.SYNOPSIS
Convert text to Base64 String

.DESCRIPTION
Encode provided text to Base64 String

.PARAMETER Value
Value to convert

.EXAMPLE

        ConvertTo-Base64String "text"
        echo "text" | encode64 
#>

Function ConvertTo-Base64String {
    param (
        [Parameter(Position = 0, ValueFromPipeline  = $True)]
        [string]$Value
    )
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($Value)
    $encoded =[Convert]::ToBase64String($bytes)
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
    $bytes = [System.Convert]::FromBase64String($EncodedValue)
    $decodedText = [System.Text.Encoding]::Unicode.GetString($bytes)
    return  $decodedText
    
    }
