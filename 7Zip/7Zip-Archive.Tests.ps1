Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'Shared-Functions.ps1')
. (Join-Path $PSScriptRoot 'Functions.ps1')

Describe 'Installed runtime discovery (offline)' {
    BeforeEach {
        $script:savedRuntime = $env:SEVENZIP_PATH
        $script:savedRoots = @($env:ProgramW6432, $env:ProgramFiles, ${env:ProgramFiles(x86)})
        $env:SEVENZIP_PATH = $null
        _Initalize
        Mock Get-7ZipPlatform { 'Unix' }
        Mock Get-Command { $null } -ParameterFilter { $CommandType -eq 'Application' }
        Mock szReceive-File { throw 'Unexpected download' }
        Mock New-Item { throw 'Unexpected installation' }
        Mock Test-Path { $false }
    }
    AfterEach {
        $env:SEVENZIP_PATH = $script:savedRuntime
        $env:ProgramW6432 = $script:savedRoots[0]
        $env:ProgramFiles = $script:savedRoots[1]
        ${env:ProgramFiles(x86)} = $script:savedRoots[2]
        Assert-MockCalled -Scope It szReceive-File -Times 0 -Exactly
        Assert-MockCalled -Scope It New-Item -Times 0 -Exactly
    }
    It 'prefers official Linux 7zz over 7z' {
        Mock Get-Command { [pscustomobject]@{Path='/opt/7zip/7zz'} } -ParameterFilter { $Name -eq '7zz' -and $CommandType -eq 'Application' }
        Test-7ZipInstall
        $script:_7zPath | Should -Be '/opt/7zip/7zz'
        Assert-MockCalled -Scope It Get-Command -Times 0 -ParameterFilter { $Name -eq '7z' }
    }
    It 'supports Linux 7z on PATH without p7zip' {
        Mock Get-Command { [pscustomobject]@{Path='/usr/bin/7z'} } -ParameterFilter { $Name -eq '7z' -and $CommandType -eq 'Application' }
        Test-7ZipInstall
        $script:_7zPath | Should -Be '/usr/bin/7z'
        Assert-MockCalled -Scope It Get-Command -Times 0 -ParameterFilter { $Name -eq 'p7zip' }
    }
    It 'supports existing 7za installations' {
        Mock Get-Command { [pscustomobject]@{Path='/usr/bin/7za'} } -ParameterFilter { $Name -eq '7za' -and $CommandType -eq 'Application' }
        Test-7ZipInstall
        $script:_7zPath | Should -Be '/usr/bin/7za'
    }
    It 'uses Windows 7z.exe on PATH' {
        Mock Get-7ZipPlatform { 'Win32NT' }
        Mock Get-Command { [pscustomobject]@{Path='C:\Tools\7z.exe'} } -ParameterFilter { $Name -eq '7z.exe' -and $CommandType -eq 'Application' }
        Test-7ZipInstall
        $script:_7zPath | Should -Be 'C:\Tools\7z.exe'
    }
    It 'finds native Windows Program Files from a 32-bit host' {
        Mock Get-7ZipPlatform { 'Win32NT' }
        # Host-neutral roots exercise Windows discovery even on Unix test hosts.
        $env:ProgramW6432 = "$TestDrive/Native Program Files"
        $env:ProgramFiles = "$TestDrive/Program Files (x86)"
        Mock Test-Path { $LiteralPath -eq (Join-Path $env:ProgramW6432 '7-Zip/7z.exe') }
        Test-7ZipInstall
        $script:_7zPath | Should -Be (Join-Path $env:ProgramW6432 '7-Zip/7z.exe')
    }
    It 'falls back to the x86 Windows install directory' {
        Mock Get-7ZipPlatform { 'Win32NT' }
        $env:ProgramW6432 = "$TestDrive/Native"
        $env:ProgramFiles = "$TestDrive/Native"
        ${env:ProgramFiles(x86)} = "$TestDrive/X86"
        Mock Test-Path { $LiteralPath -eq (Join-Path ${env:ProgramFiles(x86)} '7-Zip/7z.exe') }
        Test-7ZipInstall
        $script:_7zPath | Should -Be (Join-Path ${env:ProgramFiles(x86)} '7-Zip/7z.exe')
    }
    It 'honors a literal configured path with spaces and brackets before discovery' {
        $env:SEVENZIP_PATH = "$TestDrive/custom [runtime]/7zz"
        Mock Test-Path { $true }
        Mock Get-Item { [pscustomobject]@{FullName=$env:SEVENZIP_PATH} }
        Test-7ZipInstall
        $script:_7zPath | Should -Be $env:SEVENZIP_PATH
        Assert-MockCalled -Scope It Get-Command -Times 0 -ParameterFilter { $CommandType -eq 'Application' }
        Assert-MockCalled -Scope It Test-Path -Times 1 -ParameterFilter { $LiteralPath -eq $env:SEVENZIP_PATH -and $PathType -eq 'Leaf' }
    }
    It 'rejects an invalid override without falling back' {
        $env:SEVENZIP_PATH = "$TestDrive/missing"
        { Test-7ZipInstall } | Should -Throw 'SEVENZIP_PATH'
        $script:_7zPath | Should -BeNullOrEmpty
        Assert-MockCalled -Scope It Get-Command -Times 0 -ParameterFilter { $CommandType -eq 'Application' }
    }
    It 'rejects a relative override' {
        $env:SEVENZIP_PATH = '7zz'
        { Test-7ZipInstall } | Should -Throw 'full path'
    }
    It 'fails clearly for missing Unix runtimes and clears a stale selection' {
        $script:_7zPath = '/old/7zz'
        { Test-7ZipInstall } | Should -Throw 'No runtime is downloaded automatically'
        $script:_7zPath | Should -BeNullOrEmpty
    }
    It 'fails clearly for missing Windows runtimes' {
        Mock Get-7ZipPlatform { 'Win32NT' }
        Mock Test-Path { $false }
        { Test-7ZipInstall } | Should -Throw 'SEVENZIP_PATH'
    }
}

