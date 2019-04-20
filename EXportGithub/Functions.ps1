
<#PSScriptInfo

.VERSION 1.1

.GUID 2c1b4da3-c20e-475a-8584-70326e3bee43

.AUTHOR Dima Stadub

.COMPANYNAME 

.COPYRIGHT 

.TAGS github.com github download DownloadGithub GithubDownload ExportGithub GithubExport GetGithub zip archive

.LICENSEURI 

.PROJECTURI https://github.com/stadub/PowershellScripts

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#> 


<#
.SYNOPSIS
  Download github repo and execute repo script
.DESCRIPTION
  Allow to download git repo from github unpack it and start config script.
  Supported bouth url bases configuration and User/Repo/Branch parametrs
.EXAMPLE
   echo "https://github.com/dotnet/core/tree/2.2.103" | ExportGithub  (will download to current directory)
   
   ExportGithub "https://github.com/torvalds/linux/archive/master.zip" "C:\Sources\Linux" 
   
   ExportGithub "https://github.com/stadub/CmdScripts/archive/master.zip" "C:\CmdScripts\Cmd" "InstallBin.cmd" (Download to specific directory and start script)
   
   ExportGithub -User electron -Repo electron -Branch chromium-upgrade/73 -Destanation "C:\Sources\Electron"  InstallScript="npm install"
   
   ExportGithub -User Microsoft -Repo vscode (download the main repo to current directory)
   
   ExportGithub "https://github.com/stadub/CmdScripts/archive/master.zip" "C:\CmdScripts\Cmd" "InstallBin.cmd"
.PARAMETER Repo
   Github repository url(browser url pointed on repo)
.PARAMETER Destanation (optional)
   Destanation folder where will be unpacked github repo
.PARAMETER InstallScript (optional)
   Script ile to be invocked after repo unpacking
  #>
[cmdletbinding(DefaultParameterSetName = 'Url' )]
param(
    [Parameter(Position = 0, ParameterSetName = 'Url', ValueFromPipeline = $True, Mandatory = $true)]
    [string]$Url,
  
  
    [Parameter(Position = 0, ParameterSetName = 'RepoInfo', Mandatory = $true)]
    [string]$User,  
    [Parameter(Position = 1, ParameterSetName = 'RepoInfo', Mandatory = $true)]
    [string]$Repo,
    [Parameter(Position = 2, ParameterSetName = 'RepoInfo', Mandatory = $true)]
    [string]$Branch = "master",
  
    [Parameter(Position = 1, ParameterSetName = 'Url')]
    [Parameter(Position = 3, ParameterSetName = 'RepoInfo')]
    [Alias("-dest", "-Destanation")]
    [string]$Destanation = $((Get-Location).Path),
  
    [Parameter(Position = 2, ParameterSetName = 'Url')]
    [Parameter(Position = 4, ParameterSetName = 'RepoInfo')]
    [string]$InstallScript = ""
)
$githubUriRegex = "(?<Scheme>https://)(?<Host>github.com)/(?<User>\w*)/(?<Repo>\w*)(/tree/(?<Branch>.*))?(/archive/(?<Branch>.*).zip)?"

$githubMatch = [regex]::Match($Url, $githubUriRegex)

function GetGroupValue($match, [string]$group, [string]$default = "") {
    $val = $match.Groups[$group].Value
    Write-Debug $val
    if ($val) {
        return $val
    }
    return $default
}

if ( ! $(GetGroupValue $githubMatch "Host") ) {
    throw [System.ArgumentException] "Incorrect 'Host' value. The 'github.com' domain expected"
    #Write-Error -Message "Incorrect 'Host' value. The 'github.com' domain expected" -Category InvalidArgument
}

#Becouse url can be in different formats 
$githubUrl = 'https://github.com/{0}/{1}/archive/{2}.zip' -f 
$(GetGroupValue $githubMatch "User"),
$(GetGroupValue $githubMatch "Repo"), 
$(GetGroupValue $githubMatch "Branch" "master")


$file = [System.IO.Path]::GetTempFileName() + ".zip"

New-Object System.Net.WebClient | ForEach-Object { $_.DownloadFile($githubUrl, $file); }


if ( -Not $(Test-Path -path $Destanation)) {
    mkdir $Destanation
}
else {
    Write-Warning "'$Destanation' already exists."  -warningaction Inquire
}

if ( !  (ExtractByDotNet) )
{
    if ( -Not  (ExtractComWay) )
    {
        throw "Error excracting archive, no suatable archiver is found"
    }
    
}

if ( $InstallScript ) {
    if ( Test-Path -path $Destanation\$InstallScript) {
        &  $Destanation\$InstallScript
    }
    else {
        Write-Warning "Installer script is not found executing application globaly."
        &  $InstallScript
    }
}

function ExtractByDotNet() {
    Try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($file, $Destanation)
        return $true
    }
    Catch {
        Write-Warning  $_.Exception
    }
}

function ExtractComWay() {
    Try {
        $sh = New-Object -ComObject Shell.Application

        $archive = $sh.NameSpace($file).Items();

        #archive contain root folder. So get folder content
        $archiveFilder = $archive.Item(0).GetFolder.Items()


        $dst = $sh.NameSpace($Destanation)
        $dst.CopyHere($archiveFilder, 272)
        return $true
    }
    Catch {
        Write-Warning  $_.Exception
    }
}

