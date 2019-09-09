Import-Module .\7zip-Archive.psm1


ls -Exclude .git | New-ZipFile "scripts"
Test-ZipFileContent .\scripts.7z
Get-ZipFileContent  -Archive .\scripts.7z 
Remove-ZipFileContent -Archive .\scripts.7z -File "temp.log"
Read-ZipFile -Archive .\scripts.7z
Add-ZipFileContent -Path .\scripts.7z -FileName .\7zip-Archive.psd1