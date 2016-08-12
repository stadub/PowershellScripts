param(
  [parameter(Mandatory=$true)]
  [string]$githubRepo,
  [parameter(Mandatory=$true)]
  [string]$destDir,
  [string]$installScrip=""
)
$githubUriRegex="(?<Scheme>https://)(?<Host>github.com)/(?<User>\w*)/(?<Repo>\w*)(/archive/(?<Branch>master).zip)?"

$githubMatch = [regex]::Match($githubRepo,$githubUriRegex)

function GetGroupValue($match, [string]$group, [string]$default=""){
	$val=$match.Groups[$group].Value
	Write-Debug $val
	if($val){
		return $val
	}
	return $default
}

if( ! $(GetGroupValue $githubMatch "Host") ){
	throw [System.ArgumentException] "Incorrect 'Host' value. The 'github.com' domain expected"
	#Write-Error -Message "Incorrect 'Host' value. The 'github.com' domain expected" -Category InvalidArgument
}

#Becouse url can be in different formats 
$githubUrl='https://github.com/{0}/{1}/archive/{2}.zip' -f 
						$(GetGroupValue $githubMatch "User"),
						$(GetGroupValue $githubMatch "Repo"), 
						$(GetGroupValue $githubMatch "Branch" "master")


$file = [System.IO.Path]::GetTempFileName() + ".zip"

New-Object System.Net.WebClient|%{$_.DownloadFile($githubUrl,$file);}
$sh = New-Object -ComObject Shell.Application

$archive=$sh.NameSpace($file).Items();

#archive contain root folder. So get folder content
$archiveFilder=$archive.Item(0).GetFolder.Items()

if ( -Not $(Test-Path -path $destDir)){
	mkdir $destDir
}
else{
	Write-Warning "'$destDir' already exists."  -warningaction Inquire
}

$dst=$sh.NameSpace($destDir)
$dst.CopyHere($archiveFilder, 272)

if( $installScrip ){
	if ( Test-Path -path $destDir\$installScrip){
		&  $destDir\$installScrip
	}
	else{
		Write-Warning "Installer script is not found."
	}
}


