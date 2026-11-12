$manifest = Join-Path $PSScriptRoot 'Pipe.psd1'
Describe 'Pipe source imports and aliases' {
    BeforeAll {
        $script:importOutput = @(Import-Module $manifest -Force -PassThru -WarningAction SilentlyContinue)
    }
    AfterAll { Remove-Module Pipe -ErrorAction SilentlyContinue }

    It 'validates the source manifest and imports without example output' {
        (Test-ModuleManifest $manifest).Name | Should -Be 'Pipe'
        $script:importOutput.Count | Should -Be 1
        $script:importOutput[0] | Should -BeOfType System.Management.Automation.PSModuleInfo
    }
    It 'exports six filters and eight aliases with valid targets' {
        $module = Get-Module Pipe
        $module.ExportedFunctions.Count | Should -Be 6
        $module.ExportedAliases.Count | Should -Be 8
        foreach ($alias in $module.ExportedAliases.Values) {
            $module.ExportedFunctions.ContainsKey($alias.Definition) | Should -BeTrue
        }
    }
    It 'filters type through each reconciled alias' -TestCases @(
        @{ Name = 'wtype' }, @{ Name = 'filter-type' }, @{ Name = 'where-type' }
    ) {
        param($Name)
        @('text', 1, 2 | & $Name -TypeName String).Count | Should -Be 1
        'text', 1, 2 | & $Name -TypeName String | Should -BeExactly 'text'
    }
    It 'supports assignable types and wildcard names' {
        @(1, 'text' | Limit-Type -Type ([object]) -Strict $false).Count | Should -Be 2
        1, 'text' | Limit-Type -TypeName '*str*' -Strict $false | Should -BeExactly 'text'
    }
    It 'preserves skip, take, last, and suppression behavior' {
        (1..5 | skip -Count 2 | take -Count 2) -join ',' | Should -BeExactly '3,4'
        1..5 | last | Should -Be 5
        @(1..5 | suppress).Count | Should -Be 0
    }
    It 'exports aliases through a second clean import' {
        Remove-Module Pipe
        Import-Module $manifest -Force -WarningAction SilentlyContinue
        (Get-Alias wtype).Definition | Should -BeExactly 'Limit-Type'
    }
}
