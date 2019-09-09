

function _Initalize() {
    
$script:_binDir = Get-ProfileDir "7zip" "bin"
Write-Debug "The 7-zip is dir set to $_binDir"
$script:_7zWin = Join-Path $_binDir "7za.exe"
$script:_7zWinDownloadDir='https://www.7-zip.org/a/7za920.zip'

$script:_7zPath = $null;

}

##Check if 7zip p7z are installed
function Test-7ZipInstall {
    $os = [System.Environment]::OSVersion.Platform
    #windows
    if($os -like 'win*'){
        Write-Debug "Os:Windows"

        #7-zip
        Write-Debug "Trying to locate 7-zip by the path: $script:_7zWin"

        if( -not (Test-Path "$script:_7zWin")){
            Write-Output '7Zip didn''t downloaded.'
            Write-Output 'Now script going to try to download it.'
            
            $file = Get-TempFileName
            Write-Debug "Temp file: ${file}"

            Receive-File  "7-Zip" $file $_7zWinDownloadDir
            Write-Debug "Extracting to directory ${_binDir}"
            if ( -not (Test-Path $_binDir )) {
                New-Item -Path $_binDir -ItemType 'Directory'
            }     

            Extract-ZipFile -FileName "$file" -Path "$_binDir"
        }
        $script:_7zPath = $script:_7zWin

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

function AddKeyArg {
    param (
        $AllArgs = $null,
        [string]$Key = $null
    )
    if( -not (Test-Empty $Key)){
        $AllArgs += "-p$Key"
    }
    return $AllArgs
}


##7zip process worker function
function Start-7Zip {
    param (
        $AllArgs
    )

    Test-7ZipInstall

    
    Write-Debug "Starting process. 7Zip ${AllArgs} "

    $process = Start-Process -FilePath $script:_7zPath -ArgumentList $AllArgs -NoNewWindow -PassThru -Wait

    $code=$process.ExitCode
    Write-Debug "7-Zip process complete. Return code: $code"

    if($code -ne "0"){
        throw "Execution Error: 7 result code:${code}"
    }

    return $code
}


<#
.SYNOPSIS
List 7zip file content

.DESCRIPTION
List 7zip file content

.PARAMETER ArchiveName
Archive file to list content

.PARAMETER Password
Archive password (if have been set)

.EXAMPLE
Read-ZipFile .\scripts.7z
ls *.7z| Read-ZipFile

#>

function Read-ZipFile {
    param (
        [ValidateScript( { Test-Path $_  -pathType leaf })] 
        [Parameter(Position = 0, ValueFromPipeline  = $True, Mandatory = $true)]
        [Alias("Path","Name", "Archive", "p")]
        [string]$ArchiveName,
        [Alias("Password","pass")]
        [string]$Key = $null
    )

    Write-Output "List zip content:""$ArchiveName""."

    $AllArgs = @('l', "$ArchiveName");

    $AllArgs = AddKeyArg $AllArgs $Key
    
    return Start-7Zip $AllArgs

}

<#
.SYNOPSIS
Add file to archive

.DESCRIPTION
Add file to archive

.PARAMETER ArchiveName
Existing Archive file add extra files

.PARAMETER FileName
File to add

.PARAMETER Password
Archive password (if have been set)

.EXAMPLE
Add-ZipFileContent '.\registered.js' -Archive .\scripts.7z
Add-ZipFileContent '.\registered.js' -Archive .\scripts.7z -Password qwe123
ls *.js | Add-ZipFileContent -Archive .\scripts.7z -Password qwe123

#>

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

        [Alias("Password","pass")]        
        [string]$Key = $null
    )
    
    Write-Output "Adding/updating file ""$FileName"" to arhcive ""$ArchiveName"""

    #WriteHash $ArchiveName $FileName 

    $AllArgs = @('u', "$ArchiveName", "$FileName");

    $AllArgs = AddKeyArg $AllArgs $Key

    return Start-7Zip $AllArgs
}


<#
.SYNOPSIS
Remove file from archive

.DESCRIPTION
Remove file from archive

.PARAMETER Archive
Existing Archive file to remove files

.PARAMETER File
Removal file

.PARAMETER Password
Archive password (if have been set)

.EXAMPLE
Remove-ZipFileContent -Archive .\scripts.7z -File "temp.log"
ls *.7z| Remove-ZipFileContent -File "temp.log"
#>

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

        [Alias("Password","pass")]
        [string]$Key = $null
    )

    Write-Output "Removing file ""$FileName"" from arhcive ""$ArchiveName"""

    $AllArgs = @('d', "$ArchiveName", "$FileName");

    $AllArgs = AddKeyArg $AllArgs $Key

    $code =  Start-7Zip $AllArgs

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
Enum SplitSizeFactor {
    Byte
    Kilobyte
    Megabyte
    Gigabytes 
}

<#
.SYNOPSIS
Create a new 7zip archive

.DESCRIPTION
Create a new 7zip archive

.PARAMETER Archive
Archive file to be created

