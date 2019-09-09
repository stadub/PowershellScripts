#
# Module manifest for module 'Currency-Conv'
#
# Generated by: Dmitry Stadub
#
# Generated on: 28.04.2019
#

@{

# Script module or binary module file associated with this manifest.
# RootModule = ''

# Version number of this module.
ModuleVersion = '1.5.0'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = 'ec7f5ac6-19a7-4460-98b8-058192fe7f78'

# Author of this module
Author = 'Dmitry Stadub'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = '(c) Dmitry Stadub. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Currency converter. Exchange rates source - https://currencyconverterapi.com
Full documentation at the Github: https://github.com/stadub/PowershellScripts/tree/master/Currency-Conv
'

# Minimum version of the PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
#NestedModules = @('Aliases.ps1','Functions.ps1')
RootModule = "Currency-Conv.psm1"

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @('*')

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @('*')

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('currency','currency-convereter','exchange','currency-exchange', 'currencyconverterapi', 'convereter', 'exchange-rates' )

        # A URL to the license for this module.
        LicenseUri = 'http://opensource.org/licenses/MIT'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/stadub/PowershellScripts/tree/master/Currency-Conv'

        # A URL to an icon representing this module.
        IconUri = 'https://raw.githubusercontent.com/stadub/PowershellScripts/master/Currency-Conv/Assets/Icon.ico'

        # ReleaseNotes of this module
        ReleaseNotes = '
            Console currency converter.
            As currency exchange rates souce used service https://free.currencyconverterapi.com/
        '

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
HelpInfoURI = 'https://github.com/stadub/PowershellScripts/blob/master/Currency-Conv/README.md'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

