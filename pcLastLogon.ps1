[string[]] $comps = Get-Content machines.txt

foreach($comp in $comps){
    try{
        $result = Get-ADComputer $comp -Properties Name, LastLogonDate -ErrorAction Stop
    }
    catch{
        Write-Host $comp " not found in AD!" 
        Continue
    }
    #Write-Host $result.Name $result.LastLogonDate
    if($result.Enabled -eq "True"){
        $writeItem = New-Object System.Object
            $writeItem | Add-Member NoteProperty -Name "Name" -Value $result.Name
            $writeItem | Add-Member NoteProperty -Name "Last Seen" -Value $result.LastLogonDate
        $writeItem | Export-Csv -NoTypeInformation -Append -Path "temp.csv"
    }
}

$grids = Import-Csv -Path "temp.csv" | Out-GridView