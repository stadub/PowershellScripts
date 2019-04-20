
<#PSScriptInfo

.VERSION 1.0

.GUID 27c80b64-2c07-43ee-ae20-4d94965295eb

.AUTHOR Dmitry.Stadub

.COMPANYNAME 

.COPYRIGHT 

.TAGS uninstall msiexec

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
   Uninstall Application
.DESCRIPTION 
  Allows to Uninstall Application from system 
.EXAMPLE
    Uninstall-Application "Microsoft*4.5*"
.PARAMETER SoftwareName
 Application name(Or application name format)
#> 



filter Get-SearchAndPrint() {
    Param ([string]$filterStr = $null)
    $_ | select-string -pattern $filterStr
}

filter Split-String() {
    Param ([string]$separator = $null)
    $_.Split | select-string -pattern $separator
}

function Get-Batchfile ($file) {
    $cmd = "`"$file`" & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        Set-Item -path env:$p -value $v
    }
}
  
function Initialize-VisualStudioEnvieronment($version = "10.0") {
    $key = "HKLM:SOFTWARE\Microsoft\VisualStudio\" + $version
    $VsKey = get-ItemProperty $key
    $VsInstallPath = [System.IO.Path]::GetDirectoryName($VsKey.InstallDir)
    $VsToolsDir = [System.IO.Path]::GetDirectoryName($VsInstallPath)
    $VsToolsDir = [System.IO.Path]::Combine($VsToolsDir, "Tools")
    $BatchFile = [System.IO.Path]::Combine($VsToolsDir, "vsvars32.bat")
    Get-Batchfile $BatchFile
    [System.Console]::Title = "Visual Studio " + $version + " Windows Powershell"
    #add a call to set-consoleicon as seen below...hm...!
}

function Get-CmdletAlias ($cmdletname) {
    get-alias | Where-Object { $_.definition -like "*$cmdletname*" } | Format-Table Definition, Name -auto
}
#function Color-Console
#    {
# $host.ui.rawui.backgroundcolor = "white"
# $host.ui.rawui.foregroundcolor = "black"
#         $hosttime = (dir $pshome\PowerShell.exe).creationtime
#         $Host.UI.RawUI.WindowTitle = "Windows PowerShell $hostversion ($hosttime)"
#         clear-host
#    }
#    Color-console


enum LinkType {
    Symbolic
    Hard
    Junction
}


function New-FileSystemLink {
    [cmdletbinding(DefaultParameterSetName = 'Positional' )]
    param(
        [Parameter(Position = 0, ParameterSetName = 'Positional', ValueFromPipeline = $True, Mandatory = $true)]
        [Alias("-s", "-Source")]
        [string]$source,
  
        [Parameter(Position = 1, ParameterSetName = 'Positional')]
        [Alias("-dest", "-Destanation")]
        [string]$destanation = $((Get-Location).Path),
  
        [Parameter(Position = 2, ParameterSetName = 'Positional', Mandatory = $true)]
        [ServerType]$type = [LinkType]::Symbolic 
  
    )
    New-Item -Path $destanation -ItemType $type -Value $source
}

function Propmpt {
  param (
    [Parameter(Position = 0, ParameterSetName = 'Positional', ValueFromPipeline = $True, Mandatory = $true)]
    [Alias("Question", "-Description")]
    [string]$text
  )
  $reply = Read-Host -Prompt "$text`
  [Y] Yes [N] No [S] Suspend(default is ""Yes""):"

  if (  $reply -match "[yY]" -and $null -ne $reply ) {  
      return $true
  }
  if (  $reply -match "[Ss]" ) { throw "Execution aborted" }
  return $false
}

Set-Alias grep Get-SearchAndPrint
Set-Alias cut Split-String
Set-Alias VsVars32 Initialize-VisualStudioEnvieronment
Set-Alias ga Get-CmdletAlias
Set-Alias fl New-FileSystemLink
Set-Alias pb Export-Module