.PARAMETER FileNames
Files fo add to archive

.PARAMETER FSFiles
Powershell files (from pipeline) to add

.PARAMETER Password
Archive password (if have been set)

.PARAMETER Compression
Compression Level {Store, Fastest, Fast, Normal, Maximum, Ultra}

.PARAMETER UpdateMode
Files Update Mode  {Add, Update, Freshen, Sync}

.PARAMETER SplitSize
Volume sizes

.PARAMETER SplitSizeFactor
Volume size factor {Byte, Kilobyte, Megabyte, Gigabytes}

.EXAMPLE
ls -Exclude .git | New-ZipFile "scripts"
New-ZipFile -Compression Ultra -FileNames .\\index.rst,.\\README.md -Password qwe123 -SplitSize 1,2,3,4,20 -SplitSizeFactor Megabyte

.NOTES
General notes
#>

function New-ZipFile {
    [cmdletbinding(DefaultParameterSetName = 'SingleFile' )]
    param (

        [ValidateScript( { !(Test-Path -Path $_)  })] 
        [Parameter(Position = 0, ParameterSetName = 'FileNameArray', ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        [Parameter(Position = 0, ParameterSetName = 'FileArray', ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        [Alias("Path","Name", "Archive", "p")]
        [string]$ArchiveName,
       

        [ValidateScript( {foreach ($item in $_){ Test-Path -Path $item  }})] 
        [Parameter(Position = 1, ParameterSetName = 'FileNameArray', ValueFromPipeline = $True, Mandatory = $true)]
        [Alias("Files", "fl")]
        [string[]]$FileNames,
        

        [Parameter(Position = 1, ParameterSetName = 'FileArray', ValueFromPipeline = $True, Mandatory = $true)]
        [Alias("FileSytemFiles", "fsl")]
        [System.IO.FileSystemInfo[]]$FSFiles,

        [Parameter(Position = 3, ParameterSetName = 'FileNameArray', ValueFromPipelineByPropertyName = $True)]
        [Parameter(Position = 3, ParameterSetName = 'FileArray', ValueFromPipelineByPropertyName = $True)]
        [Alias("Password","pass")]
        [string]$Key = $null,

        [Parameter(Position = 2, ParameterSetName = 'FileNameArray', ValueFromPipelineByPropertyName = $True)]
        [Parameter(Position = 2, ParameterSetName = 'FileArray', ValueFromPipelineByPropertyName = $True)]
        [Alias("mx", "Level")]
        [CompressionLevel]$Compression = [CompressionLevel]::Normal,
       

        ###doesnt work
        # [Parameter(Position = 4, ParameterSetName = 'SingleFile', ValueFromPipelineByPropertyName = $True)]
        # [Parameter(Position = 4, ParameterSetName = 'FileNameArray', ValueFromPipelineByPropertyName = $True)]
        # [Parameter(Position = 4, ParameterSetName = 'FileArray', ValueFromPipelineByPropertyName = $True)]
        # [Alias("pf", "PathMode")]
        # [PathFormat]$PathFormat = [PathFormat]::Realtive,

        [Parameter(Position = 5, ParameterSetName = 'FileNameArray', ValueFromPipelineByPropertyName = $True)]
        [Parameter(Position = 5, ParameterSetName = 'FileArray', ValueFromPipelineByPropertyName = $True)]
        [Alias("m", "AchiveMode","FileMode")]
        [UpdateMode]$UpdateMode=[UpdateMode]::Add,

        [Parameter(Position = 6, ParameterSetName = 'FileNameArray', ValueFromPipelineByPropertyName = $True)]
        [Parameter(Position = 6, ParameterSetName = 'FileArray', ValueFromPipelineByPropertyName = $True)]
        [Alias("s", "v", "Volume", "VolumeSize", "Split")]
        [string[]]$SplitSize=$null, 

        [Parameter(Position = 7, ParameterSetName = 'FileNameArray', ValueFromPipelineByPropertyName = $True)]
        [Parameter(Position = 7, ParameterSetName = 'FileArray', ValueFromPipelineByPropertyName = $True)]
        [Alias("vs", "VolumeSizeFactor", "SplitFactor")]
        [SplitSizeFactor]$SplitSizeFactor=[SplitSizeFactor]::Megabyte

    )

    begin {
        Write-Output "Creating Archive ""$ArchiveName"""

        if ( Test-Path "${ArchiveName}.7z" ) {
            throw "Arhive ""$ArchiveName"" allready exist, please select another destination."
        }
        $files = @()
    }
    process {

        $FileNames| ForEach-Object{
            if( -not (Test-Empty $_) ){
                Write-Debug "Adding file ""$_"""
                $files += $_
            }
        }
    
        $FSFiles| ForEach-Object{
            if( $null -ne $_ ){
                Write-Debug "Addign file ""$FSFiles"" from the filesystem"
                $files += $_.FullName
            }
        }
    
    }
    
    end{
    Write-Output "Creating Archive ""$ArchiveName"""

    if ( Test-Path "${ArchiveName}.7z" ) {
        throw "Arhive ""$ArchiveName"" allready exist, please select another destination."
    }


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
        }
        Sync  {
            $AllArgs += "u"
        }
    }

    $AllArgs += "$ArchiveName"

    $AllArgs = AddKeyArg $AllArgs $Key

    if ( $null -ne $Compression ){
        Write-Debug $Compression
        Write-Debug "-mx$([int]$Compression)"
        $AllArgs += "-mx$([int]$Compression)"
    }

    switch ( $UpdateMode )
    {
        Add { }
        Update  { }
        Freshen  {
            $AllArgs += "-ur0"
        }
        Sync  {
            $AllArgs += "-uq0"
        }
    }

    $files | ForEach-Object{
        $AllArgs += $_
    }
    

    if( -not (Test-Empty $([string]$SplitSize) )){

        $factorName="b"
        switch ( $SplitSizeFactor )
        {
            Byte{
                $factorName = "b"
            }
            Kilobyte  { 
                $factorName = "k"
            }
            Megabyte {
                $factorName = "m"
            }
            Gigabytes  {
                $factorName = "g"
            }
        }
        $SplitSize| ForEach-Object{
            $AllArgs += "-v$_$factorName"
        }
    }

    $PathFormat = [PathFormat]::Realtive

    switch ( $PathFormat )
    {
        Realtive { }
        Full { 
            $AllArgs += "-spf2"
        }
        Absolute  {
            $AllArgs += "-spf"
        }
    }
    return Start-7Zip $AllArgs
    }
}


<#
.SYNOPSIS
Perform 7Zip arhive integrity check

.DESCRIPTION
Perform 7Zip arhive integrity check

.PARAMETER Archive
Archive file

.PARAMETER File
Archived File to test

.PARAMETER Password
Archive password

.EXAMPLE
/>Test-ZipFileContent  -Archive 'folder.7z'
/>Test-ZipFileContent  -Archive 'folder.7z' -File 'file.txt'
/> ([PSCustomObject]@{File='file.txt',  Archive='File.7z', Password="pass"} | Test-ZipFileContent -Archive 'File.7z'

#>

function Test-ZipFileContent {
    param (

        [ValidateScript( { Test-Path $_  -pathType leaf })] 
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        [Alias("Path","Name", "Archive", "p")]
        [string]$ArchiveName,

        [Parameter(Position = 1,  ValueFromPipelineByPropertyName = $True)]
        [Alias("File", "f")]
        [string]$FileName = $null,
        
        
        [Parameter(Position = 2, ValueFromPipelineByPropertyName = $True)]
        [Alias("Password","pass")]        
        [string]$Key = $null
    )
    
    Write-Output "Test file ""$FileName"" from archive ""$ArchiveName"""

    $AllArgs = @('t', "$ArchiveName")


    if( -not (Test-Empty $FileName) ){
        $AllArgs += "$FileName"
    }

    $AllArgs = AddKeyArg $AllArgs $Key

    $code = Start-7Zip $AllArgs

    Write-Output "File test End. Return code: $code"
    return $code

}


<#
.SYNOPSIS
Extract file(s) from 7zip archive

.DESCRIPTION
Extract file(s) from 7zip archive

.PARAMETER Archive
Parameter description

.PARAMETER FileName
File to extract

.PARAMETER Password
Parameter description

.PARAMETER Force
Overwrite existing file

.PARAMETER OutputPath
Folder to extract

.EXAMPLE
An example

.NOTES
General notes
#>

function Get-ZipFileContent {
    param (
        [ValidateScript( { Test-Path $_  -pathType leaf })] 
        [Parameter(Position = 0, ValueFromPipeline  = $True, Mandatory = $true)]
        [Alias("Path","Name", "Archive", "p")]
        [string]$ArchiveName,

        [Parameter(Position = 1)]
        [Alias("File", "f")]
        [string]$FileName=$null,

        [Alias("Password","pass")] 
        [string]$Key = $null,

        [Alias("y")] 
        [bool]$Force = $false,

        [Alias("OutDir","OutputPath")] 
        [string]$destFolder=$null
    )
    
    Write-Output "Extracting file ""$FileName"" from archive ""$ArchiveName"""

    $AllArgs = @('e', "$ArchiveName")

    if( -not (Test-Empty $FileName) ){
        $AllArgs += "$FileName"
    }

    if( -not (Test-Empty $destFolder) ){
        CreateFolderIfNotExist "${destFolder}"
        $AllArgs += "-o$destFolder"
    }

    if( $Force ){
        $AllArgs += "-y"
    }

    $AllArgs = AddKeyArg $AllArgs $Key

    $code = Start-7Zip $AllArgs

    # if( -not (Test-Empty $FileName) -and -not (Check-Hash "$ArchiveName" "$FileName")){
    #     throw "Extracted file hash is different"
    # }

    Write-Output "File extracted. Return code: $code"
    return $code

}

