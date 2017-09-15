$user = Read-Host -Prompt 'Please enter username '
if ($user -eq ""){exit}
$prop = @('LockedOut', 'AccountLockoutTime', 'BadLogonCount', 'LastBadPasswordAttempt', 'LastLogonDate', 'msDS-UserPasswordExpiryTimeComputed')
$DomainControllers = Get-ADDomainController -Filter * #You need at least one reachable Domain Controller(dc) for this to work
$gonogo = 'False'
$badPool = New-Object System.Collections.ArrayList
try {
    [string[]] $blist = Get-Content blistdc.txt -ErrorAction Stop
}
catch {}

#Initial pull of information from Domain Controllers(DC's), only active lockouts on a DC will be shown.
foreach($DC in $DomainControllers) #The purpose of this section is to give detailed lockout information
{
    IF ($blist -contains $DC.Name) {Continue} #Blacklist for readonly or  a DR DC
    try{
        $locked = Get-ADUser -Identity $user -Server $DC -Properties LockedOut -ErrorAction Stop
    }
    catch { Write-Host $DC.Name "Failed to read, consider adding to switch!" -foregroundcolor red }
    if($locked.LockedOut -eq "True"){
        $gonogo = 'True'
        $badPool.Add($DC) #The reason for the list is to speedup unlock of only affected DC's
        $DC.Name
        Get-ADUser -Identity $user -Server $DC -Properties $prop | Select-Object -Property 'LockedOut', 'AccountLockoutTime', 'BadLogonCount', 'LastBadPasswordAttempt', 'LastLogonDate', @{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}
     }
}
 
#The actual unlocking portion, the cred check is only necessary if you have special admin creds to unlock accounts.
if($gonogo -eq "True")
{
    $unlock = Read-Host -Prompt 'Would you like to run unlock?'
    If ($unlock -eq "y" -or $unlock -eq "Y")
    {
        <#If ($creds -eq $null){
            $creds = Get-Credential
        }#>
        foreach($bad in $badPool)
        {
            $bad.Name
            Unlock-ADAccount -Identity $user -Server $bad #-Credential $creds
        }
    }
}