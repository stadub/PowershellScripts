$manifest = Join-Path $PSScriptRoot 'FolderEncoder.psd1'
Describe 'FolderEncoder source import' {
    BeforeAll {
        Push-Location $TestDrive
        try { $script:loaded = @(Import-Module $manifest -Force -PassThru -ErrorAction Stop) }
        finally { Pop-Location }
    }
    AfterAll { Remove-Module FolderEncoder -Force -ErrorAction SilentlyContinue }
    It 'validates the restored manifest and exports the documented command' {
        (Test-ModuleManifest $manifest).Name | Should -BeExactly 'FolderEncoder'
        $script:loaded.Count | Should -Be 1
        $script:loaded[0].ExportedFunctions.Count | Should -Be 1
        $script:loaded[0].ExportedFunctions.ContainsKey('Invoke-FolderEncode') | Should -BeTrue
    }
    It 'keeps the destination mandatory and source optional' {
        $command = $script:loaded[0].ExportedFunctions['Invoke-FolderEncode']
        @($command.Parameters['DestFolder'].Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] })[0].Mandatory | Should -BeTrue
        @($command.Parameters['SrcFolder'].Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] })[0].Mandatory | Should -BeFalse
    }
    It 'does not encode, initialize key files or install tools during import' {
        @(Get-ChildItem $TestDrive -Force -Recurse).Count | Should -Be 0
        $script:loaded[0].ExportedFunctions.ContainsKey('CheckUtils') | Should -BeFalse
        $script:loaded[0].ExportedFunctions.ContainsKey('EncodeFile') | Should -BeFalse
    }
}
