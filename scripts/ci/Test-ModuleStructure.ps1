[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('FolderEncoder', 'Shell-Functions', 'Uninstall')][string]$Module,
    [Parameter(Mandatory)][string]$SourceRoot
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path $SourceRoot).Path
$entry = switch ($Module) {
    FolderEncoder { Join-Path $root 'FolderEncoder/FolderEncoder.psd1' }
    Shell-Functions {
        $canonical = Join-Path $root 'Shell-Functions/Shell-Functions.psd1'
        if (Test-Path $canonical -PathType Leaf) { $canonical }
        else { Join-Path $root 'Shell-Functions/Shell-Function.psd1' }
    }
    Uninstall {
        $canonical = Join-Path $root 'MiniModules.Uninstall.psd1'
        if (Test-Path $canonical -PathType Leaf) { $canonical }
        else { Join-Path $root 'Uninstall.psm1' }
    }
}
$results = Join-Path $root 'TestResults'
New-Item $results -ItemType Directory -Force | Out-Null
$cases = [System.Collections.Generic.List[string]]::new()
$loaded = $null
function Add-Check([string]$Name, [scriptblock]$Action) {
    $safeName = [Security.SecurityElement]::Escape("$Module.$Name")
    try {
        & $Action
        $cases.Add("<test-case name=`"$safeName`" executed=`"True`" success=`"True`" />")
    } catch {
        $message = [Security.SecurityElement]::Escape($_.Exception.Message)
        $cases.Add("<test-case name=`"$safeName`" executed=`"True`" success=`"False`"><failure><message>$message</message></failure></test-case>")
        throw
    }
}
try {
    Add-Check 'syntax' {
        if (-not (Test-Path $entry -PathType Leaf)) { throw "Module entry missing: $entry" }
        $files = if ($Module -eq 'Uninstall') { @(Get-Item $entry) + @(Get-Item (Join-Path $root 'Uninstall.psm1')) | Sort-Object FullName -Unique } else {
            @(Get-ChildItem (Split-Path $entry) -File -Recurse | Where-Object {
                $_.Extension -in '.ps1', '.psm1', '.psd1' -and $_.FullName -notmatch '[/\\]out[/\\]'
            })
        }
        foreach ($file in $files) {
            $tokens = $null; $parseErrors = $null
            [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$parseErrors) | Out-Null
            if ($parseErrors.Count) { throw "Syntax errors in $($file.Name): $($parseErrors.Message -join '; ')" }
        }
    }
    if ([IO.Path]::GetExtension($entry) -eq '.psd1') {
        Add-Check 'manifest' { Test-ModuleManifest $entry -ErrorAction Stop | Out-Null }
    }
    # Import into this script's local scope, then remove by module object in finally.
    $loaded = Import-Module $entry -Force -PassThru -ErrorAction Stop
    Add-Check 'exports' {
        if ($loaded.ExportedCommands.Count -eq 0) { throw "$Module imports but exports no commands" }
        if ($Module -eq 'Uninstall') {
            $command = $loaded.ExportedFunctions['Uninstall-Application']
            if (-not $command -or -not $command.Parameters.ContainsKey('SoftwareName') -or
                'Application' -notin $command.Parameters['SoftwareName'].Aliases) {
                throw 'Uninstall-Application command/parameter contract is missing'
            }
            # Never call this command: it accesses HKLM and starts msiexec.
        }
    }
    Write-Host "$Module syntax, import and export checks passed."
} catch {
    # Import failures must be represented in the uploaded report too.
    if (-not ($cases | Where-Object { $_ -like '*success="False"*' })) {
        $message = [Security.SecurityElement]::Escape($_.Exception.Message)
        $cases.Add("<test-case name=`"$Module.import`" executed=`"True`" success=`"False`"><failure><message>$message</message></failure></test-case>")
    }
    throw
} finally {
    if ($loaded) { Remove-Module $loaded -Force -ErrorAction SilentlyContinue }
    $failures = @($cases | Where-Object { $_ -like '*success="False"*' }).Count
    $xml = "<test-results name=`"$Module structure`" total=`"$($cases.Count)`" errors=`"0`" failures=`"$failures`"><test-suite name=`"$Module`" executed=`"True`" success=`"$($failures -eq 0)`"><results>$($cases -join '')</results></test-suite></test-results>"
    $xml | Set-Content (Join-Path $results "$Module-structure.xml") -Encoding UTF8
}
