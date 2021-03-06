<#
.SYNOPSIS
Return only the last element

.DESCRIPTION
Skip all pipe elemants till last

.EXAMPLE
ls | Limit-Last

#>

filter Limit-Last {
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
        return $current
    }
 }
