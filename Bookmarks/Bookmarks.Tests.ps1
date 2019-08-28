$NoExport = $true
$ModuleDevelopment = $true
$DebugPreference = "Continue"

Set-StrictMode -version Latest

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

. $PSScriptRoot\Shared-Functions.ps1

. $PSScriptRoot\Functions.ps1

_Initalize

Describe "Remove-AllPSBookmarks" {

    It "clear all bookmarks" {
        $_marks["a"]="A"
        $_marks["b"]="B"

        $_marks.Count | Should -Not -Be 0

        Mock -CommandName Import-Csv -MockWith {} -Verifiable
        Mock -CommandName Export-Csv -MockWith {} -Verifiable

        Remove-AllPSBookmarks

        $_marks.Count | Should -Be 0
    }
}

Describe "Add-PSBookmark" {

    It "adds current folder to bookmarks" {
        $_marks = @{ }
        Mock -CommandName Import-Csv -MockWith {} -Verifiable
        Mock -CommandName Export-Csv -MockWith {} -Verifiable

        Set-Location $here
        Add-PSBookmark testDir1
        $_marks.Count | Should -Be 1
        $_marks.Keys | Should -Be "testDir1"
        $_marks.Values | Should -Be $here
    }

    It "adds selected folder to bookmarks" {
        $_marks = @{ }
        Mock -CommandName Import-Csv -MockWith {} -Verifiable
        Mock -CommandName Export-Csv -MockWith {} -Verifiable

        Add-PSBookmark testDir2 "c:"
        $_marks = Get-PSBookmarks 
        $_marks.Count | Should -Be 1
        $_marks.Keys | Should -Be "testDir2"
        $_marks.Values | Should -Be "c:"
    }

    It "adds path from pipeline to bookmarks" {
        $_marks = @{ }
        Mock -CommandName Import-Csv -MockWith {} -Verifiable
        Mock -CommandName Export-Csv -MockWith {} -Verifiable

        "c:" |Add-PSBookmark testDir3 
        $_marks = Get-PSBookmarks 
        $_marks.Count | Should -Be 1
        $_marks.Keys | Should -Be "testDir3"
        $_marks.Values | Should -Be "c:"
    }
}


Describe "Remove-PSBookmark" {

    It "remove bookmark from list" {
        $_marks = @{ }
        $_marks["a"]="A";

        Mock -CommandName Import-Csv -MockWith {}
        Mock -CommandName Export-Csv -MockWith {}

        Mock -CommandName Restore-PSBookmarks -MockWith {} -Verifiable
        Mock -CommandName Save-PSBookmarks -MockWith {} -Verifiable
        
        $_marks.Count | Should -Be 1
        $_marks.Keys[0] | Should -Be "a"
        $_marks.Values[0] | Should -Be "A"

        Remove-PSBookmark  "a"

        $_marks.Count | Should -Be 0

        Assert-VerifiableMock
    }

}

Describe "Open-PSBookmark" {

    It "open specific bookmark" {
        $_marks = @{ }
        $_marks["a"]="A";

        Mock -CommandName Import-Csv -MockWith {} -Verifiable
        Mock -CommandName Export-Csv -MockWith {} -Verifiable

        Mock -CommandName Set-Location -MockWith {} 
    
        Open-PSBookmark "a"

        Assert-MockCalled Set-Location 1 

    }
}
    
Describe "Update-PSBookmark" {

    It "update current folder to bookmarks" {
        $_marks = @{ }
        Mock -CommandName Import-Csv -MockWith {} -Verifiable
        Mock -CommandName Export-Csv -MockWith {} -Verifiable

        Add-PSBookmark testDir1 "c:"

        Set-Location $here
        Update-PSBookmark testDir1
        $_marks.Count | Should -Be 1
        $_marks.Keys | Should -Be "testDir1"
        $_marks.Values | Should -Be $here
    }

    It "Update selected folder in bookmarks list" {
        $_marks = @{ }
        Mock -CommandName Import-Csv -MockWith {} -Verifiable
        Mock -CommandName Export-Csv -MockWith {} -Verifiable

        Add-PSBookmark testDir2 "c:"

        Update-PSBookmark testDir2 "$pwd"
        $_marks = Get-PSBookmarks 
        $_marks.Count | Should -Be 1
        $_marks.Keys | Should -Be "testDir2"
        $_marks.Values | Should -Be "$pwd"
    }

    It "Update path from pipeline to bookmarks" {
        $_marks = @{ }
        Mock -CommandName Import-Csv -MockWith {} -Verifiable
        Mock -CommandName Export-Csv -MockWith {} -Verifiable
        
        Add-PSBookmark testDir3 "$pwd"

        "c:" |Update-PSBookmark testDir3
        $_marks = Get-PSBookmarks 
        $_marks.Count | Should -Be 1
        $_marks.Keys | Should -Be "testDir3"
        $_marks.Values | Should -Be "c:"
    }
}