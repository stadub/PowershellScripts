# Exercise real CSV persistence in an isolated directory; never initialize a user profile.
Set-StrictMode -Version Latest
. $PSScriptRoot/Shared-Functions.ps1
. $PSScriptRoot/Functions.ps1

Describe 'Bookmark persistence and commands' {
    BeforeEach {
        $script:_marksPath = Join-Path $TestDrive 'Bookmarks.csv'
        Remove-Item $script:_marksPath -ErrorAction SilentlyContinue
    }

    It 'starts with no bookmarks when the store does not exist' {
        (Get-PSBookmarks).Count | Should -Be 0
    }

    It 'persists the current directory' {
        $null = Add-PSBookmark here
        (Get-PSBookmarks)['here'] | Should -BeExactly (Get-Location).Path
    }

    It 'persists explicit and pipeline paths including CSV punctuation and Unicode' {
        $path = Join-Path $TestDrive ('a,b' + [char]0x2642)
        $null = Add-PSBookmark explicit $path
        $null = $path | Add-PSBookmark piped
        $marks = Get-PSBookmarks
        $marks.Count | Should -Be 2
        $marks['explicit'] | Should -BeExactly $path
        $marks['piped'] | Should -BeExactly $path
    }

    It 'rejects duplicates without replacing the saved path' {
        $null = Add-PSBookmark a original
        { Add-PSBookmark a replaced } | Should -Throw
        (Get-PSBookmarks)['a'] | Should -BeExactly 'original'
    }

    It 'removes one bookmark while preserving others' {
        $null = Add-PSBookmark a first
        $null = Add-PSBookmark b second
        $null = Remove-PSBookmark a
        $marks = Get-PSBookmarks
        $marks.Count | Should -Be 1
        $marks['b'] | Should -BeExactly 'second'
    }

    It 'clears the persisted store' {
        $null = Add-PSBookmark a first
        Remove-AllPSBookmarks
        (Get-PSBookmarks).Count | Should -Be 0
    }

    It 'opens the persisted path' {
        $null = Add-PSBookmark a $TestDrive
        Mock Set-Location {}
        Open-PSBookmark a
        Assert-MockCalled Set-Location 1 -Exactly -ParameterFilter { $Path -eq $TestDrive }
    }

    It 'updates paths from an argument, pipeline, and current location' {
        $null = Add-PSBookmark a first
        $null = Update-PSBookmark a second
        (Get-PSBookmarks)['a'] | Should -BeExactly 'second'
        $null = 'third' | Update-PSBookmark a
        (Get-PSBookmarks)['a'] | Should -BeExactly 'third'
        $null = Update-PSBookmark a
        (Get-PSBookmarks)['a'] | Should -BeExactly (Get-Location).Path
    }

    It 'rejects updating a missing bookmark' {
        { Update-PSBookmark missing anything } | Should -Throw
        (Get-PSBookmarks).Count | Should -Be 0
    }

    It 'reloads external session changes on every operation' {
        $null = Add-PSBookmark a first
        @([pscustomobject]@{ Key = 'a'; Value = 'external' },
          [pscustomobject]@{ Key = 'b'; Value = 'other' }) |
            Export-Csv $script:_marksPath -NoTypeInformation
        $null = Add-PSBookmark c third
        $marks = Get-PSBookmarks
        $marks.Count | Should -Be 3
        $marks['a'] | Should -BeExactly 'external'
        $marks['b'] | Should -BeExactly 'other'
    }

    It 'returns an independent snapshot' {
        $null = Add-PSBookmark a first
        $marks = Get-PSBookmarks
        $marks['a'] = 'mutated'
        (Get-PSBookmarks)['a'] | Should -BeExactly 'first'
    }
}

Describe 'Bookmark manifest export contract' {
    It 'lists only implemented public functions without trailing whitespace' {
        $manifest = Import-PowerShellDataFile (Join-Path $PSScriptRoot 'Bookmarks.psd1')
        $expected = @('Add-PSBookmark', 'Remove-PSBookmark', 'Remove-AllPSBookmarks',
            'Open-PSBookmark', 'Get-PSBookmarks', 'Update-PSBookmark')
        ($manifest.FunctionsToExport | Sort-Object) -join ',' |
            Should -BeExactly (($expected | Sort-Object) -join ',')
        foreach ($name in $expected) { (Get-Command $name).CommandType | Should -Be 'Function' }
    }
}
