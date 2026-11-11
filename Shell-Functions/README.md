# Shell-Functions source module

Import Shell-Function.psd1 to load the existing shell filters and helpers. The
manifest previously imported nothing and exported no commands. The loader now
exports seven existing functions and seven aliases without global-scope alias
writes. The stale pb alias is omitted because Export-Module is absent, and the protected
PowerShell fl (Format-List) alias is preserved; ln/mklink call the link helper.

This source repair corrects Split-String's accidental method-property access,
binds New-FileSystemLink to its existing LinkType enum, and maps enum values to
PowerShell provider item types. The spelling of existing public command/parameter
names is retained. Windows batch/Visual Studio helpers are not executed at import.

Run Shell-Function.Tests.ps1 with Pester 4.10.1. CI tests imports/exports, real text
filters and mocked link-provider arguments; it never runs cmd, changes Visual
Studio state, creates links or invokes the interactive prompt. This module has
no configured Gallery publication or release package.
