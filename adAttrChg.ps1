#Set-ADUser -Identity $user 

$users = Import-Csv 'D:\New folder\emps.csv'

foreach ($user in $users) {
    try{    
        $info = Get-ADUser $user.Username  -ErrorAction Stop
        Write-Host $info.SamAccountName "," $info.Name "," $info.Enabled
    }
    Catch {Write-Host $user.Username " is not a valid username" -ForegroundColor Red}
}
