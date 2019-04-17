<#PSScriptInfo

.VERSION 1.1

.GUID 6d06e54e-f29e-4c27-9fb2-ed1dfbd0dc79

.AUTHOR Dima Stadub

.COMPANYNAME 

.COPYRIGHT 

.TAGS 7zip encode zip archive

.LICENSEURI 

.PROJECTURI https://github.com/stadub/PowershellScripts

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#> 


<#
.SYNOPSIS
  Encode files from folder for(for example) uploading to cloud
.DESCRIPTION
Used as backups encoding solution.
Encoding performed with 7z password protection

There was no reasons (thank goodness) decoding stored data so currently there no decoder script 
It you need - please create github issue and I'll add scrpit for folder decoding.
Manually files can be decoded with the next algorithm:
1)Concat value from .masterKey and add ':' to beginign and by using resulting key extract .keys file from .keys.7z
2)Find apropriate row in .key for file that shoudl be decoded.
3)Concat first row from .masterKey with first row from .key file and ':' to beginign
4)Use key from previouse step as 7z password for decode file
.EXAMPLE
   EncodeVia7z "c:\windows\System42" "d:\System"
.PARAMETER SrcFolder (optional)
   Folder to be encoded
.PARAMETER DestFolder
   Destanation folder where encoded files be created
  #>
param (
    [string]$SrcFolder = (Get-Location).Path,

    [string]$DestFolder = (Get-Location).Path
)

#$DebugPreference = "Continue"

$Slash = [IO.Path]::DirectorySeparatorChar; 


$binDir="$PSScriptRoot\bin\${MyInvocation.MyCommand.Name}"
$7zWin = "$binDir\7za.exe"
$sha1 = "$binDir\fciv.exe"
$7zWinDownloadDir='https://www.7-zip.org/a/7za920.zip'

$sha1Win="https://download.microsoft.com/download/c/f/4/cf454ae0-a4bb-4123-8333-a1b6737712f7/Windows-KB841290-x86-ENU.exe"


$script:7zPath = $null;
$script:shaTool = $null


function DownloadUtil {
    param (
        [string]$name,
        [string]$file,
        [string]$url
    )

    $reply = Read-Host -Prompt "Would you like to download '$name'?[y/n]"
    if ( -not $reply -match "[yY]" ) {  
        throw "Execution aborted"
    }

    Write-Output "Starting download '$name'"

    Write-Debug "Downoad url:${url}"

    (New-Object System.Net.WebClient).DownloadFile($url, $file)
    
    Write-Debug "File downloaded to ${file}."

}



function CheckUtils {
    $os = [System.Environment]::OSVersion.Platform
    #windows
    if($os -like 'win*'){
        Write-Debug "Os:Windows"

        #7-zip
        Write-Debug "Trying to locate 7-zip by the path: ${7zWin}"

        if( ! (Test-Path $7zWin)){
            Write-Output '7Zip didn''t found.'
            
            $file = [System.IO.Path]::GetTempFileName() 
            Write-Debug "Temp file: ${file}"

            DownloadUtil  "7-Zip" $file $7zWinDownloadDir
            Write-Debug "Extracting to directory ${binDir}"
            if ( ! (Test-Path $binDir )) {mkdir $binDir}
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($file, $binDir)
        }
        $script:7zPath = $7zWin

        #sha1
        Write-Debug "Trying to locate sha1 util by the path: ${sha1Win}"
        if( ! (Test-Path $sha1)){
            Write-Output 'fciv didn''t found.'

            $file = [System.IO.Path]::GetTempFileName()
            Write-Debug "Temp file: ${file}"

            DownloadUtil "fciv" $file $sha1Win
            if ( ! (Test-Path $binDir )) {mkdir $binDir}
            & $7zPath e $file "-o${binDir}" -y
        }
        $script:shaTool = "${sha1} -sha1 ";

    }
    else{
        #linux or macOs
        get-command p7zip -Erroraction 'silentlycontinue'| ForEach-Object{ $7zPath= $_.Path}
        if ( ! $7zPath ){
             #sudo apt-get install p7zip
             $script:aborted = $true
            throw "p7zip application is not installed. 
            If you using debian/ubuntu run `sudo apt-get install p7zip` then restart the script"
        }
        $shaTool = "shasum "
    }
}

