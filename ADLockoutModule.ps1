function Get-Lockout(){
    #Polling DC's for lockouts

    <#
    .Synopsis
        List Active Directory lockouts
    .Description
        This will pull a list of domain controllers and poll them for lockouts for the specified user.
    .Inputs
        Active Directory Username
    .Outputs
        List of servers, number of failed attempts, and lockout time. This also spits out an object for further use.
    .Link
        https://github.com/Blacknight318/PSScripts/blob/master/ADLockoutModule.ps1
    #>

    [CmdletBinding()]
    param(    
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$User
    )
    $start = Get-Date
    $DomainControllers = Get-ADDomainController -Filter *
    #$prop = @('LockedOut', 'AccountLockoutTime', 'BadLogonCount', 'LastBadPasswordAttempt', 'LastLogonDate', 'msDS-UserPasswordExpiryTimeComputed')
    $listBad = @()
    $servs = @()
    try {
        [string[]] $blist = Get-Content blistdc.txt -ErrorAction Stop
    }
    catch {}
    
    foreach($DC in $DomainControllers) #The purpose of this section is to give detailed lockout information
    {
        IF ($blist -contains $DC.Name) {Continue} #Blacklist for readonly or  a DR DC
        try{
            $locked = Get-ADUser -Identity $user -Server $DC -Properties LockedOut,BadlogonCount,AccountLockoutTime -ErrorAction Stop
        }
        catch { Write-Host $DC.Name "Failed to read, consider adding to blacklist!" -foregroundcolor red }
        if($locked.LockedOut -eq "True"){
            #$deets = Get-ADUser -Identity $user -Server $DC -Properties $prop
            $writeItem = New-Object System.Object
                $writeItem | Add-Member NoteProperty -Name "Domain Controller" -Value $DC.Name
                $writeItem | Add-Member NoteProperty -Name "Bad Attempts" -Value $locked.BadLogonCount
                $writeItem | Add-Member NoteProperty -Name "Lockout time" -Value $locked.AccountLockoutTime
            $listBad += $writeItem
            $servs += $DC.Name
         }
    }
    #Write-Output $listBad
    $listBad | Format-Table
    $end = Get-Date
    $runtime = New-TimeSpan -Start $start -End $end
    Write-Host $runtime
    if($servs.length -eq 0){break}
    $clearLocks = Read-Host -Prompt "Press enter to unlock, press Ctrl+C to exit"

    if($clearLocks -eq ""){
        Clear-Lockout -User $User -Servers $servs
    }
}

Function Clear-Lockout{
    <#
    .Synopsis
        Clear Lockouts
    .Description
        Clear lockouts for a given user on all supplied Domain Controllers
    .Inputs
        Active Directory Username(required) and Domain Controllers(optional, if none supplied all available Domain Controllers will be cleared)
    .Outputs
        Servers where lockouts were cleared
    .Link
        https://github.com/Blacknight318/PSScripts/blob/master/ADLockoutModule.ps1
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$User,

        [Parameter(Mandatory=$false)]
        [string[]]$Servers
    )
    
    $creds = Get-Credential
    $start = Get-Date

    if($Servers -eq $null){
        $Servers = Get-ADDomainController -Filter *
    }
    foreach($Server in $Servers){
        Unlock-ADAccount -Identity $User -Server $Server -Credential $creds
        Write-Host $Server " unlocked"
    }
    $end = Get-Date
    $runTime = New-TimeSpan -Start $start -End $end
    Write-Host $runTime
    #Invoke-Command -ComputerName $Servers -Credential $creds {Unlock-ADAccount -Identity $User -Credential $creds}
}