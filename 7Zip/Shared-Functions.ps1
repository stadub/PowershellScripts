
function szShow-ConfirmPrompt {
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
Create array from pipeline input

.DESCRIPTION
Create array from pipeline input
Original implementation at https://devblogs.microsoft.com/powershell/converting-to-array/

.EXAMPLE
    $gateway = $properties.GatewayAddresses | ForEach-Object{ [System.Net.IPAddress]::Parse($_.Address.ToString()) } | ToArray

#>

function szToArray
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
Check and create folder

.DESCRIPTION
Check if path and create folder if not exist

.PARAMETER Folder
Path

.EXAMPLE
An example

.NOTES
General notes
#>

function szCreateFolderIfNotExist {
    param ([string]$Folder)
    if( Test-Path $Folder -PathType Leaf){
        Write-Error "The destanation path ${Folder} is file."
    }

    if ( ! (Test-Path $Folder -PathType Container )) { 
        New-Item -Path $Folder  -ItemType 'Directory'
    }
}



 
 filter szLast {
    BEGIN
    {
        $current=$null
    } 
    PROCESS
    {
        $current=$_
    }
    END
    {
        Write-Host  $current
    }
 }

<#
.SYNOPSIS
Download executable from internet

.DESCRIPTION
Check if path and create folder if not exist

.EXAMPLE
An example

.NOTES
General notes
#>
function szReceive-File {
    param (
        [string]$name,
        [string]$file,
        [string]$url
    )
    $reply = szShow-ConfirmPrompt 
    if ( -not $reply  ) {  
        Write-Error "Execution aborted"
        return -1;
    }
    Write-Output "Starting download '$name'"

    Write-Debug "Downoad url:${url}"

    (New-Object System.Net.WebClient).DownloadFile($url, $file)
    
    Write-Debug "File downloaded to ${file}."

}


function szExtract-ZipFile {
    param (
       [ValidateScript( { Test-Path $_  -pathType leaf })] 
        [Parameter(Mandatory = $true)]
        [string]$FileName,
       [ValidateScript( { Test-Path  $_  -pathType Container })] 
       [Parameter(Mandatory = $true)]
        [string]$Path
    )
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($FileName, $Path)
}

function szGet-TempFileName()  {
    return [System.IO.Path]::GetTempFileName()     
}

function szTest-Empty {
    param (
        [Parameter(Position = 0)]
        [string]$string
    )
    return [string]::IsNullOrWhitespace($string) 
}

function szCombine-Path {
    param (
        [string]$baseDir,
        [string]$path
    )
    $allArgs = $PsBoundParameters.Values + $args

    [IO.Path]::Combine([string[]]$allArgs)
}

function szGet-ProfileDir {
    param (
        [string]$moduleName = $null
    )
    
    $profileDir = $ENV:AppData

    if( szTest-Empty $moduleName ){

        if ( $script:MyInvocation.MyCommand.Name.EndsWith('.psm1') ){
            $moduleName = $script:MyInvocation.MyCommand.Name
        }

        if ( $script:MyInvocation.MyCommand.Name.EndsWith('.ps1') ){
            $modulePath = Split-Path -Path $script:MyInvocation.MyCommand.Path
            $moduleName = Split-Path -Path $modulePath -Leaf
        }
    }

    if( szTest-Empty $moduleName ){
        throw "Unable to read module name."             
    }
    
    $scriptProfile =  szCombine-Path $profileDir '.ps1' 'ScriptData' $moduleName
    if ( ! (Test-Path $scriptProfile -PathType Container )) { 
        New-Item -Path $scriptProfile  -ItemType 'Directory'
    }
    return $scriptProfile
}


function szCheckPsGalleryUpdate {
    param (
        [string] $moduleName,
        [string] $currentVersion
    )
   
   Try
   {
    szWrite-Console "Update check..."
       $feed = Invoke-WebRequest -Uri "https://www.powershellgallery.com/api/v2/FindPackagesById()?id=%27$moduleName%27"
       $last=([xml]$feed.Content).feed.entry |Sort-Object -Property updated | szLast 

       $version= $last.properties.Version
   
       if ($version -gt $currentVersion) {
            szWrite-Console "Found a new module version {$version}."
           $notes=$last.properties.ReleaseNotes.'#text'
           szWrite-Console "Release notes: {$notes}."
           szWrite-Console "Recomendent to update module with command: Update-Module -Name $moduleName -Force"
       }
   }
   Catch
   {
   }    
}

function szWrite-Console {
    param (
        [string]$text,
        [String[]]$arg=$null
    )
    if($null -eq $arg){
        [Console]::WriteLine($text)
    }
    else{
        [Console]::WriteLine($text, $arg)
    }
 
}