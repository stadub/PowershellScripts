if($ModuleDevelopment){
    . $PSScriptRoot\..\Shared-Functions\ModuleLoader.ps1 "$PSScriptRoot"
}
else {
    if( -not $SharedLocal -or -not (Test-Path $SharedLocal) ){
        throw "Shared functions folder doesn't exist. 
        Looks like module typing to start in Develoment mode. 
        To start Development mode set flag: `$ModuleDevelopment=`$true
        Also you can set `$DebugPreference=`"Continue`" to getmore detalied strack trace
        Or set `$NoExport=`$True to disable `Export-ModuleMember` functions
        "
    }
    . $PSScriptRoot\Shared\ModuleLoader.ps1 "$PSScriptRoot"
}

