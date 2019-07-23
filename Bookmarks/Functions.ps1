
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

    Write-Debug "Loading ${MyInvocation.MyCommand.Name}"
    Restore-PSBookmarks
}


##Load Extra functions

#Truing to get path for ps 3+
$curDir = $MyInvocation.MyCommand.Path

#and for ps 2
if( ! $curDir ){
    $curDir = $PSScriptRoot
}else{
    $curDir = Split-Path $curDir
}

$sharedLoaded = Get-Variable -Name '_sharedLoaded*' -ValueOnly
if( ! $sharedLoaded){

if(Test-Path ($shared = Join-Path -Path $curDir -ChildPath ".\Shared.ps1" )) {
    . $shared
}
else{
    Write-Output "Loading shared modules:"

    Join-Path -Path $curDir -ChildPath "..\Shared-Functions\*.ps1"  -Resolve | `
    ForEach-Object{ 
        Write-Output $PSItem; . $PSItem
    }
}
}

if ( $MyInvocation.MyCommand.Name.EndsWith('.psm1') ){
    #Write-Output "Module"
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