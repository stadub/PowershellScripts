
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
    if ( [string]::IsNullOrEmpty($dir) ) {
        $dir = (Get-Location).Path
	}

	Restore-PSBookmarks
    $marks["$Name"] = $dir
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
                return @($marks) -like "$WordToComplete*"
            }
        )]
        $Name
    )

	Restore-PSBookmarks
    $marks.Remove($Name)
	Save-PSBookmarks
	Write-Output ("Location '{0}' removed from bookmarks" -f $Name) 	
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
            return @($marks) -like "$WordToComplete*"
        }
    )]
    $Name
    )
    Set-Location $marks["$Name"]
}

function Restore-PSBookmarks {
	if (test-path $marksPath) {
		Import-Csv $marksPath | ForEach-Object { $marks[$_.key] = $_.value }
	}
}
function Save-PSBookmarks {
    $marks.getenumerator() | export-csv $marksPath -notype
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
    $marks
}

$marks = @{ }
$marksPath = Join-Path (split-path -parent $profile) .bookmarks

Restore-PSBookmarks


Export-ModuleMember -Function Add-PSBookmark 
Export-ModuleMember -Function Remove-PSBookmarks
Export-ModuleMember -Function Open-PSBookmark
Export-ModuleMember -Function Get-PSBookmarks
