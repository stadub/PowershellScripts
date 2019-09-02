#$DebugPreference = "Continue"

##Account selection

function _Initalize() {

    $script:license=$null

    $script:apiKey = $null
    $script:baseUrl = $null

    $script:apiKeyFile = Get-ProfileDataFile currency-conv ".cur_api_key"

    $script:baseUrlFile = Get-ProfileDataFile currency-conv ".path"


    if( !(Test-Path $script:apiKeyFile)){

        Write-Console "Api key didn't found on the computer. "
        Write-Console "To use the CurrencyConverter api you need to enter your apiKey or receive free api key."

        while ( Test-Empty $script:baseUrl ){
            LicenseTypePrompt
        }
        $script:baseUrl  | Out-File -FilePath $baseUrlFile

        if(  $script:license -ne 'fr' ){
            Read-Host -Prompt "Enter the received api key here: " | Out-File -FilePath $apiKeyFile
        }else{

            Read-Host -Prompt "Please open in the browser link 'https://free.currencyconverterapi.com/free-api-key' and follow the site instructions.`
            Afterwards enter the received api key here: " | Out-File -FilePath $apiKeyFile
            Write-Console "Important: Do not forget to verify your email address."
        }
    }

    Get-Content -Path $apiKeyFile | ForEach-Object{ $script:apiKey= $_}
    Get-Content -Path $baseUrlFile | ForEach-Object{ $script:baseUrl= $_}
}

function LicenseTypePrompt {

    $comercialPath="https://api.currconv.com"
    $freePath= "https://free.currconv.com"

    $reply = Read-Host -Prompt  "Do you have a ApiKey or whant to receive a free one?`
    [C] Have comercial key; [F] Have free api Key; [R] Need a new free registration."
    if (  $reply -match "[Cc]" -and $null -ne $reply ) {  
        $script:baseUrl = $comercialPath
        $script:license = "c"
    }
    if (  $reply -match "[Ff]" -and $null -ne $reply ) {  
        $script:baseUrl = $freePath
        $script:license = "f"

    }
    if (  $reply -match "[Rr]" -and $null -ne $reply ) {  
        $script:baseUrl = $freePath
        $script:license = "fr"
    }
}

#$apiKey = "aa9464c63b35f8a405af"

function PerformWebRequest {
	param (
		[string]$func,
		[string]$arg='a'
    )

    $url= "${baseUrl}/api/v7/${func}?q=${arg}&apiKey=${apiKey}" 
    Write-Debug "Performing web request to ${url}"
    $result= Invoke-WebRequest -Uri  ${url} | ConvertFrom-Json 

    return $result
	
}

<#
.SYNOPSIS
Convert amount from one currency to another

.DESCRIPTION
Perform currency exchange

.PARAMETER From
Base currency name

.PARAMETER To
Resulting currency[Default - USD]

.PARAMETER Amount
Amount to convert [Defult - 1]

.EXAMPLE
Get-ExchangeRate USD BYN 5
Get-ExchangeRate -From USD -To BYN 5
Get-ExchangeRate -Base PHP -Result EUR -Amount 5
([PSCustomObject]@{From="BYN"; To="USD";Value=4}) |  Get-ExchangeRate
([PSCustomObject]@{Base="PHP"; Amount=400})|  Get-ExchangeRate


#>

function Get-ExchangeRate {
	param (
        [Parameter(Position = 0,  ValueFromPipelineByPropertyName  = $True, Mandatory = $true)]
        [Alias("Base")]
        [ValidateScript({$_ -in (Get-Currencies).id})]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $ValidValues = (Get-Currencies).id
                return @($ValidValues) -like "$WordToComplete*"
            }
        )]
        [string]$From,

        [Parameter(Position = 1,  ValueFromPipelineByPropertyName  = $True)]
        [Alias("Result")]
        [ValidateScript({$_ -in (Get-Currencies).id})]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $ValidValues = (Get-Currencies).id
                return @($ValidValues) -like "$WordToComplete*"
            }
        )]
        [string]$To = "USD",

        [Parameter(Position = 2,  ValueFromPipelineByPropertyName  = $True)]
        [Alias("Value", "Count")]
        [decimal] $Amount = 1
	)



#"${from}_${to}%2C${to}_${from}"
    $result = PerformWebRequest "convert" "${From}_${To}"

    $from = $result.results |  Select-Object -ExpandProperty "${from}_${to}" | ForEach-Object{$_.fr}
    $to = $result.results |  Select-Object -ExpandProperty "${from}_${to}" | ForEach-Object{$_.to}
    $val = $result.results |  Select-Object -ExpandProperty "${from}_${to}" | ForEach-Object{$_.val}
    #$from= $result.results."${from}_${to}"
    #$to= $result.results."${to}_${from}"

    $res = new-object PSObject

    $res | add-member -type NoteProperty -Name Date -Value (Get-Date)

    $res | add-member -type NoteProperty -Name From -Value $from 
    $res | add-member -type NoteProperty -Name To -Value $to 
    $res | add-member -type NoteProperty -Name Amount -Value $amount 

    $res | add-member -type NoteProperty -Name Rate -Value $val 
    $res | add-member -type NoteProperty -Name Result -Value ($val * $Amount)
     #$conversion | add-member -type NoteProperty -Name BackRate -Value $to.val `

    return $res

}


function Get-Historical{
    Write-Error "Not implemented yet"
#&date=[yyyy-mm-dd]&endDate=[yyyy-mm-dd]
}

<#
.SYNOPSIS
Countries list with currencies

.DESCRIPTION
Countries list which currencies can be converted

.EXAMPLE
Get-Countries

#>

function Get-Countries {
	
    $result = PerformWebRequest "countries" 
    return $result.results
}

<#
.SYNOPSIS
Supported currencies list

.DESCRIPTION
Supported currencies list

.EXAMPLE
/> Get-Currencies | Where-Object {$_.id -eq "BYN"} 
/> Get-Currencies | %{$_.id}
#>

function Get-Currencies {
	
    $result = PerformWebRequest "currencies" 
    $result.results.PSObject.Properties | ForEach-Object {
        $_.Value
    }
    #return $result.results
}

#Get-Currencies | Where-Object {$_.id -eq "BYN"} 
#Get-Currencies | %{$_.id}
#Get-ExchangeRate USD BYN 5
#Get-ExchangeRate -From USD -To BYN 5
#Get-ExchangeRate -Base USD -Result BYN -Amount 5

#([PSCustomObject]@{From="BYN"; To="USD";Value=4}) |  Get-ExchangeRate

#([PSCustomObject]@{Base="PHP"; Amount=400})|  Get-ExchangeRate


<#
.SYNOPSIS
Remove currconv.com api key fromthe system

.DESCRIPTION
Remove currconv.com api key fromthe system:

#>
function Remove-CurrencyApi-Key {

    rm $script:apiKeyFile

    rm $script:baseUrlFile
}