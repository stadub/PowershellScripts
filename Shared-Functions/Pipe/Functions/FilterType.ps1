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

 ls | FilterType -Type [FileSystemInfo] -Strict $false
 "a", 3, 5 | FilterType -TypeName "string" 
 Import-FsStore "def" | FilterType -TypeName "ConcurrentDictionary```2[string,object]"
#>

filter FilterType {
    param (
 
     #[Parameter(Position = 0, ParameterSetName = 'Type')]
     [System.Type]$Type,
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
         
         #type name check
         if( -not [string]::IsNullOrWhitespace( $typeName) ) {
 
             $itemTypeName = $argType.Name
     
             if( $argType.IsGenericType) {
                 $itemTypeName += '['
                 foreach( $arg in $argType.GetGenericArguments()){
                     $itemTypeName += $arg.Name
                     $itemTypeName += ','
                 }
                 $itemTypeName = $itemTypeName.TrimEnd(",")
                 $itemTypeName += ']'
             }
 
             if( $Strict){
                 if([String]::Compare( $TypeName, $itemTypeName, $true) -eq 0 ) {
                     return $_
                 }
             }
             else{
                if(  $itemTypeName -like $TypeName ) {
                    return $_
                }
             }

         }
         else{
 
             if($Strict){
                 if( $argType -eq $Type ){
                     return $_
                 }
             }
             else {
                 if ( $Type.IsAssignableFrom( $_.GetType() ) ) {
                     return $_
                 }
             }
         }
    }
 }