$script:aborted = $false

$Keyfile = ".keys";
$KeyfilePath = $DestFolder + $Slash + $Keyfile;
$MaserKeyfilePath = $DestFolder + $Slash + ".masterKey"
function ZipFile {
    param (
        [ValidateScript( { Test-Path ( $SrcFolder + $Slash + $_ ) -pathType leaf })] 
        [Parameter(Mandatory = $true)]
        [string]$FileName,

        [Parameter(Mandatory = $true)]
        [string]$Key,
        [string]$SrcFolder,
        [string]$DestFolder
    )
    Write-Output "Creating Archive for file ""$FileName"""

    $_srcFile = $SrcFolder + $Slash + $FileName
    $_dstFile = $DestFolder + $Slash + $FileName.Replace('.', '_')


    if ( Test-Path "${_dstFile}.7z" ) {
        Write-Error "Arhive ""$FileName"" allready exist in folder ""$DestFolder"", please select another distanation."
        return -1;
    }

    $AllArgs = @('a', "$_dstFile", "$_srcFile", "-p:$Key");
    Write-Debug $AllArgs
    $process = Start-Process -FilePath $7zPath -ArgumentList $AllArgs -NoNewWindow -PassThru -Wait

    $code = $process.ExitCode.ToString();

    Write-Output "File compressed. Return code: $code"
    return $process.ExitCode

}

function GetFileHash {
    param (
        [ValidateScript( { Test-Path ($_ ) -pathType leaf })] 
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # --- getting file sha1 checksum

    $_hash = Invoke-Expression "$shaTool  $FilePath"
    #remove extra lines
    $_hash = $_hash | ForEach-Object { 
        if ( ![string]::IsNullOrEmpty($_.ToString()) -and !$_.ToString().StartsWith("//")) { 
            Write-Output $_; 
        } 
    };
    #extract hash
    $_hash = $_hash.Split(' ')[0];


    Write-Output $_hash
}

function EncodeFile() {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Salt,
        [Parameter(Mandatory = $true)]
        [string]$SrcFolder,
        [Parameter(Mandatory = $true)]
        [string]$DestFolder,
        [ValidateScript( { Test-Path ( $SrcFolder + $Slash + $_ ) -pathType leaf })] 
        [Parameter(Mandatory = $true)]
        [string]$FileName
    )

    Write-Output "Encoding file ""$FileName"""

    $srcFile = $SrcFolder + $Slash + $FileName;


    $hash = GetFileHash -FilePath $srcFile;

    $key = $Salt + $hash;

    Write-Output "$hash $FileName">>$KeyfilePath;

    $result = ZipFile -FileName  $FileName -Key $Key -SrcFolder $SrcFolder   -DestFolder $DestFolder;

    if ( $result -eq "0" ) {
        throw "Encoding aborted. Some error occured."
    }

}

function EncodFolder {
    param (
        [Parameter(Mandatory = $true)][string]$SrcFolder,
        [Parameter(Mandatory = $true)][string]$DestFolder
    )

    if ( Test-Path $KeyfilePath ) {
        #rm -Force $KeyfilePath | out-null
    }

    $salt = [System.Guid]::NewGuid().ToString();


    Get-ChildItem $SrcFolder | ForEach-Object {
        if ($aborted -eq $true) { return; }
        $FileName = $_.Name;

        EncodeFile $salt $SrcFolder $DestFolder $FileName
    }

    EncodeFile $salt $DestFolder $DestFolder $Keyfile

    $KeysFileHash = Get-Content  $KeyfilePath | Select-Object -last 1
    $KeysFileHash = $KeysFileHash.Split(' ')[0];

    Write-Output "$salt $KeysFileHash">$MaserKeyfilePath
}

CheckUtils

EncodFolder $SrcFolder $DestFolder;