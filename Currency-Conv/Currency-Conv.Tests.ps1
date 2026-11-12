# Pester 4 tests: source functions only, never import the interactive module.
. $PSScriptRoot/Shared-Functions.ps1
. $PSScriptRoot/Functions.ps1

# MemoryCache uses the real system clock. This double models its absolute expiry
# contract using the same deterministic clock as Get-Date, without sleeps.
function New-TestCurrencyCache {
    $cache = New-Object PSObject -Property @{ Entries = @{} }
    $cache | Add-Member ScriptMethod Get {
        param($key)
        if ($this.Entries.ContainsKey($key)) {
            $entry = $this.Entries[$key]
            if ($entry.ExpiresAt -gt $script:cacheNow) { return $entry.Value }
            $this.Entries.Remove($key)
        }
        return $null
    }
    $cache | Add-Member ScriptMethod Add {
        param($key, $value, $expiresAt)
        $this.Entries[$key] = @{ Value = $value; ExpiresAt = $expiresAt }
        return $true
    }
    return $cache
}

Describe 'Currency cache lifetimes' {
    BeforeEach {
        $script:cacheNow = [DateTimeOffset]'2030-01-01T00:00:00Z'
        $script:currenciesCache = New-TestCurrencyCache
        $script:requestNumber = 0
        Mock Get-Date { $script:cacheNow.UtcDateTime }
        Mock PerformWebRequest {
            $script:requestNumber++
            [PSCustomObject]@{ results = $script:requestNumber }
        }
    }

    It 'refreshes <func> once per lifetime, including repeated expiration cycles' -TestCases @(
        @{ func = 'convert'; lifetime = [TimeSpan]::FromSeconds(60) }
        @{ func = 'countries'; lifetime = [TimeSpan]::FromHours(15) }
        @{ func = 'currencies'; lifetime = [TimeSpan]::FromHours(15) }
    ) {
        param($func, $lifetime)
        (PerformCahcedWebRequest $func $lifetime).results | Should -Be 1
        $script:cacheNow = $script:cacheNow.Add($lifetime).AddTicks(-1)
        (PerformCahcedWebRequest $func $lifetime).results | Should -Be 1
        Assert-MockCalled PerformWebRequest 1 -Exactly -Scope It
        $script:cacheNow = $script:cacheNow.AddTicks(1)
        (PerformCahcedWebRequest $func $lifetime).results | Should -Be 2
        (PerformCahcedWebRequest $func $lifetime).results | Should -Be 2
        Assert-MockCalled PerformWebRequest 2 -Exactly -Scope It
        $script:cacheNow = $script:cacheNow.Add($lifetime)
        (PerformCahcedWebRequest $func $lifetime).results | Should -Be 3
        (PerformCahcedWebRequest $func $lifetime).results | Should -Be 3
        Assert-MockCalled PerformWebRequest 3 -Exactly -Scope It
    }

    It 'expires currency pairs independently and does not slide on hits' {
        $ttl = [TimeSpan]::FromSeconds(60)
        (PerformCahcedWebRequest convert $ttl USD_EUR).results | Should -Be 1
        $script:cacheNow = $script:cacheNow.AddSeconds(30)
        (PerformCahcedWebRequest convert $ttl EUR_USD).results | Should -Be 2
        (PerformCahcedWebRequest convert $ttl USD_EUR).results | Should -Be 1
        $script:cacheNow = $script:cacheNow.AddSeconds(30)
        (PerformCahcedWebRequest convert $ttl USD_EUR).results | Should -Be 3
        (PerformCahcedWebRequest convert $ttl EUR_USD).results | Should -Be 2
        Assert-MockCalled PerformWebRequest 3 -Exactly -Scope It
    }

    It 'keeps endpoint and argument boundaries distinct' {
        $ttl = [TimeSpan]::FromMinutes(1)
        (PerformCahcedWebRequest ab $ttl c).results | Should -Be 1
        (PerformCahcedWebRequest a $ttl bc).results | Should -Be 2
        (PerformCahcedWebRequest ab $ttl c).results | Should -Be 1
    }

    It 'starts the lifetime after the response arrives' {
        Mock PerformWebRequest {
            $script:cacheNow = $script:cacheNow.AddSeconds(10)
            [PSCustomObject]@{ results = 1 }
        }
        $null = PerformCahcedWebRequest convert ([TimeSpan]::FromSeconds(60)) USD_EUR
        $script:currenciesCache.Entries['convert:USD_EUR'].ExpiresAt |
            Should -Be ([DateTimeOffset]'2030-01-01T00:01:10Z')
    }

    It 'leaves valid keys intact and retries a failed refresh' {
        $ttl = [TimeSpan]::FromSeconds(60)
        $null = PerformCahcedWebRequest convert $ttl USD_EUR
        $null = PerformCahcedWebRequest countries ([TimeSpan]::FromHours(15))
        Mock PerformWebRequest { throw 'offline' } -ParameterFilter { $func -eq 'convert' }
        # A valid entry remains usable even while the provider is unavailable.
        (PerformCahcedWebRequest convert $ttl USD_EUR).results | Should -Be 1
        $script:cacheNow = $script:cacheNow.AddSeconds(60)
        { PerformCahcedWebRequest convert $ttl USD_EUR } | Should -Throw 'offline'
        (PerformCahcedWebRequest countries ([TimeSpan]::FromHours(15))).results | Should -Be 2
        $script:currenciesCache.Get('convert:USD_EUR') | Should -BeNullOrEmpty
        Mock PerformWebRequest { [PSCustomObject]@{ results = 9 } } -ParameterFilter { $func -eq 'convert' }
        (PerformCahcedWebRequest convert $ttl USD_EUR).results | Should -Be 9
        (PerformCahcedWebRequest convert $ttl USD_EUR).results | Should -Be 9
        Assert-MockCalled PerformWebRequest 1 -Exactly -Scope It -ParameterFilter { $func -eq 'countries' }
        Assert-MockCalled PerformWebRequest 3 -Exactly -Scope It -ParameterFilter { $func -eq 'convert' }
    }

    It 'does not cache <name> responses' -TestCases @(
        @{ name = 'null'; response = $null }
        @{ name = 'API error'; response = [PSCustomObject]@{ error = 'unavailable' } }
        @{ name = 'null results'; response = [PSCustomObject]@{ results = $null } }
    ) {
        param($name, $response)
        Mock PerformWebRequest { $response }
        { PerformCahcedWebRequest currencies ([TimeSpan]::FromHours(15)) } | Should -Throw
        { PerformCahcedWebRequest currencies ([TimeSpan]::FromHours(15)) } | Should -Throw
        Assert-MockCalled PerformWebRequest 2 -Exactly -Scope It
    }

    It 'returns uncached responses for zero and negative durations' {
        (PerformCahcedWebRequest countries ([TimeSpan]::Zero)).results | Should -Be 1
        (PerformCahcedWebRequest countries ([TimeSpan]::FromSeconds(-1))).results | Should -Be 2
        $script:currenciesCache.Entries.Count | Should -Be 0
    }

    It 'supports legacy absolute deadlines without returning null after expiry' {
        $deadline = $script:cacheNow.AddSeconds(60)
        (PerformCahcedWebRequest countries $deadline).results | Should -Be 1
        (PerformCahcedWebRequest countries $deadline).results | Should -Be 1
        $script:cacheNow = $deadline
        (PerformCahcedWebRequest countries $deadline).results | Should -Be 2
        (PerformCahcedWebRequest countries $deadline).results | Should -Be 3
    }

    It 'stores and reuses a response in the real MemoryCache' {
        $script:currenciesCache = New-Object System.Runtime.Caching.MemoryCache ([Guid]::NewGuid().ToString())
        try {
            Mock Get-Date { [DateTime]::UtcNow }
            (PerformCahcedWebRequest countries ([TimeSpan]::FromHours(1))).results | Should -Be 1
            (PerformCahcedWebRequest countries ([TimeSpan]::FromHours(1))).results | Should -Be 1
            Assert-MockCalled PerformWebRequest 1 -Exactly -Scope It
        } finally {
            $script:currenciesCache.Dispose()
        }
    }
}