Describe 'Native process argument boundaries' {
    BeforeEach {
        Mock Test-7ZipInstall { $script:_7zPath = '/tools with spaces/7zz' }
        Mock Start-Process { [pscustomobject]@{ExitCode=0} }
    }
    It 'quotes paths, passwords, empty arguments, embedded quotes and trailing slashes' {
        Start-7Zip @('a', 'archive name.7z', '-ppass word', '', 'a"b', 'C:\folder\') | Should -Be 0
        Assert-MockCalled -Scope It Start-Process -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq '/tools with spaces/7zz' -and
            $ArgumentList -eq '"a" "archive name.7z" "-ppass word" "" "a\"b" "C:\folder\\"' -and $Wait -and $PassThru
        }
    }
    It 'throws on nonzero exit codes' {
        Mock Start-Process { [pscustomobject]@{ExitCode=2} }
        { Start-7Zip @('t', 'bad.7z') } | Should -Throw 'result code:2'
    }
    It 'does not launch when discovery fails' {
        Mock Test-7ZipInstall { throw 'missing runtime' }
        { Start-7Zip @('l', 'file.7z') } | Should -Throw 'missing runtime'
        Assert-MockCalled -Scope It Start-Process -Times 0 -Exactly
    }
}

Describe 'Public archive command argument regressions' {
    BeforeEach {
        Mock Test-Path { $true }
        Mock Start-7Zip { }
        Mock szCreateFolderIfNotExist { }
    }
    It 'preserves list, update, delete and integrity commands and passwords' {
        Read-ZipFile 'archive name.7z' -Password 'pass word'
        Assert-MockCalled -Scope It Start-7Zip -Times 1 -ParameterFilter { ($AllArgs -join '|') -eq 'l|archive name.7z|-ppass word' }
        Add-ZipFileContent 'archive name.7z' 'new file.txt' -Password 'pass word'
        Assert-MockCalled -Scope It Start-7Zip -Times 1 -ParameterFilter { ($AllArgs -join '|') -eq 'u|archive name.7z|new file.txt|-ppass word' }
        Remove-ZipFileContent 'archive name.7z' 'old file.txt'
        Assert-MockCalled -Scope It Start-7Zip -Times 1 -ParameterFilter { ($AllArgs -join '|') -eq 'd|archive name.7z|old file.txt' }
        Test-ZipFileContent 'archive name.7z' -File 'new file.txt'
        Assert-MockCalled -Scope It Start-7Zip -Times 1 -ParameterFilter { ($AllArgs -join '|') -eq 't|archive name.7z|new file.txt' }
    }
    It 'preserves extraction destination, overwrite and password switches' {
        Get-ZipFileContent 'archive name.7z' -File 'file.txt' -OutDir 'output dir' -Force $true -Password 'pass word'
        Assert-MockCalled -Scope It Start-7Zip -Times 1 -ParameterFilter { ($AllArgs -join '|') -eq 'e|archive name.7z|file.txt|-ooutput dir|-y|-ppass word' }
    }
    It 'preserves creation mode, compression, split volumes and pipeline file paths' {
        Mock Test-Path { $false } -ParameterFilter { $Path -like '*new archive*' }
        'file one.txt', 'file two.txt' | New-ZipFile 'new archive' -Compression Ultra -UpdateMode Sync -SplitSize 1,2 -SplitSizeFactor Megabyte -Password 'pass word'
        Assert-MockCalled -Scope It Start-7Zip -Times 1 -ParameterFilter { ($AllArgs -join '|') -eq 'u|new archive|-ppass word|-mx9|-uq0|file one.txt|file two.txt|-v1m|-v2m' }
    }
    It 'preserves filesystem pipeline input' {
        Mock Test-Path { $false } -ParameterFilter { $Path -like '*new archive*' }
        $file = Get-Item -LiteralPath (Join-Path $PSScriptRoot 'README.md')
        New-ZipFile 'new archive' -FSFiles $file
        Assert-MockCalled -Scope It Start-7Zip -Times 1 -ParameterFilter { $AllArgs[3] -eq $file.FullName }
    }
}

Describe 'Manifest help metadata' {
    It 'validates with no invalid updatable-help endpoint and retains the project URL' {
        $manifest = Join-Path $PSScriptRoot '7zip-Archive.psd1'
        $info = Test-ModuleManifest -Path $manifest -ErrorAction Stop
        $info.HelpInfoUri | Should -BeNullOrEmpty
        $data = Import-PowerShellDataFile $manifest
        $data.PrivateData.PSData.ProjectUri | Should -Be 'https://github.com/stadub/PowershellScripts/tree/master/7Zip'
        Test-Path -LiteralPath (Join-Path $PSScriptRoot $data.RootModule) | Should -Be $true
    }
}
