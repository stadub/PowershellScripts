$NoExport = $true
$ModuleDevelopment = $true
$DebugPreference = "Continue"

Set-StrictMode -version Latest

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

. $PSScriptRoot\Shared-Functions.ps1

. $PSScriptRoot\Functions.ps1


$script:license=$null

$script:apiKey = $null
$script:baseUrl = $null

$json='{"query":{"count":1},"results":{"BBD_ALL":{"id":"BBD_ALL","fr":"BBD","to":"ALL","val":55.122849}}}'

$jsonCurr='{"results":
{"ALL":{"currencyName":"Albanian Lek","currencySymbol":"Lek","id":"ALL"},
"BBD":{"currencyName":"Barbadian Dollar","currencySymbol":"$","id":"BBD"}
}}'

$jsonCountries='{"results":
{"AF":{"alpha3":"AFG","currencyId":"AFN","currencyName":"Afghan afghani","currencySymbol":"؋","id":"AF","name":"Afghanistan"},
"AI":{"alpha3":"AIA","currencyId":"XCD","currencyName":"East Caribbean dollar","currencySymbol":"$","id":"AI","name":"Anguilla"},
"AU":{"alpha3":"AUS","currencyId":"AUD","currencyName":"Australian dollar","currencySymbol":"$","id":"AU","name":"Australia"}
}}'

Describe "Get-ExchangeRate" {

    It "Should perform web request" {

        Mock -CommandName PerformWebRequest -Verifiable -MockWith { return $json|ConvertFrom-Json } `
         -ParameterFilter { $func -and $func -eq "convert" }


        Mock -CommandName PerformWebRequest -ParameterFilter   { $func -and $func -eq "currencies" }   `
        -MockWith { return $jsonCurr|ConvertFrom-Json} -Verifiable
        Get-ExchangeRate 'BBD' 'ALL' 5
    }
}

Describe "Get-Countries" {

    It "Should return countries list" {

        Mock -CommandName PerformWebRequest -Verifiable -MockWith { return $jsonCountries|ConvertFrom-Json } `
        -ParameterFilter { $func -and $func -eq "countries" }

        Get-Countries

        Assert-MockCalled  PerformWebRequest 1 
    }

   
}


Describe "Get-Currencies" {

    It "Should return supported currencies" {
        Mock -CommandName PerformWebRequest -ParameterFilter   { $func -and $func -eq "currencies" }   `
        -MockWith { return $jsonCurr|ConvertFrom-Json} -Verifiable

        Get-Currencies

        Assert-MockCalled  PerformWebRequest 1 
    }

}

Describe "PerformWebRequest" {

    It "Requests data from  currconv site" {
        $_marks = @{ }
        $_marks["a"]="A";

        Mock -CommandName Invoke-WebRequest -MockWith {} -Verifiable

        PerformWebRequest "convert" "a_b"

        Assert-MockCalled  Invoke-WebRequest 1 

    }
}