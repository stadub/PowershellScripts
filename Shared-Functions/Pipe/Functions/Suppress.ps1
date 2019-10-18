
<#
.SYNOPSIS
Snuze the pipe out

.DESCRIPTION
One of the options to avoid comman output

.EXAMPLE
cp c:\Windows d:\windows | Suppress

.NOTES
General notes
#>

filter Suppress(){
    return
}

