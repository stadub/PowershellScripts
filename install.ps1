
$module="Bookmarks"

;$moduleToLoad=$module;

$RepoName = 'PowershellScripts';

$tempFile= "$env:TEMP\$RepoName";

$ProfileModulePath = $env:PSModulePath.split(';')[0];
if (!(Test-Path $ProfileModulePath)) {
    New-Item -ItemType Directory -Path $ProfileModulePath;
}


$client = New-Object System.Net.WebClient

$url = [uri]"https://github.com/stadub/$RepoName/archive/master.zip"

$file =  "${tempFile}.zip"

try {

    Register-ObjectEvent $client DownloadProgressChanged -action {     
 
         Write-Progress -Activity "Module Installation" -Status `
             ("Downloading Module: {0} of {1}" -f $eventargs.BytesReceived, $eventargs.TotalBytesToReceive) `
             -PercentComplete $eventargs.ProgressPercentage    
     }
 
     Register-ObjectEvent $client DownloadFileCompleted -SourceIdentifier Finished
 
     $client.DownloadFileAsync($url, $file)
 
     # optionally wait, but you can break out and it will still write progress
     Wait-Event -SourceIdentifier Finished
}
catch [System.Net.WebException]  
{  
Write-Host("Cannot download $url")  
} 
  finally { 
     $client.dispose()
 }

Unblock-File -Path "${tempFile}.zip";


Write-Progress -Activity "Module Installation"  -Status "Unpacking Module" -PercentComplete 0

Add-Type -AssemblyName System.IO.Compression.FileSystem;
[System.IO.Compression.ZipFile]::ExtractToDirectory("${tempFile}.zip", "${tempFile}");

Write-Progress -Activity "Module Installation"  -Status "Unpacking Module" -PercentComplete 40

Write-Progress -Activity "Module Installation"  -Status "Copy Module to PowershellModules folder" -PercentComplete 50
Move-Item -Path "${tempFile}\$RepoName-master\$moduleToLoad" -Destination "$ProfileModulePath";
Write-Progress -Activity "Module Installation"  -Status "Copy Module to PowershellModules folder" -PercentComplete 60

Write-Progress -Activity "Module Installation"  -Status "Finishing Installation and Cleanup " -PercentComplete 80
Remove-Item "${tempFile}*" -Recurse -ErrorAction SilentlyContinue;
Write-Progress -Activity "Module Installation"  -Status "Module installed sucessaful "