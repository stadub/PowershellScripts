# Pester 4.x: no real network, profile data, or update-cache writes.
. $PSScriptRoot/Shared-Functions.ps1

Describe 'Bookmarks automatic update checks' {
    BeforeEach {
        $script:savedCheck = $env:BOOKMARKS_UPDATE_CHECK
        $script:savedInterval = $env:BOOKMARKS_UPDATE_CHECK_INTERVAL_HOURS
        $env:BOOKMARKS_UPDATE_CHECK = '1'
        $env:BOOKMARKS_UPDATE_CHECK_INTERVAL_HOURS = $null
        $script:updateCache = Join-Path $TestDrive ([guid]::NewGuid().ToString() + '.timestamp')
        $script:checkNow = [datetime]'2026-01-01T00:00:00Z'
        Mock Get-PSGalleryUpdateCachePath { $script:updateCache }
        Mock Get-Date { $script:checkNow }
        Mock Invoke-WebRequest {
            @{ Content = '<feed><entry><properties><Version>2.2.0</Version></properties></entry></feed>' }
        }
        Mock Write-Host {}
    }

    AfterEach {
        $env:BOOKMARKS_UPDATE_CHECK = $script:savedCheck
        $env:BOOKMARKS_UPDATE_CHECK_INTERVAL_HOURS = $script:savedInterval
    }

    It 'does no network or cache work when disabled' {
        foreach ($value in @('0', 'false', 'OFF')) {
            $env:BOOKMARKS_UPDATE_CHECK = $value
            CheckPsGalleryUpdate Bookmarks '2.2.0'
        }
        Assert-MockCalled -Scope It Invoke-WebRequest -Times 0 -Exactly
        Assert-MockCalled -Scope It Get-PSGalleryUpdateCachePath -Times 0 -Exactly
    }

    It 'imports the real module repeatedly with checks disabled and no requests' {
        $savedAppData = $env:APPDATA
        $modulePath = Join-Path $PSScriptRoot 'Bookmarks.psd1'
        try {
            $env:APPDATA = Join-Path $TestDrive 'profile'
            # Avoid unrelated first-run directory output from the existing profile helper.
            $null = New-Item -ItemType Directory -Path (Join-Path $env:APPDATA '.ps1/ScriptData/Bookmarks') -Force
            $env:BOOKMARKS_UPDATE_CHECK = '0'
            @(Import-Module $modulePath -Force).Count | Should -Be 0
            @(Import-Module $modulePath -Force).Count | Should -Be 0
            Assert-MockCalled -Scope It Invoke-WebRequest -Times 0 -Exactly
            (Test-Path -LiteralPath $script:updateCache) | Should -Be $false
        }
        finally {
            Remove-Module Bookmarks -ErrorAction SilentlyContinue
            $env:APPDATA = $savedAppData
        }
    }

    It 'defaults to 24 hours with checks enabled when configuration is absent' {
        $env:BOOKMARKS_UPDATE_CHECK = $null
        CheckPsGalleryUpdate Bookmarks '2.2.0'
        $script:checkNow = $script:checkNow.AddHours(23)
        CheckPsGalleryUpdate Bookmarks '2.2.0'
        Assert-MockCalled -Scope It Invoke-WebRequest -Times 1 -Exactly
        $script:checkNow = $script:checkNow.AddHours(1)
        CheckPsGalleryUpdate Bookmarks '2.2.0'
        Assert-MockCalled -Scope It Invoke-WebRequest -Times 2 -Exactly
    }

    It 'persists the interval across repeated checks and helper reloads' {
        CheckPsGalleryUpdate Bookmarks '2.2.0'
        # Like a forced import/new module scope, reload without retaining script state.
        . $PSScriptRoot/Shared-Functions.ps1
        Mock Get-PSGalleryUpdateCachePath { $script:updateCache }
        CheckPsGalleryUpdate Bookmarks '2.2.0'
        CheckPsGalleryUpdate Bookmarks '2.2.0'
        Assert-MockCalled -Scope It Invoke-WebRequest -Times 1 -Exactly
    }

    It 'honors the configured interval and checks at expiry' {
        $env:BOOKMARKS_UPDATE_CHECK_INTERVAL_HOURS = '168'
        CheckPsGalleryUpdate Bookmarks '2.2.0'
        $script:checkNow = $script:checkNow.AddHours(167)
        CheckPsGalleryUpdate Bookmarks '2.2.0'
        Assert-MockCalled -Scope It Invoke-WebRequest -Times 1 -Exactly
        $script:checkNow = $script:checkNow.AddHours(1)
        CheckPsGalleryUpdate Bookmarks '2.2.0'
        Assert-MockCalled -Scope It Invoke-WebRequest -Times 2 -Exactly
    }

    It 'falls back to 24 hours for invalid intervals' {
        foreach ($value in @('garbage', '0', '-1', '1.5', '8761', '99999999999999')) {
            $script:updateCache = Join-Path $TestDrive ([guid]::NewGuid().ToString() + '.timestamp')
            $env:BOOKMARKS_UPDATE_CHECK_INTERVAL_HOURS = $value
            CheckPsGalleryUpdate Bookmarks '2.2.0'
            $script:checkNow = $script:checkNow.AddHours(1)
            CheckPsGalleryUpdate Bookmarks '2.2.0'
        }
        Assert-MockCalled -Scope It Invoke-WebRequest -Times 6 -Exactly
    }

    It 'bounds requests with timeout and disables redirects' {
        CheckPsGalleryUpdate Bookmarks '2.2.0'
        Assert-MockCalled -Scope It Invoke-WebRequest -Times 1 -Exactly -ParameterFilter {
            $TimeoutSec -eq 3 -and $MaximumRedirection -eq 0 -and $UseBasicParsing -and
            $Uri -like '*$filter=IsLatestVersion&$top=1'
        }
    }

    It 'silently backs off remote errors including under ErrorActionPreference Stop' {
        Mock Invoke-WebRequest { throw 'Offline' }
        $oldPreference = $ErrorActionPreference
        try {
            $ErrorActionPreference = 'Stop'
            { CheckPsGalleryUpdate Bookmarks '2.2.0' } | Should -Not -Throw
            CheckPsGalleryUpdate Bookmarks '2.2.0'
            Assert-MockCalled -Scope It Invoke-WebRequest -Times 1 -Exactly
            $script:checkNow = $script:checkNow.AddHours(24)
            CheckPsGalleryUpdate Bookmarks '2.2.0'
            Assert-MockCalled -Scope It Invoke-WebRequest -Times 2 -Exactly
        }
        finally { $ErrorActionPreference = $oldPreference }
        Assert-MockCalled -Scope It Write-Host -Times 0 -Exactly
    }

    It 'quietly backs off malformed feeds' {
        Mock Invoke-WebRequest { @{ Content = 'not XML' } }
        { CheckPsGalleryUpdate Bookmarks '2.2.0' } | Should -Not -Throw
        CheckPsGalleryUpdate Bookmarks '2.2.0'
        Assert-MockCalled -Scope It Invoke-WebRequest -Times 1 -Exactly
        Assert-MockCalled -Scope It Write-Host -Times 0 -Exactly
    }

    It 'uses numeric versions and host output without polluting the success stream' {
        Mock Invoke-WebRequest {
            @{ Content = '<feed><entry><properties><Version>2.10.0</Version></properties></entry></feed>' }
        }
        @(CheckPsGalleryUpdate Bookmarks '2.9.0').Count | Should -Be 0
        Assert-MockCalled -Scope It Write-Host -Times 1 -Exactly -ParameterFilter {
            $Object -like '*2.10.0*Update-Module -Name Bookmarks -Force*'
        }
    }

    It 'does not announce an older numeric version' {
        Mock Invoke-WebRequest {
            @{ Content = '<feed><entry><properties><Version>2.9.0</Version></properties></entry></feed>' }
        }
        @(CheckPsGalleryUpdate Bookmarks '2.10.0').Count | Should -Be 0
        Assert-MockCalled -Scope It Write-Host -Times 0 -Exactly
    }

    It 'recovers a corrupt timestamp and throttles subsequent checks' {
        Set-Content -LiteralPath $script:updateCache -Value 'corrupt'
        CheckPsGalleryUpdate Bookmarks '2.2.0'
        CheckPsGalleryUpdate Bookmarks '2.2.0'
        Assert-MockCalled -Scope It Invoke-WebRequest -Times 1 -Exactly
    }

    It 'skips requests when cache storage is unavailable' {
        Mock Get-PSGalleryUpdateCachePath { throw 'Storage unavailable' }
        { CheckPsGalleryUpdate Bookmarks '2.2.0' } | Should -Not -Throw
        CheckPsGalleryUpdate Bookmarks '2.2.0'
        Assert-MockCalled -Scope It Invoke-WebRequest -Times 0 -Exactly
    }

    It 'skips a busy cache without waiting or requesting' {
        $lock = [IO.File]::Open($script:updateCache, 'OpenOrCreate', 'ReadWrite', 'None')
        try {
            { CheckPsGalleryUpdate Bookmarks '2.2.0' } | Should -Not -Throw
            Assert-MockCalled -Scope It Invoke-WebRequest -Times 0 -Exactly
        }
        finally { $lock.Dispose() }
        CheckPsGalleryUpdate Bookmarks '2.2.0'
        Assert-MockCalled -Scope It Invoke-WebRequest -Times 1 -Exactly
    }
}
