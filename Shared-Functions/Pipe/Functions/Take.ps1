


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


