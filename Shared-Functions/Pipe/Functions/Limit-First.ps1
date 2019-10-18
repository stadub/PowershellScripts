<#
.SYNOPSIS
Return First Element

.DESCRIPTION
Return only the first element from the pipe

.EXAMPLE
ls | Limit-First

#>

filter Limit-First {
    $_
    Break
}