Describe 'Currency public commands and initialization' {
    BeforeEach {
        $script:cacheNow = [DateTimeOffset]'2030-01-01T00:00:00Z'
        $script:currenciesCache = New-TestCurrencyCache
        Mock Get-Date { $script:cacheNow.UtcDateTime }
        Mock PerformWebRequest {
            switch ($func) {
                currencies { '{"results":{"ALL":{"id":"ALL"},"BBD":{"id":"BBD"}}}' | ConvertFrom-Json }
                countries { '{"results":{"AF":{"id":"AF"}}}' | ConvertFrom-Json }
                convert { '{"results":{"BBD_ALL":{"fr":"BBD","to":"ALL","val":55.122849}}}' | ConvertFrom-Json }
            }
        }
    }

    It 'uses the configured durations and preserves conversion output and aliases' {
        $names = @('CurrencyConvExchangeRateCahcheLifetime', 'CurrencyConvCountriesCahcheLifetime', 'CurrencyConvCurrenciesCahcheLifetime')
        $saved = @{}
        foreach ($name in $names) {
            $previous = Get-Variable $name -Scope Global -ErrorAction SilentlyContinue
            $saved[$name] = if ($null -ne $previous) { @{ Value = $previous.Value } } else { $null }
        }
        # Initialize with isolated dummy key/provider files, never the user's profile.
        Set-Content (Join-Path $TestDrive '.cur_api_key') 'test-only'
        Set-Content (Join-Path $TestDrive '.path') 'https://example.invalid'
        Mock CurrencyGet-ProfileDataFile { Join-Path $TestDrive $moduleName }
        try {
            _Initalize
            $global:CurrencyConvExchangeRateCahcheLifetime | Should -Be ([TimeSpan]::FromSeconds(60))
            $global:CurrencyConvCountriesCahcheLifetime | Should -Be ([TimeSpan]::FromHours(15))
            $global:CurrencyConvCurrenciesCahcheLifetime | Should -Be ([TimeSpan]::FromHours(15))
            $script:currenciesCache = New-TestCurrencyCache
            $rate = Get-ExchangeRate -Base BBD -Result ALL -Value 5
            $rate.From | Should -Be BBD
            $rate.To | Should -Be ALL
            $rate.Amount | Should -Be 5
            $rate.Rate | Should -Be 55.122849
            [Math]::Abs([double]$rate.Result - 275.614245) | Should -BeLessThan 0.000001
            (Get-Countries).AF.id | Should -Be AF
            @(Get-Currencies).Count | Should -Be 2
            $null = Get-ExchangeRate BBD ALL 1
            Assert-MockCalled PerformWebRequest 1 -Exactly -Scope It -ParameterFilter { $func -eq 'convert' -and $arg -eq 'BBD_ALL' }
            Assert-MockCalled PerformWebRequest 1 -Exactly -Scope It -ParameterFilter { $func -eq 'currencies' }
            Assert-MockCalled PerformWebRequest 1 -Exactly -Scope It -ParameterFilter { $func -eq 'countries' }
        } finally {
            foreach ($name in $names) {
                if ($null -ne $saved[$name]) { Set-Variable $name $saved[$name].Value -Scope Global }
                else { Remove-Variable $name -Scope Global }
            }
        }
    }

}

Describe 'Currency request failures' {
    It 'makes web errors terminating' {
        Mock Invoke-WebRequest { Write-Error 'offline' }
        $script:baseUrl = 'https://example.invalid'
        $script:apiKey = 'test-only'
        { PerformWebRequest convert USD_EUR } | Should -Throw 'offline'
        Assert-MockCalled Invoke-WebRequest 1 -Exactly -Scope It
    }
}
