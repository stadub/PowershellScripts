

function Initalize() {
    

$script:_binDir = Join-Path (Get-ProfileDir $moduleName) 'bin'
$script:_7zWin = Join-Path $_binDir "7za.exe"
$script:_7zWinDownloadDir='https://www.7-zip.org/a/7za920.zip'

$script:_7zPath = $null;

Write-Debug "Loading ${MyInvocation.MyCommand.Name}"

}

function Test-7ZipInstall {
    $os = [System.Environment]::OSVersion.Platform
    #windows
    if($os -like 'win*'){
        Write-Debug "Os:Windows"

        #7-zip
        Write-Debug "Trying to locate 7-zip by the path: $script:_7zWin"

        if( -not (Test-Path "$script:_7zWin")){
            Write-Output '7Zip didn''t found.'
            
            $file = Get-TempFileName
            Write-Debug "Temp file: ${file}"

            Receive-File  "7-Zip" $file $_7zWinDownloadDir
            Write-Debug "Extracting to directory ${_binDir}"
            if ( -not (Test-Path $_binDir )) {
                New-Item -Path $_binDir -ItemType 'Directory'
            }     

            Extract-ZipFile -FileName "$file" -Path "$_binDir"
        }
        $script:_7zPath = $7zWin

    }
    else{
        #linux or macOs
        Get-Command p7zip -Erroraction 'silentlycontinue'| ForEach-Object{ $script:_7zPath= $_.Path}
        if ( -not (Test-Path $script:_7zPath )){
             #sudo apt-get install p7zip
             $script:aborted = $true
            throw "p7zip application is not installed. 
            If you using debian/ubuntu run `sudo apt-get install p7zip` then restart the script"
        }
    }
}

function Start-7Zip {
    param (
        $Args,
        [string]$Key = $null
    )

    Test-7ZipInstall

    if( -not (Test-Empty $Key)){
        $Args += "-p:$Key"
   }

    Write-Debug "Starting process. 7Zip ${Args} "

    $process = Start-Process -FilePath $script:_7zPath -ArgumentList $Args -NoNewWindow -PassThru -Wait

    $code=$process.ExitCode
    Write-Debug "7-Zip process complete. Return code: $code"

    if($code -ne "0"){
        throw "Execution Error: 7 result code:${code}"
    }

    return $code
}

function Read-ZipFile {
    param (
        [ValidateScript( { Test-Path $_  -pathType leaf })] 
        [Parameter(Position = 0, ValueFromPipeline  = $True, Mandatory = $true)]
        [Alias("Path","Name", "Archive", "p")]
        [string]$ArchiveName,
        [Alias("Password","p")]
        [string]$Key = $null
    )

    Write-Output "List zip content:""$ArchiveName""."

    $AllArgs = @('l', "$ArchiveName");
    return Start-7Zip $AllArgs $Key

}

function Add-ZipFileContent {
    param (
        [ValidateScript( { Test-Path $_  -pathType leaf })] 
        [Parameter(Position = 0,  Mandatory = $true)]
        [Alias("Path","Name", "Archive", "p")]
        [string]$ArchiveName,

        [ValidateScript( { Test-Path $_  -pathType leaf })] 
        [Parameter(Position = 1, ValueFromPipeline  = $True, Mandatory = $true)]
        [Alias("File", "f")]
        [string]$FileName,

        [Alias("Password","p")]        
        [string]$Key = $null
    )
    
    Write-Output "Adding/updating file ""$FileName"" to arhcive ""$ArchiveName"""

    #WriteHash $ArchiveName $FileName 

    $AllArgs = @('u', "$ArchiveName", "$FileName");

    return Start-7Zip $AllArgs $Key
}

