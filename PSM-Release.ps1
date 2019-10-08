

function UpdateVersion {
    param (
        [Parameter(Position = 0, ParameterSetName = 'Positional', ValueFromPipeline = $True)]
        [Alias("s", "Source")]
        [string]$path = $((Get-Location).Path),
        [Parameter(Position = 1, ParameterSetName = 'Positional', ValueFromPipelineByPropertyName = $True)]
        [Alias("Info", "Notes")]
        [string]$ReleaseNotes = $null
    )
    Push-Location $path

    $file = Get-ChildItem ./*.psd1
    $infos = Import-PowerShellDataFile -Path $file.FullName

    #update versions
    $psdVerRegex = "ModuleVersion = '(?<Major>\d+)\.(?<Minor>\d+)\.(?<Build>\d+)'"

    $Major=1
    $Minor=1
    $Build=1
    $content = [System.IO.File]::ReadAllText($file.FullName)

    $newVersion="$Major.$Minor.$Build"
    $replacedString = [Regex]::Replace($content, $psdVerRegex, $newVersion);

    [System.IO.File]::WriteAllText($file.FullName, $replacedString)


    if($ReleaseNotes = $null){ $ReleaseNotes = Read-Host -Prompt  "Please enter the new version ReleaseNotes" }
    $infos.PrivateData.PSData.ReleaseNotes = $ReleaseNotes


    $mdFileVersionRegex = "https://www.powershellgallery.com/packages/${file.Name}/(?<version>((\d+)(\.*))*)"

    $content = [System.IO.File]::ReadAllText("README.md")
    $replacedString = [Regex]::Replace($content, $mdFileVersionRegex, $newVersion);

    [System.IO.File]::WriteAllText($file.FullName, $replacedString)


    $changeLogAdd="
    ### [v${newVersion}](https://github.com/thoemmi/7Zip4Powershell/releases/tag/v1.9)
    
    * Updated 7-Zip dlls to 16.04
    * Disabled the `CustomInitialization` parameter for `Expand-7Zip`, will be removed in future versions.
    "

    $content = [System.IO.File]::ReadAllText("../README.md")
    $replacedString = [Regex]::Replace($content, $mdFileVersionRegex, $newVersion);

    [System.IO.File]::WriteAllText($file.FullName, $replacedString)
    Pop-Location
}

function GetGroupValue($match, [string]$group, [string]$default = "") {
    $val = $match.Groups[$group].Value
    Write-Debug $val
    if ($val) {
        return $val
    }
    return $default
}

function Export-GithubModule() {
    param(
        [Parameter(Position = 0, ParameterSetName = 'Positional', ValueFromPipeline = $True)]
        [Alias("s", "Source")]
        [string]$path = $((Get-Location).Path),
        [Parameter(Position = 1, ParameterSetName = 'Positional', ValueFromPipelineByPropertyName = $True)]
        [Alias("v", "Release")]
        [string]$version,
        [Parameter(Position = 2, ParameterSetName = 'Positional', ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        [Alias("Info", "Notes")]
        [string]$ReleaseNotes,
        [Parameter(Position = 3, ParameterSetName = 'Positional', ValueFromPipelineByPropertyName = $True, Mandatory = $false)]
        [Alias("GitHubKey")]
        [string]$ghApiKey = $null
    )

    Set-Location $path

#git log origin/master..master


    #20b8e8faa2c5062448ae6c36cc9677db4fadbbdb
    #get github api key
    $ghApiKeyRef=([ref]$ghApiKey)
    Read-ApiKey $ghApiKeyRef gh "https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line"
    
    $ghApiKey = $ghApiKeyRef.Value

    #parse repo
    $Url = git remote -v
    
    $githubUriRegex = "(?<Scheme>https://)(?<Host>github.com)/(?<User>\w*)/(?<Repo>\w*)(/tree/(?<Branch>.*))?(/archive/(?<Branch>.*).zip)?"

    $githubMatch = [regex]::Match($Url, $githubUriRegex)
    
    
    if ( ! $(GetGroupValue $githubMatch "Host") ) {
        throw [System.ArgumentException] "Incorrect 'Host' value. The 'github.com' domain expected"
        #Write-Error -Message "Incorrect 'Host' value. The 'github.com' domain expected" -Category InvalidArgument
    }
    
    #Becouse url can be in different formats 


    $branch = git branch | %{ $_.split()[1]}
    $user = $(GetGroupValue $githubMatch "User");
    $repo = $(GetGroupValue $githubMatch "Repo");

    $CreateReleaseUrl = 'https://api.github.com/repos/{0}/{1}/releases' -f $user, $repo
    $LatestReleaseUrl = 'https://api.github.com/repos/{0}/{1}/releases/latest' -f $user, $repo


    $buildVersionRegex= "v(?<Major>\d+)\.(?<Minor>\d+)\.(?<Build>\d+)"

    $latestRelease=Invoke-WebRequest -Uri $LatestReleaseUrl -Headers @{"Authorization"="token ${ghApiKey}"} 
    $js= $latestRelease.Content| ConvertFrom-Json
    $buildTag = $js.tag_name
  echo "$buildTag"

    $tagMatch = [regex]::Match($buildTag, $buildVersionRegex)

    $Major = $(GetGroupValue $tagMatch "Major") -as [int];
    $Minor = $(GetGroupValue $tagMatch "Minor") -as [int];
    $Build = $(GetGroupValue $tagMatch "Build") -as [int];

    Write-Output "Latest build ${Major}.${Minor}.${Build}"

    if ( [string]::IsNullOrWhiteSpace($ReleaseNotes)){

        $reply = Read-Host -Prompt "Enter the ReleaseNotes fro the release: "
        if ( ! [string]::IsNullOrWhiteSpace($reply)) {  $ReleaseNotes = $reply }
    }

    if ( [string]::IsNullOrWhiteSpace($version)){

        $reply = Read-Host -Prompt "Enter the Major release version.[$Major]"
        if ( ! [string]::IsNullOrWhiteSpace($reply)) {  $Major = $reply -as [int] }

        $reply = Read-Host -Prompt "Enter the Minor release version.[$Minor]"
        if ( ! [string]::IsNullOrWhiteSpace($reply)) {  $Minor = $reply -as [int] }

        $reply = Read-Host -Prompt "Enter the Build release version.[$Build]"
        if ( ! [string]::IsNullOrWhiteSpace($reply)) {  $Build = $reply -as [int] }

        $ver = "v${Major}.${Minor}.${Build}"
    }

    Write-Output "New release will be created for version : $ver and branch $branch"
    Write-Output "Release description : $ReleaseNotes"

    $reply = Show-ConfirmPrompt 
    if ( -not $reply  ) {  
        return
    }

    $body = @{
        "tag_name"= $ver
        "target_commitish"= $branch
        "name"=  $ver
        "body"= $ReleaseNotes
        "draft"= $false
        "prerelease"= $false

       } | ConvertTo-Json


    Write-Debug $LatestReleaseUrl

    Invoke-WebRequest -Uri $CreateReleaseUrl -Method POST -Body $body -Headers @{"Authorization"="token ${ghApiKey}"}

}

function Get-Guid  {
    [guid]::NewGuid()    
}

function Export-Module {
    param(
        [Parameter(Position = 0, ParameterSetName = 'Positional', ValueFromPipeline = $True)]
        [Alias("s", "Source")]
        [string]$path = $((Get-Location).Path),
        [Parameter(Position = 1, ParameterSetName = 'Positional', ValueFromPipeline = $True)]
        [Alias("d", "Destanation")]
        [string]$dest = "./Export/Module",
        [Parameter(Position = 2, ParameterSetName = 'Positional', ValueFromPipeline = $True)]
        [Alias("d", "SharedFunctionsDir")]
        [string]$sharePath = "../\#Shared"
    )
    Export-Scripts $path $dest $sharePath
}

function Export-Function {
    param(
        [Parameter(Position = 0, ParameterSetName = 'Positional', ValueFromPipeline = $True)]
        [Alias("s", "Source")]
        [string]$path = $((Get-Location).Path),
        [Parameter(Position = 1, ParameterSetName = 'Positional', ValueFromPipeline = $True)]
        [Alias("d", "Destanation")]
        [string]$dest = "./Export/Function",
        [Parameter(Position = 2, ParameterSetName = 'Positional', ValueFromPipeline = $True)]
        [Alias("d", "SharedFunctionsDir")]
        [string]$sharePath = "../\#Shared"
    )
    Export-Scripts $path $dest $sharePath
}

function Export-Scripts {
    param(
        [string]$path,
        [string]$dest,
        [string]$sharePath
    )
    
    Write-Output "Exporting the ${path}"
    Push-Location $path

    #export folder
    if ( Test-Path $dest ){
        mkdir $dest
    }

    if ( Test-Path $dest ){
        mkdir $dest
    }
    
    mkdir $dest/Functions
    Copy-Item *.ps*1 $dest/Functions
    Get-Content $dest/Functions/*.ps1 | Set-Content functions.ps1
    

    #export shared
    if( $sharePath -ne $null ){
        mkdir $dest/Shared
        Copy-Item "$sharePath/*.ps*1" $dest 
        Get-Content $dest/Shared/*.ps1 | Set-Content allShared.ps1
    }
    else{
        mkdir $dest/Shared
        Write-Output "" > Set-Content allShared.ps1
    }
    Get-Content $dest/Shared/allShared.ps1, $dest/Functions/functions.ps1 | Set-Content $dest/Psm/Functions.ps1
    Copy-Item $dest/*.psd1 $dest/Psm/*.psd1 
}

function Export-Module() {
    param(
        [Parameter(Position = 0, ParameterSetName = 'Positional', ValueFromPipeline = $True)]
        [Alias("s", "Source")]
        [string]$path = $((Get-Location).Path),
        [Parameter(Position = 1, ParameterSetName = 'Positional', ValueFromPipelineByPropertyName = $True)]
        [Alias("Key")]
        [string]$apiKey = $null
    )
    #oy2aodasx3dppjelcfkqko6ybauce6ne5gn5m7qep2q4bi
    #get api key
    $keyRef=([ref]$apiKey)
    Read-ApiKey $keyRef nuget "https://www.powershellgallery.com/account/apikeys"

    Write-Output "Exporting the ${path}"
    Push-Location $path

    #export folder
    mkdir Export
    
    mkdir Export/Functions
    Copy-Item *.ps*1 ./Export/Functions

    #export shared
    mkdir Export/Shared
    Copy-Item '../\#Shared/*.ps*1' ./Export 
    Get-Content Export/Shared/*.ps1 | Set-Content allShared.ps1

    mkdir Export/Psm
    Get-Content Export/Shared/allShared.ps1, ./Export/Functions/*.ps1 | Set-Content ./Export/Psm/Functions.ps1
    Copy-Item Export/*.psd1 Export/Psm/*.psd1 

    mkdir Export/Pss
    $funcName = Get-ChildItem *.ps1 | ForEach-Object{$_.Name}
    Get-Content ./Export/Shared/allShared.ps1, ./Export/Functions/$funcName | Set-Content ./Export/Pss/${funcName}

    #publish module
    Push-Location ./Export/Psd
    #Publish-Module -Name ./*.psd1  -NuGetApiKey $keyRef.Value
    ##teddy micro
    Publish-Module -Name ./*.psd1  -NuGetApiKey oy2nrn275nrnnml7b3rqglqh2w6rx3ze7cn6nbpmxqfh3q -Verbose


    #tead oy2jt7jh6uar5jsdk27q22gnr7j5h2huphkz6untmzkkga
    Publish-Module -Name ./*.psd1  -NuGetApiKey oy2jt7jh6uar5jsdk27q22gnr7j5h2huphkz6untmzkkga -Verbose
    #publish script module
    Push-Location ./Export/Pss
    #Publish-Script -Name ./*.ps1  -NuGetApiKey $keyRef.Value
    
    #Remove-Item -force Export
    Pop-Location
}


function Export-PsModule() {
    param(
        [Parameter(Position = 0, ParameterSetName = 'Positional', ValueFromPipeline = $True)]
        [Alias("s", "Source")]
        [string]$path = $((Get-Location).Path)
    )

    Write-Output "Exporting the ${path}"
    Push-Location $path

    Remove-Item Export -Force -Confirm -Recurse
    #export folder
    mkdir Export
    
    mkdir Export/PsModule
    Copy-Item Aliases.ps1 ./Export/PsModule
    Copy-Item Functions.ps1 ./Export/PsModule
    Copy-Item *.psd1 ./Export/PsModule

    #export shared
    Get-Content '../\Shared-Functions/*.ps*1' | Set-Content ./Export/PsModule/SharedFunctions.ps1
}



if($commandline){
    Write-Output "loading shared modules"
    #ls ..\\#Shared/*.ps1
    . .\\Shared-Functions/*.ps1
}


Export-PsModule ./Currency-Conv
#Export-Module ./Currency-Conv
return

Export-GithubModule `
-Source ./ `
-ReleaseNotes "[Currency-Conv](https://github.com/stadub/PowershellScripts/tree/master/Currency-Conv) module update 0.9.0:
* First public release with currecny exchange countires and currencies list 
"