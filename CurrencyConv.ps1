#$DebugPreference = "Continue"

$baseUrl= "https://free.currconv.com"

$binDir="$PSScriptRoot\bin\${MyInvocation.MyCommand.Name}"
$apiKeyFile="${binDir}\.cur_api_key"

$apiKey=$null

if( !(Test-Path $apiKeyFile)){
	Write-Output "Please receive api key at https://free.currencyconverterapi.com/free-api-key"
    Read-Host -Prompt "And paste it here: " |Out-File -FilePath $apiKeyFile
}

Get-Content -Path $apiKeyFile | ForEach-Object{ $apiKey= $_}

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

    $res | add-member -Name Date -Value (Get-Date)

    $res | add-member -type NoteProperty -Name From -Value $from 
    $res | add-member -type NoteProperty -Name To -Value $to 
    $res | add-member -type NoteProperty -Name Amount -Value $amount 

    $res | add-member -type NoteProperty -Name Rate -Value $val 
    $res | add-member -type NoteProperty -Name Result -Value ($val * $Amount)
     #$conversion | add-member -type NoteProperty -Name BackRate -Value $to.val `

    return $res

}


function Get-Historical{

#&date=[yyyy-mm-dd]&endDate=[yyyy-mm-dd]
}

function Get-Countries {
	
    $result = PerformWebRequest "countries" 
    return $result.results
}

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

([PSCustomObject]@{Base="PHP"; Amount=400})|  Get-ExchangeRate

Set-Alias gxc Get-Currencies
Set-Alias xe Get-ExchangeRate