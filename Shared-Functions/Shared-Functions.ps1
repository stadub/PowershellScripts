
<#
.SYNOPSIS
Simple wrapper ower `Read-Host` intendend to show "[Yes]/[No]" questions

.DESCRIPTION
Simple wrapper ower `Read-Host` intendend to show "[Yes]/[No]" questions

.PARAMETER text
Text to be shown in the prompt

.EXAMPLE
  $reply = Show-ConfirmPrompt "Would you like to continue?"
    if ( -not $reply  ) {  
        return
    }
#>

function Show-Prompt {
    param (
        [Parameter(Position = 0, ParameterSetName = 'Positional', ValueFromPipeline = $True)]
        [Alias("Question", "Description")]
        $text ="Would you like to continue?"
    )
    $reply = Read-Host -Prompt "$text`
    [Y] Yes [N] No [S] Suspend(default is ""Yes""):"

    if (  $reply -match "[yY]" -and $null -ne $reply ) {  
        return $true
    }
    if (  $reply -match "[Ss]" ) { throw "Execution aborted" }
    return $false
}

<#
.SYNOPSIS
Read apiKey(or other information) from input and store it to file
.DESCRIPTION
Long description

.PARAMETER apiKey
Reference to the api key value received from the command prompt

.PARAMETER fileName
Filename to save key

.PARAMETER regUrl
Help url with description or registration

.EXAMPLE
    Read-ApiKey $ghApiKeyRef gh "https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line"

    $keyRef=([ref]$apiKey)
    Read-ApiKey $keyRef nuget "https://www.powershellgallery.com/account/apikeys"
    Publish-Module -Name ./*.psd1  -NuGetApiKey $keyRef.Value

#>

function Read-ApiKey {
    param (
        [ref]$apiKey = $null,
        [string]$fileName,
        [string]$regUrl
    )
    if(!!(("${apiKey.Value}").Trim()))
    {
        return $true
    }
    #get api key
    $apiKeyFile = Join-Path (split-path -parent $profile) ".${fileName}_api_key"
    
    if ( !(Test-Path $apiKeyFile)) {
        $apiKey = Read-Host -Prompt  "Please Enter the api key received at $regUrl`
        And paste it here: "
      
        $reply = Show-ConfirmPrompt "Would you like to store it?"
        if (  $reply  ) {  
            $apiKey.Value | Out-File -FilePath $apiKeyFile
        }
    }
    else {
        Get-Content -Path $apiKeyFile | ForEach-Object { $apiKey.Value = $_ }
    }
    return $true
}

<#
.SYNOPSIS
Create array from pipeline input

.DESCRIPTION
Create array from pipeline input
Original implementation at https://devblogs.microsoft.com/powershell/converting-to-array/

.EXAMPLE
    $gateway = $properties.GatewayAddresses | ForEach-Object{ [System.Net.IPAddress]::Parse($_.Address.ToString()) } | ToArray

#>

function ToArray
{
  begin
  {
    $output = @(); 
  }
  process
  {
    $output += $_; 
  }
  end
  {
    return ,$output; 
  }
}


<#
.SYNOPSIS
Merge two hashtables into one

.DESCRIPTION
Add elemtns from $second hastable(or any dictionary based structure) to $first

.PARAMETER first
Hashtable to add key/value pairs

.PARAMETER second
Hashtable key/values to be added to $first

.EXAMPLE

        $q = @{a=1;b=4;c=3}        
        [ordered]$w = @{a=2;b=1;c=5;d=6}
        MergeHashtable $q $w
#>

  function MergeHashtable {
      param (
          [Alias("To")]
          [Parameter(Position = 0, ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
          [System.Collections.IDictionary]$first,
  
          [Alias("From")]
          [Parameter(Position = 1, ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
          [System.Collections.IDictionary]$second
      )
      $second.Keys | ForEach-Object{
          $first[$_] = $second[$_];
      }
  }

  function LoadModules {
      param (
          [bool]$local = $false,
          [Parameter(Mandatory = $true)]
          [string]$functionsFolder,
          [string]$sharedFolder = $PSScriptRoot
      )

      $functions  = @( Get-ChildItem -Path $functionsFolder\*.ps1 -ErrorAction SilentlyContinue )
      $shared = @( Get-ChildItem -Path $sharedFolder\*.ps1 -ErrorAction SilentlyContinue )
      
      Foreach($import in @($Public + $functions))
      {
          Try
          {
              . $import.fullname
          }
          Catch
          {
              Write-Error -Message "Failed to import function $($import.fullname): $_"
          }
      }


    ##



# Add the functions into the runspace
GetScriptFunctions $functions | ForEach-Object {
    $rs.SessionStateProxy.InvokeProvider.Item.Set(
        'function:\{0}' -f $_.Name,
        $_.Body.GetScriptBlock()) 
}
  }
<#
.SYNOPSIS
#

.DESCRIPTION
This function is based on https://stackoverflow.com/a/45929412/959779

.PARAMETER scriptFile
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>

function GetScriptFunctions {
    param (
        [string]$scriptFile
    )
    # Get the AST of the file
    $tokens = $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile(
        $scriptFile,
        [ref]$tokens,
        [ref]$errors)

    # Get only function definition ASTs
    $functionDefinitions = $ast.FindAll({
        param([System.Management.Automation.Language.Ast] $Ast)

        $Ast -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
        # Class methods have a FunctionDefinitionAst under them as well, but we don't want them.
        ($PSVersionTable.PSVersion.Major -lt 5 -or
        $Ast.Parent -isnot [System.Management.Automation.Language.FunctionMemberAst])

    }, $true)
    return $functionDefinitions
}