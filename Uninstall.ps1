
<#PSScriptInfo

.VERSION 1.0

.GUID 27c80b64-2c07-43ee-ae20-4d94965295eb

.AUTHOR dmitry.stadub

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


function Uninstall-Application {
param(
  
  [Parameter(Mandatory=$True, ValueFromPipeline=$True,
  ValueFromPipelineByPropertyName=$True, HelpMessage='Enter the Application to uninstall.')]
  [Alias('Application')]
  [string] $SoftwareName

)

$uninstallX86RegPath="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$uninstallX64RegPath="HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

$uninstallString=""

$uninstall32 = gci $(uninstallX64RegPath) | foreach { gp $_.PSPath } | ? { $_ -like $SoftwareName } | select UninstallString
$uninstall64 = gci $(uninstallX86RegPath) | foreach { gp $_.PSPath } | ? { $_ -like $SoftwareName } | select UninstallString

if($uninstall64) {$uninstallString=$uninstall64;}
if($uninstall32) {$uninstallString=$uninstall32;}

if(!$uninstallString) {
	Write-Error "Application was is not found"
}

	
$uninstallString = $uninstallString.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
$uninstallString = $uninstallString.Trim()
Write "Uninstalling..."

start-process "msiexec.exe" -arg "/X $uninstallString /qb" -Wait

}


export-modulemember -function Uninstall-Application
