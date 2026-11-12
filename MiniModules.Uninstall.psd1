@{
    RootModule = 'Uninstall.psm1'
    ModuleVersion = '1.0.1'
    GUID = '27c80b64-2c07-43ee-ae20-4d94965295eb'
    Author = 'Dima Stadub'
    Description = 'Windows application uninstall helper using the registry and msiexec. Importing the module does not uninstall applications.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Uninstall-Application')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Windows', 'Uninstall', 'msiexec')
            LicenseUri = 'https://github.com/stadub/PowershellScripts/blob/master/LICENSE'
            ProjectUri = 'https://github.com/stadub/PowershellScripts'
            ReleaseNotes = 'Prepare the existing standalone module for manifest-based packaging; uninstall implementation unchanged.'
        }
    }
}
