$marks = @{ }
$marksPath = Join-Path (split-path -parent $profile) .bookmarks

Restore-PSBookmarks

function Restore-PSBookmarks {
	if (test-path $marksPath) {
		Import-Csv $marksPath | ForEach-Object { $marks[$_.key] = $_.value }
	}
}

function Add-PSBookmark () {
    Param (
        [Parameter(Position = 0, Mandatory = $true)]
        [Alias("Name", "Bookmark")]
        $Name,
        [Parameter(Position = 1, ValueFromPipeline  = $True)]
        [string]$dir = $null
    )
    if ( [string]::IsNullOrEmpty($dir) ) {
        $dir = (Get-Location).Path
	}

	Open-PSBookmarks
    $marks["$Name"] = $dir
	Save-PSBookmarks
	Write-Output ("Location '{1}' saved to bookmarks" -f $Name, $dir) 	
}


function Open-PSBookmark() {
    Param(
    [Parameter(Position = 0, ValueFromPipelineByPropertyName  = $True, Mandatory = $true)]
    [Alias("Bookmark")]
    $Name
    )
    Set-Location $marks["$Name"]
}

function Save-PSBookmarks {
    $marks.getenumerator() | export-csv $marksPath -notype
}

function Get-PSBookmarks {
    Open-PSBookmarks
    $marks
}

Set-Alias ba Add-PSBookmark
Set-Alias bo Open-PSBookmark
Set-Alias bv Get-PSBookmarks

$Completion_PSBookmarks = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    Get-PSBookmarks | ForEach-Object { $_.Keys } | Sort-Object | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        New-Object System.Management.Automation.CompletionResult $_, $_, 'ParameterValue', ('{0}' -f $marks[$_]) 
    }
}

if (-not $global:options) { $global:options = @{CustomArgumentCompleters = @{ }; NativeArgumentCompleters = @{ } }
}
$global:options['CustomArgumentCompleters']['Get-PSBookmark:number'] = $Completion_PSBookmarks

Register-ArgumentCompleter -CommandName Get-PSBookmark -ParameterName "number" -ScriptBlock $Completion_PSBookmarks

$function:tabexpansion2 = $function:tabexpansion2 -replace 'End\r\n{', 'End { if ($null -ne $options) { $options += $global:options} else {$options = $global:options}'