function Remove-ZipFileContent {
    param (

        [ValidateScript( { Test-Path $_  -pathType leaf })] 
        [Parameter(Position = 0, ValueFromPipeline  = $True, Mandatory = $true)]
        [Alias("Path","Name", "Archive", "p")]
        [string]$ArchiveName,

        [ValidateScript( { Test-Path $_  -pathType leaf })] 
        [Parameter(Position = 1, Mandatory = $true)]
        [Alias("File", "f")]
        [string]$FileName,

        [Alias("Password","p")] 
        [string]$Key = $null
    )

    Write-Output "Removing file ""$FileName"" from arhcive ""$ArchiveName"""

    $AllArgs = @('d', "$ArchiveName", "$FileName");

    $code =  Start-7Zip $AllArgs $Key

    #Remove-Hash $ArchiveName "$FileName"

    return $code
}



Enum CompressionLevel {
    Store = 0
    Fastest = 1
    Fast = 3
    Normal = 5
    Maximum = 7
    Ultra = 9
}

Enum PathFormat {
    Realtive = 0
    Full = 1
    Absolute = 3
}

Enum UpdateMode {
    Add
    Update
    Freshen
    Sync
}

function New-ZipFile {
    [cmdletbinding(DefaultParameterSetName = 'SingleFile' )]
    param (

        [ValidateScript( { Test-Path $_  -pathType leaf })] 
        [Parameter(Position = 0, ParameterSetName = 'SingleFile', ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        [Parameter(Position = 0, ParameterSetName = 'FileArray', ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        [Alias("Path","Name", "Archive", "p")]
        [string]$ArchiveName,

        [ValidateScript( { Test-Path $_  -pathType leaf })] 
        [Parameter(Position = 1, ParameterSetName = 'SingleFile', ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        [Alias("File", "f")]
        [string]$FileName,
        

        [ValidateScript( {foreach ($item in $_){ Test-Path $item  -pathType leaf }})] 
        [Parameter(Position = 1, ParameterSetName = 'FileArray', ValueFromPipeline = $True, Mandatory = $true)]
        [Parameter(Position = 1, ValueFromPipeline  = $True, Mandatory = $true)]
        [Alias("Files", "f")]
        [string[]]$FileNames,
        
        [Parameter(Position = 3, ParameterSetName = 'SingleFile', ValueFromPipelineByPropertyName = $True)]
        [Parameter(Position = 3, ParameterSetName = 'FileArray', ValueFromPipelineByPropertyName = $True)]
        [Alias("Password","p")] 
        [string]$Key = $null,

        [Parameter(Position = 2, ParameterSetName = 'SingleFile', ValueFromPipelineByPropertyName = $True)]
        [Parameter(Position = 2, ParameterSetName = 'FileArray', ValueFromPipelineByPropertyName = $True)]
        [Alias("mx", "Level", "Compression")]
        [CompressionLevel]$Compression = [CompressionLevel]::Normal,

        [Parameter(Position = 4, ParameterSetName = 'SingleFile', ValueFromPipelineByPropertyName = $True)]
        [Parameter(Position = 4, ParameterSetName = 'FileArray', ValueFromPipelineByPropertyName = $True)]
        [Alias("s", "v", "Volume", "Split", "SplitSize")]
        [string]$SplitSize=$null,

        [Parameter(Position = 5, ParameterSetName = 'SingleFile', ValueFromPipelineByPropertyName = $True)]
        [Parameter(Position = 5, ParameterSetName = 'FileArray', ValueFromPipelineByPropertyName = $True)]
        [Alias("pf", "PathMode")]
        [PathFormat]$PathFormat = [PathFormat]::Realtive,

        [Parameter(Position = 6, ParameterSetName = 'SingleFile', ValueFromPipelineByPropertyName = $True)]
        [Parameter(Position = 6, ParameterSetName = 'FileArray', ValueFromPipelineByPropertyName = $True)]
        [Alias("m", "Mode","FileMode")]
        [UpdateMode]$UpdateMode=[UpdateMode]::Add

    )
    begin {
        Write-Output "Creating Archive for file ""$FileName"" ""$ArchiveName"""

        if ( Test-Path "${ArchiveName}.7z" ) {
            throw "Arhive ""$ArchiveName"" allready exist, please select another destination."
        }
    }
    process {

        $AllArgs = @()

        switch ( $UpdateMode )
        {
            Add {
                $AllArgs += "a"
             }
            Update  { 
                $AllArgs += "u"
            }
            Freshen  {
                $AllArgs += "u"
                $AllArgs += "-ur0"
            }
            Sync  {
                $AllArgs += "u"
                $AllArgs += "-uq0"
            }
        }

        $AllArgs += "-mx${Compression.value__}"
        
        if( -not (Test-Empty $SplitSize) ){
            $AllArgs += "-v$SplitSize"
        }

        switch ( $PathFormat )
        {
            Realtive { }
            Full { 
                $AllArgs += "-spf2"
            }
            Absolute  {
                $AllArgs += "--spf"
            }
        }

        $AllArgs += "$ArchiveName"

        foreach ($item in $FileNames){
              #WriteHash $ArchiveName $item 
              $AllArgs += "$item"

        }

        if( -not (Test-Empty $FileName) ){
            $AllArgs += "$FileName"
        }


        return Start-7Zip $AllArgs $Key
    }
    end{

    }
}

function Test-ZipFileContent {
    param (

        [ValidateScript( { Test-Path $_  -pathType leaf })] 
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        [Alias("Path","Name", "Archive", "p")]
        [string]$ArchiveName,

        [Parameter(Position = 1,  ValueFromPipelineByPropertyName = $True)]
        [Alias("File", "f")]
        [string]$FileName = $null,
        
        
        [Parameter(Position = 3, ValueFromPipelineByPropertyName = $True)]
        [Parameter(Position = 3, ValueFromPipelineByPropertyName = $True)]
        [Alias("Password","p")] 
        [string]$Key = $null
    )
    
    Write-Output "Test file ""$FileName"" from archive ""$ArchiveName"""

    $AllArgs = @('t', "$ArchiveName")


    if( -not (Test-Empty $FileName) ){
        $AllArgs += "$FileName"
    }


    $code = Start-7Zip $AllArgs $Key

    Write-Output "File test End. Return code: $code"
    return $code

}

function Get-ZipFileContent {
    param (
        [ValidateScript( { Test-Path $_  -pathType leaf })] 
        [Parameter(Position = 0, ValueFromPipeline  = $True, Mandatory = $true)]
        [Alias("Path")]
        [string]$ArchiveName,

        [Parameter(Position = 1)]
        [Alias("File")]
        [string]$FileName=$null,

        [string]$Key = $null,
        [bool]$Force = $false,
        [string]$destFolder=$null
    )
    
    Write-Output "Extracting file ""$FileName"" from archive ""$ArchiveName"""

    $AllArgs = @('e', "$ArchiveName")

    if( -not (Test-Empty $FileName) ){
        $AllArgs += "$FileName"
    }

    if( -not (Test-Empty $destFolder) ){
        CreateFolderIfNotExist "${destFolder}"
        $AllArgs += "-o:$destFolder"
    }

    if( $Force ){
        $AllArgs += "-y"
    }


    $code = Start-7Zip $AllArgs $Key

    # if( -not (Test-Empty $FileName) -and -not (Check-Hash "$ArchiveName" "$FileName")){
    #     throw "Extracted file hash is different"
    # }

    Write-Output "File extracted. Return code: $code"
    return $code

}


##Load Extra functions
$curDir = Split-Path $MyInvocation.MyCommand.Path


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

if(-not $_7ZipLoaded){
    Initalize
}

# if(-not $_HashLoaded ){
# Write-Output "Loading Hash Function"; . "./Hash.ps1"
# }
    
$_7ZipLoaded = $true


if ( $script:MyInvocation.MyCommand.Name.EndsWith('.psm1') ){
    #Write-Output "Module"
    Export-ModuleMember -Function: Read-ZipFile
    Export-ModuleMember -Function: Add-ZipFileContent
    Export-ModuleMember -Function: Remove-ZipFileContent
    Export-ModuleMember -Function: Test-ZipFileContent
    Export-ModuleMember -Function: Get-ZipFileContent
}

