
function _Initalize() {
    $script:_marksPath = Get-ProfileDataFile bookmarks "Bookmarks"
}


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

    $_marks = Import-PSBookmarks

    if( $_marks.ContainsKey("$Name") ){
        throw "Folder bookmark ''$Name'' already exist"
    }

    $_marks["$Name"] = $dir
	Save-PSBookmarks $_marks
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

    $_marks = Import-PSBookmarks

    $_marks.Remove($Name)
	Save-PSBookmarks $_marks
	Write-Output ("Location '{0}' removed from bookmarks" -f $Name) 	
}

function Remove-AllPSBookmarks {
    $_marks = @{ }
    Save-PSBookmarks $_marks
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
    $_marks = Import-PSBookmarks
    Set-Location $_marks["$Name"]
}

function Import-PSBookmarks {
    $_marks = @{ }
	if (test-path "$script:_marksPath" -PathType leaf) {
		Import-Csv  $script:_marksPath | ForEach-Object { $_marks[$_.key] = $_.value }
    }
    return $_marks
}

function Save-PSBookmarks {
    param (
        $marks
    )    
    $marks.getenumerator() | export-csv "$_marksPath" -notype
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
    $_marks = Import-PSBookmarks
    $_marks.Clone()
}



<#
 .Synopsis
   Update folder location in the bookmarks list

 .Description
  Update folder location in the bookmarks list

 .Parameter Name
  The bookmark name.

 .Parameter Path
  The Path to folder.

 .Example
   # Update bookmark with name.
   ./Update-PSBookmark [ bu ]  BookmarkName (Opt)Directory 

 .Example
   # Update bookmark from pipeline.
   $pwd |  Update-PSBookmark -Name "ThisDirectory"
#>
function Update-PSBookmark () {
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
    
    $_marks = Import-PSBookmarks

    if( -not  $_marks.ContainsKey("$Name") ){
        throw "Folder bookmark ''$Name'' doesn't exist"
    }

    $_marks["$Name"] = $dir
	Save-PSBookmarks $_marks
	Write-Output ("The bookmark {0} updated with location '{1}'" -f $Name, $dir) 	
}