Set-Alias gtb GitGetActiveBarnch -Scope Global

Set-Alias gtbl GitGetBarnches -Scope Global

Set-Alias gtbn GitNewBranch -Scope Global

Set-Alias gtbm GitMoveToBranch -Scope Global

Set-Alias gtm GitMerge -Scope Global

Set-Alias gta GitAddToBranch -Scope Global

Set-Alias gtc GitCommit -Scope Global

Set-Alias gtca GitCommitAll -Scope Global

Set-Alias gtcm GitCommitAmend -Scope Global

Set-Alias gts GitStatus -Scope Global

Set-Alias gtr GitReflog -Scope Global

$gitFnNames = "gt"
function GitFunctions(){
	
	$fName, $rest =  $args
	Write-Debug "Execute function:'$fName' Args:'$rest'"
	$gitAliases = Get-Alias   -Definition "*git*" | where Name -like "${gitFnNames}*"
	$gitAliases| out-string | Write-Debug
	
	$f = $gitAliases | where Name -like "${gitFnNames}${fName}"
	Write-Debug $f
	. $f $rest
}

Set-Alias g GitFunctions -Scope Global