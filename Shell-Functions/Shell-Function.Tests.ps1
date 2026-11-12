$manifest = Join-Path $PSScriptRoot 'Shell-Functions.psd1'
$moduleName = 'Shell-Functions'
if (-not (Test-Path $manifest)) {
    $manifest = Join-Path $PSScriptRoot 'Shell-Function.psd1'
    $moduleName = 'Shell-Function'
}
Import-Module $manifest -Force -ErrorAction Stop
Describe 'Shell source imports and filters' {
    It 'exports callable functions and resolvable aliases from its manifest' {
        $module = Get-Module $moduleName
        $module.ExportedFunctions.Count | Should -Be 7
        $module.ExportedAliases.Count | Should -Be 7
        $module.ExportedAliases.ContainsKey('pb') | Should -BeFalse
        (Get-Alias fl).Definition | Should -BeExactly 'Format-List'
        foreach ($alias in $module.ExportedAliases.Values) {
            Get-Command $alias.Definition -ErrorAction Stop | Should -Not -BeNullOrEmpty
        }
        (Get-Command New-FileSystemLink).Parameters['type'].ParameterType.Name | Should -BeExactly 'LinkType'
    }
    It 'filters matching pipeline lines' {
        @('Alpha', 'Beta' | Get-SearchAndPrint 'alpha').Count | Should -Be 1
        'Alpha', 'Beta' | grep 'alpha' | Select-Object -ExpandProperty Line | Should -BeExactly 'Alpha'
    }
    It 'splits pipeline strings using the requested literal separator' {
        ('a,b' | cut ',') -join '|' | Should -BeExactly 'a|b'
        ('a::b::' | Split-String '::') -join '|' | Should -BeExactly 'a|b|'
        ('a b' | Split-String) -join '|' | Should -BeExactly 'a|b'
    }
}
InModuleScope $moduleName {
    Describe 'Link provider argument contracts' {
        It 'maps <Type> without creating a link' -TestCases @(
            @{ Type='Symbolic'; Expected='SymbolicLink' }
            @{ Type='Hard'; Expected='HardLink' }
            @{ Type='Junction'; Expected='Junction' }
        ) {
            param($Type, $Expected)
            Mock New-Item { [pscustomobject]@{ Path=$Path; ItemType=$ItemType; Value=$Value } }
            $result = New-FileSystemLink -source 'source file' -destanation 'dest path' -type $Type
            $result.Path | Should -BeExactly 'dest path'
            $result.Value | Should -BeExactly 'source file'
            $result.ItemType | Should -BeExactly $Expected
            Assert-MockCalled New-Item -Times 1 -Exactly -Scope It
        }
    }
}
Remove-Module $moduleName -Force
