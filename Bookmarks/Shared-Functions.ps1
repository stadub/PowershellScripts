

function CreateFolderIfNotExist {
    param ([string]$Folder)
    if( Test-Path $Folder -PathType Leaf){
        Write-Error "The destanation path ${Folder} is file."
    }

    if ( ! (Test-Path $Folder -PathType Container )) { 
        New-Item -Path $Folder  -ItemType 'Directory'
    }
}


function Test-Empty {
    param (
        [Parameter(Position = 0)]
        [string]$string
    )
    return [string]::IsNullOrWhitespace($string) 
}

function Get-ProfileDataFile {
    param (
        [string]$file,
        [string]$moduleName = $null
    )
    return Join-Path (Get-ProfileDir $moduleName) $file
    
}
function Get-ProfileDir {
    param (
        [string]$moduleName = $null,
        [string]$profileFolder = $null
    )
    
    $profileDir = $ENV:AppData

    if( Test-Empty $moduleName ){

        if ( $script:MyInvocation.MyCommand.Name.EndsWith('.psm1') ){
            $moduleName = $script:MyInvocation.MyCommand.Name
        }

        if ( $script:MyInvocation.MyCommand.Name.EndsWith('.ps1') ){
            $modulePath = Split-Path -Path $script:MyInvocation.MyCommand.Path
            $moduleName = Split-Path -Path $modulePath -Leaf
        }
    }

    if( Test-Empty $moduleName ){
        throw "Unable to read module name."             
    }
    
    $scriptProfile =  Combine-Path $profileDir '.ps1' 'ScriptData' $moduleName

    if( Test-Empty $profileFolder){
        $scriptProfile =  Combine-Path $profileDir '.ps1' 'ScriptData' $moduleName $profileFolder

    }
    if ( ! (Test-Path $scriptProfile -PathType Container )) { 
        New-Item -Path $scriptProfile  -ItemType 'Directory'
    }

    return $scriptProfile
}


function Combine-Path {
    param (
        [string]$baseDir,
        [string]$path
    )
    $allArgs = $PsBoundParameters.Values + $args

    [IO.Path]::Combine([string[]]$allArgs)
}

filter Last {
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
        Write-Output  $current
    }
 }
 
 function CheckPsGalleryUpdate {
    param (
        [string] $moduleName,
        [string] $currentVersion
    )
   
   Try
   {
       Write-Output "Update check..."
       $feed = Invoke-WebRequest -Uri "https://www.powershellgallery.com/api/v2/FindPackagesById()?id=%27$moduleName%27"
       $last=([xml]$feed.Content).feed.entry |Sort-Object -Property updated | Last 

       $version= $last.properties.Version
   
       if ($version -gt $currentVersion) {
           Write-Output "Found a new module version {$version}."
           $notes=$last.properties.ReleaseNotes.'#text'
           Write-Output "Release notes: {$notes}."
           Write-Output "Recomendent to update module with command: Update-Module -Name $moduleName -Force"
       }
   }
   Catch
   {
   }    
}