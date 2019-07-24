
<#
 .Synopsis
   Add folder to bookmarks list.

 .Description
  Add folder to bookmarks list.

 .Parameter Name
  The bookmark name.

 .Parameter Path
  The Path to folder.

 .Example
   # Add bookmark with name.
   ./Add-PSBookmark [ ba ]  BookmarkName (Opt)Directory 

 .Example
   # Add bookmark from pipeline.
   $pwd |  Add-PSBookmark -Name "ThisDirectory"
#>
function Add-PSBookmark () {
    Param (
        [Parameter(Position = 0, Mandatory = $true)]
        [Alias("Bookmark")]
        $Name,
        [Parameter(Position = 1, ValueFromPipeline  = $True)]
        [Alias("Path")]
        [string]$dir = $null
    )
    if ( Test-Empty $dir ) {
        $dir = (Get-Location).Path
	}

	Restore-PSBookmarks
    $_marks["$Name"] = $dir
	Save-PSBookmarks
	Write-Output ("Location '{1}' saved to bookmark '{0}'" -f $Name, $dir) 	
}


<#
 .Synopsis
  Delete bookmark from list.

 .Description
  Removes folder from bookmarks list.

 .Parameter Name
  The bookmark name.
 .Example
   # Add bookmark with name.
   ./Remove-PSBookmark [ br ]  BookmarkName
#>
function Remove-PSBookmark () {
    Param (
        [Parameter(Position = 0, Mandatory = $true)]
        [Alias("Bookmark")]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                return @($_marks) -like "$WordToComplete*"
            }
        )]
        $Name
    )

	Restore-PSBookmarks
    $_marks.Remove($Name)
	Save-PSBookmarks
	Write-Output ("Location '{0}' removed from bookmarks" -f $Name) 	
}

function Remove-AllPSBookmarks {
    $_marks.Clone() | ForEach-Object{$_.keys} | ForEach-Object{$_marks.remove($_)}
    Save-PSBookmarks
}

<#
 .Synopsis
  Open saved bookmark.

 .Description
  Open saved bookmark.

 .Parameter Name
  The bookmark name.
 .Example
   # Add bookmark with name.
   ./Open-PSBookmark [ bo ]  BookmarkName
#>
function Open-PSBookmark() {
    Param(
    [Parameter(Position = 0, ValueFromPipelineByPropertyName  = $True, Mandatory = $true)]
    [Alias("Bookmark")]
    [ArgumentCompleter(
        {
            param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
            return @($_marks) -like "$WordToComplete*"
        }
    )]
    $Name
    )
    Set-Location $_marks["$Name"]
}

function Restore-PSBookmarks {
	if (test-path "$_marksPath" -PathType leaf) {
		Import-Csv $_marksPath | ForEach-Object { $_marks[$_.key] = $_.value }
	}
}
function Save-PSBookmarks {
    $_marks.getenumerator() | export-csv "$_marksPath" -notype
}


<#
 .Synopsis
  List saved bookmark.

 .Description
  List saved bookmark.

 .Example
   # Add bookmark with name.
   ./Get-PSBookmarks [ bl ] [bv]
#>
function Get-PSBookmarks {
    Restore-PSBookmarks
    $_marks.Clone()
}


function Initalize() {
    
    $script:_marks = @{ }
    $script:_marksPath = Get-ProfileDataFile bookmarks

    Write-Debug "Loading ${script:MyInvocation.MyCommand.Name}"
    Restore-PSBookmarks
}


##Load Extra functions


#Truing to get path for ps 3+
#Write-Debug "Truing to assig script info from MyInvocation variable"
#$curScript = $MyInvocation.MyCommand.Source

#and for ps 2
#if( ! $curScript ){
    #Write-Debug "MyInvocation variable doesn't exist trying to set from PSScriptRoot"
    Write-Debug "Trying to set from PSScriptRoot"
    $curScript = (Get-Variable 'PSCommandPath' -Scope 0).Value
#}
$curDir = Split-Path $curScript 

$moduleName = ((Split-Path $curScript -Leaf)  -replace "\.ps.*","")

Write-Debug "Script directory: ${curDir}"
Write-Debug "Script Name: ${moduleName}"


$sharedLoaded = Get-Variable -Name '_sharedLoaded*' -ValueOnly
if( ! $sharedLoaded){
    Write-Debug "No shared functions has been loded."

if(Test-Path ($shared = Join-Path -Path $curDir -ChildPath ".\Shared.ps1" )) {
    . $shared
}
else{
    Write-Debug "Loading shared modules:"

    Join-Path -Path $curDir -ChildPath "..\Shared-Functions\*.ps1"  -Resolve | `
    ForEach-Object{ 
        Write-Debug $PSItem; . $PSItem
    }
}
}

if ( $moduleName -ne 'Functions' ){
    #Write-Output "Module"
    Write-Debug "Loaded as module. Exporting functions"

    Export-ModuleMember -Function Add-PSBookmark 
    Export-ModuleMember -Function Remove-PSBookmarks
    Export-ModuleMember -Function Open-PSBookmark
    Export-ModuleMember -Function Get-PSBookmarks
    Export-ModuleMember -Function Remove-AllPSBookmarks
}
else{
    #file
    #Invoke-ScriptFunction $DestFolder $SrcFolder
}

Initalize