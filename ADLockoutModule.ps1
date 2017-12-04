function Get-Lockouts(){
    #Polling DC's for lockouts

    <#
    .Synopsis
    .Description
    .Inputs
    .Outputs
    .Link
    #>

    [CmdletBinding()]
    param($User)

    $DomainControllers = Get-ADDomainController -Filter *
    $prop = @('LockedOut', 'AccountLockoutTime', 'BadLogonCount', 'LastBadPasswordAttempt', 'LastLogonDate', 'msDS-UserPasswordExpiryTimeComputed')
    #$writeItem = New-Object System.Object
    $listBad = @()
    try {
        [string[]] $blist = Get-Content blistdc.txt -ErrorAction Stop
    }
    catch {}
    
    foreach($DC in $DomainControllers) #The purpose of this section is to give detailed lockout information
    {
        IF ($blist -contains $DC.Name) {Continue} #Blacklist for readonly or  a DR DC
        try{
            $locked = Get-ADUser -Identity $user -Server $DC -Properties LockedOut -ErrorAction Stop
        }
        catch { Write-Host $DC.Name "Failed to read, consider adding to blacklist!" -foregroundcolor red }
        if($locked.LockedOut -eq "True"){
            #$DC.Name
            #Get-ADUser -Identity $user -Server $DC -Properties $prop | Select-Object -Property 'LockedOut', 'AccountLockoutTime', 'BadLogonCount', 'LastBadPasswordAttempt', 'LastLogonDate', @{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}
            $deets = Get-ADUser -Identity $user -Server $DC -Properties $prop
            $writeItem = New-Object System.Object
                $writeItem | Add-Member NoteProperty -Name "Domain Controller" -Value $DC.Name
                $writeItem | Add-Member NoteProperty -Name "Bad Attempts" -Value $deets.BadLogonCount
                $writeItem | Add-Member NoteProperty -Name "Lockout time" -Value $deets.AccountLockoutTime
                #$writeItem | Add-Member NoteProperty -Name "Last Bad Attempt" -Value $deets.LastBadPasswordAttempt
            $listBad += $writeItem
            #$writeItem | Export-Csv -NoTypeInformation -Append -Path "track_$((Get-Date).ToString('MM-dd-yy')).csv"
         }
    }
    $listBad | Out-GridView
}