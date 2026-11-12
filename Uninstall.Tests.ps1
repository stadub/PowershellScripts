$manifest = Join-Path $PSScriptRoot 'MiniModules.Uninstall.psd1'
Describe 'Uninstall module packaging contracts' {
    BeforeAll {
        $script:loaded = Import-Module $manifest -Force -PassThru -ErrorAction Stop
    }
    AfterAll { Remove-Module $script:loaded -Force -ErrorAction SilentlyContinue }
    It 'validates the manifest and unchanged public command' {
        (Test-ModuleManifest $manifest).Version.ToString() | Should -BeExactly '1.0.1'
        $script:loaded.Name | Should -BeExactly 'MiniModules.Uninstall'
        (Import-PowerShellDataFile $manifest).RootModule | Should -BeExactly 'Uninstall.psm1'
        $script:loaded.ExportedFunctions.Count | Should -Be 1
        $script:loaded.ExportedFunctions.ContainsKey('Uninstall-Application') | Should -BeTrue
    }
    It 'preserves the mandatory pipeline software-name parameter and Application alias' {
        $command = $script:loaded.ExportedFunctions['Uninstall-Application']
        $parameter = $command.Parameters['SoftwareName']
        $parameter.Aliases | Should -Contain 'Application'
        $contract = @($parameter.Attributes | Where-Object { $_ -is [Management.Automation.ParameterAttribute] })[0]
        $contract.Mandatory | Should -BeTrue
        $contract.ValueFromPipeline | Should -BeTrue
    }
    It 'imports safely without starting an uninstaller or reading registry entries' {
        Mock Start-Process { throw 'Unexpected uninstaller invocation' }
        Mock Get-ItemProperty { throw 'Unexpected registry access' }
        Import-Module $manifest -Force -ErrorAction Stop
        Assert-MockCalled Start-Process 0 -Exactly -Scope It
        Assert-MockCalled Get-ItemProperty 0 -Exactly -Scope It
    }
}
