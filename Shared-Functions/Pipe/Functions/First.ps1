<#
.SYNOPSIS
Return First Element

.DESCRIPTION
Return only the first element from the pipe

.EXAMPLE
ls | First

#>

filter First {
    $_
    Break
}
