$soft = Read-Host -Prompt 'Please enter software name '
$creds = Get-Credential
$comps = Get-ADComputer -Filter *
#$liveComps = @()

foreach ($comp in $comps){
    try{
        $online = Test-Connection -BufferSize 32 -Count 1 -ComputerName $comp.Name -Quiet -ErrorAction Stop
    }
    catch{Write-Host $comp.Name " offline"}
    #if($online -eq $true){$liveComps += $comp}
    if($online -eq $true){
        Write-Host $comp.Name " in progress"
        $checks = Get-WmiObject -ComputerName $comp.Name -Class win32_Product -Credential $creds
        foreach($check in $checks){
            if ($check.Name -like $soft){
                $writeItem = New-Object System.Object
                    $writeItem | Add-Member NoteProperty -Name "Computer Name" -Value $comp.Name
                    $writeItem | Add-Member NoteProperty -Name "Software Name" -Value $check.Name
                    $writeItem | Add-Member NoteProperty -Name "Version" -Value $check.Version
                $writeItem | Export-Csv -NoTypeInformation -Append -Path "SoftwareScan.csv"
            }
        }

    }
}

$grids = Import-Csv -Path "SoftwareScan.csv" | Out-GridView
Read-Host -Prompt "Press enter to exit"
