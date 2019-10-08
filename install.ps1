
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

     $progressEventArgs = @{
        InputObject = $client
        EventName = 'DownloadProgressChanged'
        SourceIdentifier = 'ModuleDownload'
        Action = {
            
            Write-Progress -Activity "Module Installation" -Status `
             ("Downloading Module: {0} of {1}" -f $eventargs.BytesReceived, $eventargs.TotalBytesToReceive) `
             -PercentComplete $eventargs.ProgressPercentage 
        }
    }

    $completeEventArgs = @{
        InputObject = $client
        EventName = 'DownloadFileCompleted'
        SourceIdentifier = 'ModuleDownloadCompleted'
    }

     Register-ObjectEvent @progressEventArgs
     Register-ObjectEvent @completeEventArgs
 
     $client.DownloadFileAsync($url, $file)

     Wait-Event -SourceIdentifier ModuleDownloadCompleted
}
catch [System.Net.WebException]  
{  
    Write-Host("Cannot download $url")  
} 
finally { 
     $client.dispose()
     Unregister-Event -SourceIdentifier ModuleDownload
     Unregister-Event -SourceIdentifier ModuleDownloadCompleted
     
 
#avoid errors on already existing file
 try {
    Unblock-File -Path "${tempFile}.zip";

    Write-Progress -Activity "Module Installation"  -Status "Unpacking Module" -PercentComplete 0

    Add-Type -AssemblyName System.IO.Compression.FileSystem;
    [System.IO.Compression.ZipFile]::ExtractToDirectory("${tempFile}.zip", "${tempFile}");
 }
 catch {  }

Write-Progress -Activity "Module Installation"  -Status "Unpacking Module" -PercentComplete 40

Write-Progress -Activity "Module Installation"  -Status "Copy Module to PowershellModules folder" -PercentComplete 50
Move-Item -Path "${tempFile}\$RepoName-master\$moduleToLoad" -Destination "$ProfileModulePath"
Write-Progress -Activity "Module Installation"  -Status "Copy Module to PowershellModules folder" -PercentComplete 60

Write-Progress -Activity "Module Installation"  -Status "Finishing Installation and Cleanup " -PercentComplete 80
Remove-Item "${tempFile}*" -Recurse -ErrorAction SilentlyContinue;
Write-Progress -Activity "Module Installation"  -Status "Module installed sucessaful "

Write-Host "Module installation complete"

Write-Host "Use ''Import-Module $module'' to start using module"