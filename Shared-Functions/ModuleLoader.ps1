Param([string]$scriptRoot)


function LoadModule {
    param ($path)
    $loadRef = Get-PSCallStack

    Write-Debug "Loading module referenced in line $($loadRef[1].Location)"
    if($null -eq $path){
        Write-Debug "No module found."
        return;
    }
    
    $loadedFunctions =  Get-ChildItem -Path Function:
    Foreach($import in @($path))
    {
        if($import.Name -like "*.Test.ps1" -or $import.Name -like "*.Tests.ps1" ){
            continue;
        }
        Try
        {
            Write-Debug "Loading file $($import.FullName)."
            . $import.FullName
        }
        Catch
        {
            Write-Error "Failed to import function $($import.FullName): $_"
        }
    }

    $functions= Get-ChildItem -Path Function: | `
        Where-Object { $loadedFunctions -notcontains $_ } | `
        ForEach-Object{ Get-Item function:$_ }

    return $functions
}


$script:Public  = Get-ChildItem $scriptRoot\*.ps1 -ErrorAction SilentlyContinue 
$script:PublicFolder  = Get-ChildItem $scriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue 


$script:Private = Get-ChildItem $scriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue 

if( !Test-Path variable:ModuleDevelopment  -or !$ModuleDevelopment ){
    Write-Debug "Starting module in production mode."
    $script:SharedFunctions = Get-ChildItem $scriptRoot\Shared\*.ps1 -ErrorAction SilentlyContinue 
}
else{
    Write-Debug "Starting module in development mode."
    $script:SharedFunctions = Get-ChildItem $scriptRoot\..\Shared-Functions\*.ps1 -ErrorAction SilentlyContinue 

    if( -not $SharedFunctions -or -not (Test-Path $SharedFunctions) ){
        throw "Shared functions folder doesn't exist. 
        Looks like module typing to start in Develoment mode. 
        To start Development mode set flag: `$ModuleDevelopment=`$true
        Also you can set `$DebugPreference=`"Continue`" to getmore detalied strack trace
        Or set `$NoExport=`$True to disable `Export-ModuleMember` functions
        "
    }
}

$script:sharedFunction = LoadModule ($SharedFunctions| Where-Object { $_.Name -ne 'ModuleLoader.ps1'  } )


$script:privateFunctions = LoadModule $script:Private

$script:publicFunctions = LoadModule $script:PublicFolder

$script:publicFunctions += LoadModule $script:Public

$script:sharedFunction | ForEach-Object{
    Write-Debug "Loading shared function $($_.Name)"
    $_  | new-item -Path "Function:$($_.Name)"
}

$script:privateFunctions | ForEach-Object{
    Write-Debug "Loading private function $($_.Name)"
    $_  | new-item -Path "Function:$($_.Name)"
}

$script:publicFunctions| ForEach-Object{
    Write-Debug "Loading public function $($_.Name)"
    $_  | new-item -Path "Function:$($_.Name)"
}

#filter initalize scripts
$initScripts = ($script:privateFunctions +  $script:publicFunctions )| `
    Where-Object{ 
        $_.Name -eq 'Initalize' -or  
        $_.Name -eq 'Init' -or 
        $_.Name -eq '_Initalize' -or  
        $_.Name -eq '_Init'} 

#execute all initalizers
$initScripts | ForEach-Object{ & $_ }

if ( !Test-Path variable:NoExport  -or !$NoExport ){
#Write-Output "Module"
Write-Debug "Exporting functions"

#
$script:publicFunctions| 
Where-Object { $_.Name -notlike '_*'  } |  ` # not extport _Name functions
ForEach-Object{

    Write-Debug "Exporting function $($_.Name)"
    Export-ModuleMember -Function $_.Name
}

}