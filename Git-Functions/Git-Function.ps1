function GitGetActiveBarnch(){
	GitGetBarnches | Select-String "^\*" | %{$_.Line.Substring(2)}
}

function GitGetBarnches(){
	git branch 
}

function GitNewBranch(){
	Param (
	[Parameter(Mandatory=$true)]
	[string]$branch
	)
	git checkout -b $branch
}

function GitMoveToBranch(){
	Param (
	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
	[Alias("dest","Destanation")]
	[string]$Branch
	)
	git checkout $Branch
}

function GitMerge(){
	Param (
    [Parameter(Mandatory=$true)]
	[Alias("-dest","-Destanation")]
	[Validatescript({(GitGetBarnches | Select-String "^\s+($_.*)").Matches.Groups[1].Value -eq $_})]
	[string]$destBranch,
	
	[bool]$noFastForward=$true,
	
	[bool]$delete=$true)
	#//git rebase $destBranch
	$active=GitGetActiveBarnch
	if($LastExitCode -ne 0) {
		throw "Error Receiving active Branch"
	}
	git checkout $destBranch
	if($LastExitCode -ne 0) {
		throw "Error Swithing to Branch $destBranch"
	}
	if($noFastForward -eq $true){
		git merge --no-ff $active
	}
	else{
		git merge $active
	}
	
	if($LastExitCode -ne 0) {
		$newActive=GitGetActiveBarnch
		throw "Error merging $active to Branch $destBranch.Current branch is $newActive"
	}
	if($delete -eq $true){
		git branch -d $active
	}
}

function GitAddToBranch(){
	Param (
	#[ValidatePattern("\s")]
	[string]$name
	)
	if($name -ne "*"){
		$files=git status | Select-String "^#\s+\w+:\s+(?<name>$name)"| %{$_.Matches.Groups[1].Value}
	}
	else{
		$files="*"
	}
	git add $files
}


function GitAassumeUnchanged{
	git update-index --assume-unchanged
	#git update-index --no-assume-unchanged 
}

function GitCommit(){
	Param ([string]$message)
	git commit -m $message
	#git commit --amend
}

function GitCommitAmend(){
	Param ([string]$message)
	git commit -m $message --amend
}

function GitCommitAll(){
	Param ([string]$message)
	git commit -a -m $message
}

function GitStatus(){
	Param ([string]$args)
	git status $args
}


function GitSquash(){
	Param (
	[int]$count=4
	)
	. "git rebase -i HEAD~$count"

}
function GirReflog(){
	Param ([bool]$all=$false)
	if($all -eq $false)
	{
		git reflog --all
	}
	else
		{
		git reflog
	}
}
