

function CreateFolderIfNotExist {
    param ([string]$Folder)
    if( Test-Path $Folder -PathType Leaf){
        Write-Error "The destanation path ${Folder} is file."
    }

    if ( ! (Test-Path $Folder -PathType Container )) { 
        New-Item -Path $Folder  -ItemType 'Directory'
    }
}


function Test-Empty {
    param (
        [Parameter(Position = 0)]
        [string]$string
    )
    return [string]::IsNullOrWhitespace($string) 
}

function Get-ProfileDataFile {
    param (
        [string]$file,
        [string]$moduleName = $null
    )
    return Join-Path (Get-ProfileDir $moduleName) $file
    
}
function Get-ProfileDir {
    param (
        [string]$moduleName = $null,
        [string]$profileFolder = $null
    )
    
    $profileDir = $ENV:AppData

    if( Test-Empty $moduleName ){

        if ( $script:MyInvocation.MyCommand.Name.EndsWith('.psm1') ){
            $moduleName = $script:MyInvocation.MyCommand.Name
        }

        if ( $script:MyInvocation.MyCommand.Name.EndsWith('.ps1') ){
            $modulePath = Split-Path -Path $script:MyInvocation.MyCommand.Path
            $moduleName = Split-Path -Path $modulePath -Leaf
        }
    }

    if( Test-Empty $moduleName ){
        throw "Unable to read module name."             
    }
    
    $scriptProfile =  Combine-Path $profileDir '.ps1' 'ScriptData' $moduleName

    if( Test-Empty $profileFolder){
        $scriptProfile =  Combine-Path $profileDir '.ps1' 'ScriptData' $moduleName $profileFolder

    }
    if ( ! (Test-Path $scriptProfile -PathType Container )) { 
        New-Item -Path $scriptProfile  -ItemType 'Directory'
    }

    return $scriptProfile
}


function Combine-Path {
    param (
        [string]$baseDir,
        [string]$path
    )
    $allArgs = $PsBoundParameters.Values + $args

    [IO.Path]::Combine([string[]]$allArgs)
}

filter Last {
    BEGIN
    {
        $current=$null
    } 
    PROCESS
    {
        $current=$_
    }
    END
    {
        Write-Output  $current
    }
 }
 
# Kept separate from bookmark storage: update checks must not create profile data.
function Get-PSGalleryUpdateCachePath {
    param ([string]$moduleName)
    $root = [Environment]::GetFolderPath('LocalApplicationData')
    if ([string]::IsNullOrEmpty($root)) { return $null }
    Join-Path (Join-Path $root 'PowershellScripts/UpdateChecks') "$moduleName.timestamp"
}

function Test-PSGalleryUpdateCheckDue {
    param ([string]$moduleName, [int]$intervalHours)

    $stream = $null
    try {
        $path = Get-PSGalleryUpdateCachePath $moduleName
        if ([string]::IsNullOrEmpty($path)) { return $false }
        $null = [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($path))
        # An exclusive, non-waiting claim also throttles simultaneous imports.
        $stream = [IO.File]::Open($path, [IO.FileMode]::OpenOrCreate,
            [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
        $now = (Get-Date).ToUniversalTime().Ticks
        $previous = 0L
        if ($stream.Length -gt 0 -and $stream.Length -le 128) {
            $buffer = New-Object byte[] ([int]$stream.Length)
            $length = $stream.Read($buffer, 0, $buffer.Length)
            $null = [long]::TryParse([Text.Encoding]::UTF8.GetString($buffer, 0, $length), [ref]$previous)
        }
        if ($previous -gt 0 -and ($now - $previous) -lt [TimeSpan]::FromHours($intervalHours).Ticks) {
            return $false
        }
        # Record attempts before networking, so failures receive the same backoff.
        $buffer = [Text.Encoding]::UTF8.GetBytes($now.ToString([Globalization.CultureInfo]::InvariantCulture))
        $stream.Position = 0
        $stream.SetLength(0)
        $stream.Write($buffer, 0, $buffer.Length)
        $stream.Flush()
        return $true
    }
    catch {
        # If storage is locked or unavailable, skip rather than issue unthrottled requests.
        return $false
    }
    finally {
        if ($null -ne $stream) { $stream.Dispose() }
    }
}

function CheckPsGalleryUpdate {
    param (
        [string]$moduleName,
        [string]$currentVersion
    )

    try {
        if ($env:BOOKMARKS_UPDATE_CHECK -match '^(0|false|off)$') { return }
        $intervalHours = 24
        $configuredHours = 0
        if ([int]::TryParse($env:BOOKMARKS_UPDATE_CHECK_INTERVAL_HOURS, [ref]$configuredHours) -and
            $configuredHours -ge 1 -and $configuredHours -le 8760) {
            $intervalHours = $configuredHours
        }
        if (-not (Test-PSGalleryUpdateCheckDue $moduleName $intervalHours)) { return }

        # Ask only for the latest stable package, not the entire version history.
        $id = [Uri]::EscapeDataString($moduleName.Replace("'", "''"))
        $uri = "https://www.powershellgallery.com/api/v2/FindPackagesById()?id=%27$id%27&`$filter=IsLatestVersion&`$top=1"
        $feed = Invoke-WebRequest -Uri $uri -UseBasicParsing -TimeoutSec 3 -MaximumRedirection 0 -ErrorAction Stop
        $entry = ([xml]$feed.Content).feed.entry
        $version = [version]$entry.properties.Version
        if ($version -gt [version]$currentVersion) {
            Write-Host "Found a new module version {$version}. Update with: Update-Module -Name $moduleName -Force"
        }
    }
    catch {
        # Update checks are optional; offline, malformed feed and HTTP errors are quiet.
    }
}
