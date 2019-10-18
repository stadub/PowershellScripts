
<#
.SYNOPSIS
Snuze the pipe out

.DESCRIPTION
One of the options to avoid comman output

.EXAMPLE
cp c:\Windows d:\windows | Hide-Out

.NOTES
General notes
#>

filter Hide-Out(){
    return
}

