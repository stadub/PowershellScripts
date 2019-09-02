$DebugPreference = "Continue"

Set-StrictMode -version Latest

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

. $PSScriptRoot\Shared-Functions.ps1

. $PSScriptRoot\Functions.ps1

_Initalize


Describe "Test-7ZipInstall" {

    It "Try to download utill when it doesnt exit" {

        Mock -CommandName Receive-File -MockWith {}
        Mock -CommandName Extract-ZipFile -MockWith {}
        Mock -CommandName Get-TempFileName -MockWith { return "${pwd}/7Zip.ps1"}       
        
        Test-7ZipInstall 

        Assert-MockCalled Receive-File 1 
        Assert-MockCalled Extract-ZipFile 1 
        Assert-MockCalled Get-TempFileName 1 
    }
}


Describe "Start-7Zip" {

    It "Starts 7zip process" {

        Mock -CommandName Test-7ZipInstall -MockWith {}
        Mock -CommandName Start-Process -MockWith { @{ExitCode=0}}
        $script:_7zPath="${pwd}/7Zip.ps1"

        Start-7Zip "${pwd}/7Zip.ps1"

        Assert-MockCalled Start-Process 1 
        Assert-MockCalled Test-7ZipInstall 1 
    }

    It "Should throw on not zero exit code" {

        Mock -CommandName Test-7ZipInstall -MockWith {}
        Mock -CommandName Start-Process -MockWith { @{ExitCode=3}}
        $script:_7zPath="${pwd}/7Zip.ps1"

        $exception=$null
        try {
            Start-7Zip "${pwd}/7Zip.ps1"
            
        }
        catch {
            $exception=$_
        }

                
        $exception.Count | Should -Be 1

        $exception  | Should  BeOfType System.Management.Automation.ErrorRecord
        $exception.Exception  | Should  BeOfType System.Management.Automation.RuntimeException


        Assert-MockCalled Start-Process 1 
        Assert-MockCalled Test-7ZipInstall 1 
    }
}

Describe "Read-ZipFile" {

    It "Check weither 7zip bin exist, execute 7zip worker and check file hash" {

        Mock -CommandName Test-7ZipInstall -MockWith {}
        Mock -CommandName Start-Process -MockWith { @{ExitCode=0}}
        $script:_7zPath="${pwd}/7Zip.ps1"

        Read-ZipFile -ArchiveName "${pwd}/7Zip.ps1"

        Assert-MockCalled Start-Process 1 
        Assert-MockCalled Test-7ZipInstall 1 
    }
}

Describe "Add-ZipFileContent" {

    It "Check weither 7zip bin exist, create hash and starts worker" {

        Mock -CommandName Test-7ZipInstall -MockWith {}
        Mock -CommandName Start-Process -MockWith { @{ExitCode=0}}
        #Mock -CommandName Get-FileHash -MockWith { "hash"}

        $script:_7zPath="${pwd}/7Zip.ps1"

        Add-ZipFileContent -ArchiveName "${pwd}/7Zip.ps1" -FileName "${pwd}/7Zip.ps1"

        Assert-MockCalled Start-Process 1 
        #Assert-MockCalled Get-FileHash 1 
        Assert-MockCalled Test-7ZipInstall 1 
    }
}

Describe "Remove-ZipFileContent" {

    It "Check weither 7zip bin exist, starts worker and remove hash" {

        Mock -CommandName Test-7ZipInstall -MockWith {}
        Mock -CommandName Start-Process -MockWith { @{ExitCode=0}}
        #Mock -CommandName Remove-Hash -MockWith { "hash"}

        $script:_7zPath="${pwd}/7Zip.ps1"

        Remove-ZipFileContent -ArchiveName "${pwd}/7Zip.ps1" -FileName "${pwd}/7Zip.ps1"

        Assert-MockCalled Start-Process 1 
        #Assert-MockCalled Remove-Hash 1 
        Assert-MockCalled Test-7ZipInstall 1 
    }
}


Describe "New-ZipFile" {

    It "Check weither 7zip bin exist, create hash and starts worker" {

        Mock -CommandName Test-7ZipInstall -MockWith {}
        Mock -CommandName Start-Process -MockWith { @{ExitCode=0}}
        #Mock -CommandName WriteHash -MockWith { "hash"}

        $script:_7zPath="${pwd}/7Zip.ps1"

        New-ZipFile -ArchiveName "${pwd}/7Zip.ps1"  -Filenames "${pwd}/7Zip.ps1", "${pwd}/7Zip.ps1", "${pwd}/7Zip.ps1"

        Assert-MockCalled Start-Process 1 
        #Assert-MockCalled WriteHash 1 
        Assert-MockCalled Test-7ZipInstall 1 
    }
}


Describe "Get-ZipFileContent" {

    It "Check weither 7zip bin exist, create hash and starts worker" {

        Mock -CommandName Test-7ZipInstall -MockWith {}
        Mock -CommandName Start-Process -MockWith { @{ExitCode=0}}
        #Mock -CommandName Check-Hash -MockWith { $true}

        $script:_7zPath="${pwd}/7Zip.ps1"

        Get-ZipFileContent -ArchiveName "${pwd}/7Zip.ps1"  -FileName "${pwd}/7Zip.ps1"

        Assert-MockCalled Start-Process 1 
        #Assert-MockCalled Check-Hash 1 
        Assert-MockCalled Test-7ZipInstall 1 
    }
}

Describe "Test-ZipFileContent" {

    It "Check weither 7zip bin exist, create hash and starts worker" {

        Mock -CommandName Test-7ZipInstall -MockWith {}
        Mock -CommandName Start-Process -MockWith { @{ExitCode=0}}
        #Mock -CommandName Check-Hash -MockWith { $true}

        $script:_7zPath="${pwd}/7Zip.ps1"

        Test-ZipFileContent -ArchiveName "${pwd}/7Zip.ps1"  -FileName "${pwd}/7Zip.ps1"

        Assert-MockCalled Start-Process 1 
        #Assert-MockCalled Check-Hash 1 
        Assert-MockCalled Test-7ZipInstall 1 
    }
}