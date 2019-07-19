
;$moduleToLoad=$module;

$RepoName = 'PowershellScripts';

$tempFile= "$env:TEMP\$RepoName";

$ProfileModulePath = $env:PSModulePath.split(';')[0];
if (!(Test-Path $ProfileModulePath)) {
    New-Item -ItemType Directory -Path $ProfileModulePath;
}

(New-Object System.Net.WebClient).DownloadFile("https://github.com/stadub/$RepoName/archive/master.zip", "${tempFile}.zip");

Unblock-File -Path "${tempFile}.zip";

Add-Type -AssemblyName System.IO.Compression.FileSystem;
[System.IO.Compression.ZipFile]::ExtractToDirectory("${tempFile}.zip", "${tempFile}");

Move-Item -Path "${tempFile}\$RepoName-master\$moduleToLoad" -Destination "$ProfileModulePath";
Remove-Item "${tempFile}*" -Recurse -ErrorAction SilentlyContinue;
