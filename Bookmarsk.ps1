$marks = @{}

$marksPath = Join-Path (split-path -parent $profile) .bookmarks

if(test-path $marksPath){
	import-csv $marksPath | %{$marks[$_.key]=$_.value}
}

function Set-PSBookmark (){
	Param (
	[Parameter(Mandatory=$true)]
	$number,
	[string]$dir = $null
	)
	if( [string]::IsNullOrEmpty($dir)){
		$dir=(pwd).path;
	}
	$marks["$number"] = $dir;
	echo ("Saved bookmark '{0}' to directory '{1}'" -f $number, $dir) 
    Save-PSBookmarks
}


function Get-PSBookmark(){
	[CmdletBinding()]
	[Parameter(Mandatory=$true)]
    Param($number)
	cd $marks["$number"];
}


function Save-PSBookmarks{
$marks.getenumerator() | export-csv $marksPath -notype
}

function Get-PSBookmarks{
$marks
}

Set-Alias bs Set-PSBookmark
Set-Alias bg Get-PSBookmark
Set-Alias bl Get-PSBookmarks

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


