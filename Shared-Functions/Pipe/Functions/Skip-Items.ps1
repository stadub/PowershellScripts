

<#
.SYNOPSIS
Skip N elemtns from pipe

.DESCRIPTION
Return only the N'ths element from pipe

.PARAMETER Count
Number of elements to skip

.EXAMPLE
ls | Skip-Items -Count 3 | Take -Count 2

#>

filter Skip-Items {
    param (
        [int]$Count
    )
    BEGIN
    {
    } 
    PROCESS
    {
        if( $Count -gt 0 ){
            $Count -= 1
        }
        else{
            return $_
        }
    }
 }