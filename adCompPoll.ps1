$computer = Read-Host -Prompt 'Please enter computer name with * for wildcard'
$DomainControllers = Get-ADDomainController -Filter *

foreach($DC in $DomainControllers)
{
    try{
        $comp = Get-ADComputer -Filter 'Name -like $computer' -Server $DC
    }
    catch { Write-Host $DC.Name "Failed to read!" -foregroundcolor red }
    Write-Host $DC.Name "==>" $comp.Name
}
