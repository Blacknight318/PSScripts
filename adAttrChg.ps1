#Set-ADUser -Identity $user 

$users = Import-Csv 'D:\New folder\test.csv'
$creds = Get-Credential

foreach($user in $users){
    [string]$info
    try{$info = Get-ADUser -Identity $user.Username -ErrorAction Stop}
    catch{Write-Host $user.Name " is not listed in AD" -ForegroundColor Red}

    if($user.EmployeeNumber.length -gt 0 -and $info.EmployeeID -eq ""){
        Set-ADUser -Identity $user.Username -EmployeeID $user.EmployeeNumber -Credential $creds -WhatIf
    }
}