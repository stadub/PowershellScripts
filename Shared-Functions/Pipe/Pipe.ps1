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


<#
.SYNOPSIS
Skip N elemtns from pipe

.DESCRIPTION
Return only the N'ths element from pipe

.PARAMETER Count
Number of elements to skip

.EXAMPLE
ls | Skip -Count 3 | Take -Count 2

#>

 filter Skip {
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


 <#
 .SYNOPSIS
Process only N elements from pipe
 
 .DESCRIPTION
 Return only N elements from pipe
 
 .PARAMETER count
Number of elements to pass througth
 
 .EXAMPLE
ls | Skip -Count 3 | Take -Count 2
 
 #>
 
 filter Take {
    param (
        [int]$Count
    )
    BEGIN
    {
        if( $Count -eq 0){
            $Count = -1;
        }
        if( !$Count){
            $Count = -1;
        }
    } 
    PROCESS
    {
        
        if( $count -ne -1 ){
            if( $count -eq 0 ){
                
            }
            else{
                $count -= 1;
                return $_
            }
        }
        else{
            return $_
        }
    }
 }


<#
.SYNOPSIS
Return only the last element

.DESCRIPTION
Skip all pipe elemants till last

.EXAMPLE
ls | Last

#>

 filter Last {
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

<#
.SYNOPSIS
Snuze the pipe out

.DESCRIPTION
One of the options to avoid comman output

.EXAMPLE
cp c:\Windows d:\windows | Snuze

.NOTES
General notes
#>

filter Snuze(){
    return
}

<#
.SYNOPSIS


.DESCRIPTION
Long description

.PARAMETER Type
Parameter description

.PARAMETER Strict
If $True - only the type
otherwise check the type decedants 

.EXAMPLE

 ls | WhereType [FileSystemInfo] -Strict = $false
 "a", 3, 5 | WhereType -TypeName "string" 
 Import-FsStore "def" | WhereType -TypeName "ConcurrentDictionary```2[string,object]"
#>

filter WhereType {
   param (

    #[Parameter(Position = 0, ParameterSetName = 'Type')]
    [System.Type] $Type,
    #[Parameter(Position = 1, ParameterSetName = 'Type')]    
    [bool]$Strict=$true,

    #[Parameter(Position = 0, ParameterSetName = 'TypeName')]
    [string]$TypeName
   )
   BEGIN
   {
   } 
   PROCESS
   {
        $argType = $_.GetType()
        
        if($null -ne $typeName){

            $itemTypeName = $argType.Name
    
            if( $argType.IsGenericType ){
                $itemTypeName += '['
                foreach( $arg in $argType.GetGenericArguments()){
                    $itemTypeName += $arg.Name
                    $itemTypeName += ','
                }
                $itemTypeName = $itemTypeName.TrimEnd(",")
                $itemTypeName += ']'
            }

            if( [String]::Compare( $TypeName, $itemTypeName, $true) -eq 0 ){
                return $_
            }
        }
        else{

            if($Strict){
                if( $argType -eq $Type ){
                    return $_
                }
            }
            else {
                if ( $_.IsAssignableFrom( $Type ) ) {
                    return $_
                }
            }
        }
   }
}
