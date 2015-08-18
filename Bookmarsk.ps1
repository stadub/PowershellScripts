$marks = @{}
$marksPath = Join-Path (split-path -parent $profile) .bookmarks

if(test-path $marksPath){
	import-csv $marksPath | %{$marks[$_.key]=$_.value}
}

function Save-PSBookmark (){
	Param (
	[Parameter(Mandatory=$true)]
	$name,
	[string]$dir = $null
	)
	if( [string]::IsNullOrEmpty($dir)){
		$dir=(pwd).path;
	}
	$marks["$name"] = $dir;
	echo ("Saved bookmark '{0}' to directory '{1}'" -f $name, $dir) 
    Save-PSBookmarks
}


function Load-PSBookmark(){
	[CmdletBinding()]
	[Parameter(Mandatory=$true)]
    Param($name)
	cd $marks["$name"];
}


function Save-PSBookmarks{
$marks.getenumerator() | export-csv $marksPath -notype
}

function List-PSBookmarks{
$marks
}

Set-Alias bs Save-PSBookmark
Set-Alias bl Load-PSBookmark
Set-Alias bv List-PSBookmarks

$Completion_PSBookmarks = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    Get-PSBookmarks |  ForEach-Object { $_.Keys }  |Sort-Object | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        New-Object System.Management.Automation.CompletionResult $_, $_, 'ParameterValue', ('{0}' -f $marks[$_]) 
    }
}

if (-not $global:options) { $global:options = @{CustomArgumentCompleters = @{};NativeArgumentCompleters = @{}}}
$global:options['CustomArgumentCompleters']['Get-PSBookmark:number'] = $Completion_PSBookmarks

Register-ArgumentCompleter -CommandName Get-PSBookmark -ParameterName "number" -ScriptBlock $Completion_PSBookmarks

$function:tabexpansion2 = $function:tabexpansion2 -replace 'End\r\n{','End { if ($null -ne $options) { $options += $global:options} else {$options = $global:options}'


