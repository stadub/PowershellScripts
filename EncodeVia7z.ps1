#Allow to encode files from folder for upload to cloud.
#Used as backups encoding solution and have no auto decoder(thank goodness)
#Encoding performed by 7z util
#To decrypt:
#1)Concat value from .masterKey and add ':' to beginign and by using resulting key extract .keys file from .keys.7z
#2)Find apropriate row in .key for file that shoudl be decoded.
#3)Concat first row from .masterKey with first row from .key file and ':' to beginign
#4)Use key from previouse step as 7z password for decode file
param (
[string]$SrcFolder  = (Get-Location).Path,

[string]$DestFolder =  (Get-Location).Path
)



$utilFolder="C:\Program Files\7-Zip\";
$Slash=[IO.Path]::DirectorySeparatorChar; 
$aborted=$false;
$Keyfile= ".keys";
$KeyfilePath= $DestFolder + $Slash + $Keyfile;
$MaserKeyfilePath= $DestFolder + $Slash +".masterKey"
function ZipFile{
param (
[ValidateScript({Test-Path ( $SrcFolder + $Slash + $_ ) -pathType leaf})] 
[Parameter(Mandatory=$true)]
[string]$FileName,

[Parameter(Mandatory=$true)]
[string]$Key,
[string]$SrcFolder,
[string]$DestFolder

)
echo "Creating Archive for file ""$FileName"""

$_srcFile= $SrcFolder + $Slash + $FileName;
$_dstFile= $DestFolder + $Slash + $FileName.Replace('.','_');

$7z="${utilFolder}7z.exe";

if( Test-Path "${_dstFile}.7z" ){
 Write-Error "Arhive ""$FileName"" allready exist in folder ""$DestFolder"", please select another distanation."
 return -1;
}

$AllArgs =  @('a', "$_dstFile", "$_srcFile", "-p:$Key");
echo $AllArgs
$process = Start-Process -FilePath $7z -ArgumentList $AllArgs -NoNewWindow -PassThru -Wait

$code=$process.ExitCode.ToString();

echo "File compressed. Return code: $code"
return $process.ExitCode

}

function GetFileHash{
param (
[ValidateScript({Test-Path ($_ ) -pathType leaf})] 
[Parameter(Mandatory=$true)]
[string]$FilePath
)

$_shaTool="${utilFolder}fciv.exe";

# --- getting file sha1 checksum

$_hash= & $_shaTool -sha1 $FilePath ;
#remove extra lines
$_hash =$_hash| %{ if( ![string]::IsNullOrEmpty($_.ToString()) -and !$_.ToString().StartsWith("//")){ echo $_;} };
#extract hash
$_hash= $_hash.Split(' ')[0];


echo $_hash
}

function EncodeFile(){
param (
[Parameter(Mandatory=$true)]
[string]$Salt,
[Parameter(Mandatory=$true)]
[string]$SrcFolder,
[Parameter(Mandatory=$true)]
[string]$DestFolder,
[ValidateScript({Test-Path ( $SrcFolder + $Slash + $_ ) -pathType leaf})] 
[Parameter(Mandatory=$true)]
[string]$FileName
)

echo "Encoding file ""$FileName"""

$srcFile= $SrcFolder + $Slash + $FileName;


$hash=GetFileHash -FilePath $srcFile;

$key=$Salt+$hash;

echo "$hash $FileName">>$KeyfilePath;

$result=ZipFile -FileName  $FileName -Key $Key -SrcFolder $SrcFolder   -DestFolder $DestFolder;

if( $result -eq "0" ){
    Write-Error "Encoding aborted. Some error occured.";
    $aborted=$true;
    return -1;
}

}

function EncodFolder{
param (
[Parameter(Mandatory=$true)][string]$SrcFolder,
[Parameter(Mandatory=$true)][string]$DestFolder
)

if( Test-Path $KeyfilePath ){
#rm -Force $KeyfilePath | out-null
}

$salt=[System.Guid]::NewGuid().ToString();


ls $SrcFolder | %{
    if($aborted -eq $true){ return;}
    $FileName=$_.Name;

    EncodeFile $salt $SrcFolder $DestFolder $FileName
}

EncodeFile $salt $DestFolder $DestFolder $Keyfile

$KeysFileHash=Get-Content  $KeyfilePath| Select-Object -last 1
$KeysFileHash=$KeysFileHash.Split(' ')[0];

echo "$salt $KeysFileHash">$MaserKeyfilePath
}



EncodFolder $SrcFolder $DestFolder;